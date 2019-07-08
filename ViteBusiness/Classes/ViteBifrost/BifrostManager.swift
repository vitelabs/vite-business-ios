//
//  BifrostManager.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/11.
//

import enum Alamofire.Result
import RxSwift
import RxCocoa
import ViteWallet
import PromiseKit

public final class BifrostManager {
    public static let instance = BifrostManager()

    enum BifrostManagerError: Error {
        case connectTimeout
        case unknown
    }

    private var interactor: WCInteractor?
    private let clientMeta = WCPeerMeta(name: Bundle.main.appName,
                                        url: "https://itunes.apple.com/us/app/vite-official-hd-wallet/id1437629486?mt=8")

    private let disposeBag = DisposeBag()

    public lazy var isConnectedAndApprovedDriver: Driver<Bool> = self.isConnectedAndApprovedBehaviorRelay.asDriver()
    private var isConnectedAndApprovedBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private var tasks = [BifrostViteSendTxTask]()

    public var isConnectedAndApproved: Bool {
        return isConnectedAndApprovedBehaviorRelay.value
    }

    var currectTask: BifrostViteSendTxTask? {
        return tasks.first
    }

    func removeTask(_ task: BifrostViteSendTxTask) {
        for (index, t) in tasks.enumerated() where t.id == task.id {
            tasks.remove(at: index)
            return
        }
    }

    private init() {
        isConnectedAndApprovedDriver.drive(onNext: { [weak self] (connected) in
            guard let `self` = self else { return }
            guard let current = UIViewController.current else { return }
            if connected {
                self.showBifrostViewControllerIfNeeded()
            } else {
                if current is BifrostViewController {
                    current.navigationController?.popViewController(animated: true)
                }
                self.tasks = [BifrostViteSendTxTask]()
            }
        }).disposed(by: disposeBag)
    }

    func tryConnect(uri: BifrostURI) {
        guard let session = WCSession.from(string: uri.string()) else {
            fatalError()
        }

        HUD.show()
        if let i = interactor, i.connected { i.killSession().cauterize() }
        let i = WCInteractor(session: session, meta: clientMeta)
        configure(interactor: i)
        i.connect()
            .done { [weak self] (connected) in
                guard let `self` = self else { return }
                if connected {
                    // after 2 second, if not receive session request, disconnect and show error message
                    GCD.delay(2, task: {
                        guard let interactor = self.interactor else { return }
                        if !interactor.hasReceivedSessionRequest {
                            self.approveFailed(message: BifrostManagerError.connectTimeout.localizedDescription)
                        }
                    })
                } else {
                    self.approveFailed(message: BifrostManagerError.unknown.localizedDescription)
                }
            }.catch { [weak self] (error) in
                self?.approveFailed(message: error.localizedDescription)
            }
        interactor = i
    }

    func disConnect() {
        if let i = interactor, i.connected {
            i.killSession().cauterize()
        }

        tasks = [BifrostViteSendTxTask]()
    }


}

extension BifrostManager {


    fileprivate func configure(interactor: WCInteractor) {

        let chainId = 1
        let address = HDWalletManager.instance.account!.address

        interactor.onDisconnect = { [weak self] (error) in
            guard let `self` = self else { return }
            self.isConnectedAndApprovedBehaviorRelay.accept(false)
        }

        interactor.onSessionRequest = { [weak self] (id, peer) in
            HUD.hide()
            Alert.show(title: R.string.localizable.bifrostAlertTipTitle(),
                       message: R.string.localizable.bifrostAlertApproveSessionMessage(peer.url),
                       actions: [
                        (.cancel, { _ in
                            self?.interactor?.rejectSession().cauterize()
                            self?.approveFailed(message: nil)
                        }),
                        (.default(title: R.string.localizable.confirm()), { _ in
                            self?.interactor?.approveSession(accounts: [address], chainId: chainId).cauterize()
                            self?.isConnectedAndApprovedBehaviorRelay.accept(true)
                        })
                ])
        }

        interactor.onViteSendTx = { [weak self] (id, tx) in
            guard let `self` = self else { return }
            tx.generateConfrimInfo().done({[weak self] (info, tokenInfo) in
                guard let `self` = self else { return }
                let task = BifrostViteSendTxTask(id: id, tx: tx, info: info, tokenInfo: tokenInfo)
                self.tasks.append(task)
                self.showBifrostViewControllerIfNeeded()
            }).catch({ (error) in
                self.interactor?.rejectRequest(id: id, message: error.localizedDescription).cauterize()
            })
        }
    }

    @discardableResult
    func showBifrostViewControllerIfNeeded() -> BifrostViewController? {
        guard let current = UIViewController.current else { return nil }
        guard isConnectedAndApprovedBehaviorRelay.value else { return nil }

        let ret: BifrostViewController
        if let vc = current as? BifrostViewController {
            ret = vc
        } else {
            let vc = BifrostViewController(result: { [weak self] (ret, task, vc) in
                guard let `self` = self else { return }
                guard let account = HDWalletManager.instance.account else { return }
                if ret {
                    Workflow.bifrostSendTxWithConfirm(title: task.info.title ,
                                                      account: account,
                                                      toAddress: task.tx.block.toAddress,
                                                      tokenInfo: task.tokenInfo,
                                                      amount: task.tx.block.amount,
                                                      data: task.tx.block.data,
                                                      completion: { (ret) in
                                                        switch ret {
                                                        case .success(let accountBlock):
                                                            self.removeTask(task)
                                                            vc.hideConfrim()
                                                            self.interactor?.approveViteTx(id: task.id, accountBlock: accountBlock)
                                                            vc.showConfrimIfNeeded()
                                                        case .failure(let error):
                                                            plog(level: .debug, log: error.localizedDescription)
                                                        }
                    })
                } else {
                    self.removeTask(task)
                    vc.hideConfrim()
                    self.interactor?.rejectRequest(id: task.id, message: "cancel").cauterize()
                    vc.showConfrimIfNeeded()
                }
            })

            if let scanVc = current as? ScanViewController {
                scanVc.popSelfAndPush(vc)
            } else {
                current.navigationController?.pushViewController(vc, animated: true)
            }
            ret = vc
        }

        ret.showConfrimIfNeeded()
        return ret
    }

    fileprivate func approveFailed(message: String?) {
        let scanViewController: ScanViewController?
        if let vc = UIViewController.current as? ScanViewController {
            scanViewController = vc
        } else {
            scanViewController = nil
        }

        isConnectedAndApprovedBehaviorRelay.accept(false)
        interactor?.onSessionRequest = nil
        interactor?.killSession().cauterize()
        scanViewController?.startCaptureSession()

        HUD.hide()
        if let msg = message {
            Toast.show(msg)
        }
    }
}

struct BifrostViteSendTxTask {
    let id: Int64
    let tx : VBViteSendTx
    let info: BifrostConfrimInfo
    let tokenInfo: TokenInfo
}
