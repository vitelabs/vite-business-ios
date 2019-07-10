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

    private let disposeBag = DisposeBag()
    private var interactor: VBInteractor?
    private var tasks = [BifrostViteSendTxTask]()
    private var isConnectedAndApprovedBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    var isConnectedAndApproved: Bool { return isConnectedAndApprovedBehaviorRelay.value }
    lazy var isConnectedAndApprovedDriver: Driver<Bool> = self.isConnectedAndApprovedBehaviorRelay.asDriver()


    var currectTask: BifrostViteSendTxTask? { return tasks.first }
    func removeTask(_ task: BifrostViteSendTxTask) {
        for (index, t) in tasks.enumerated() where t.id == task.id {
            tasks.remove(at: index)
            return
        }
    }

    private init() {
        isConnectedAndApprovedDriver.drive(onNext: { [weak self] (connected) in
            plog(level: .info, log: "connect state changed: \(connected)", tag: .bifrost)
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
        guard let session = VBSession.from(string: uri.string()) else {
            plog(level: .severe, log: "invalid uri", tag: .bifrost)
            self.approveFailed(message: "invalid uri")
            return
        }

        plog(level: .info, log: "try connect", tag: .bifrost)

        HUD.show()
        if let i = interactor, i.connected {
            i.killSession().cauterize()
        }

        let clientMeta = VBClientMeta(name: Bundle.main.appName,
                                    version: Bundle.main.versionNumber,
                                    versionCode: Bundle.main.buildNumber,
                                    bundleId: Bundle.main.bundleIdentifier ?? "",
                                    platform: "ios",
                                    language: LocalizationService.sharedInstance.currentLanguage.languageCode)

        let i = VBInteractor(session: session, meta: clientMeta)
        configure(interactor: i)
        i.connect()
            .done { [weak self] (connected) in
                guard let `self` = self else { return }
                if connected {
                    plog(level: .info, log: "socket connected, wait for receive session request", tag: .bifrost)
                    // after 2 second, if not receive session request, disconnect and show error message
                    GCD.delay(2, task: {
                        guard let interactor = self.interactor else { return }
                        if !interactor.hasReceivedSessionRequest {
                            plog(level: .info, log: "receive session request time out, exit bifrost", tag: .bifrost)
                            self.approveFailed(message: BifrostManagerError.connectTimeout.localizedDescription)
                        }
                    })
                } else {
                    plog(level: .info, log: "socket connect error, exit bifrost", tag: .bifrost)
                    self.approveFailed(message: BifrostManagerError.unknown.localizedDescription)
                }
            }.catch { [weak self] (error) in
                plog(level: .info, log: "socket connect error \(error.localizedDescription), exit bifrost", tag: .bifrost)
                self?.approveFailed(message: error.localizedDescription)
            }
        interactor = i
    }

    func disConnect() {
        plog(level: .info, log: "disconnect, exit bifrost", tag: .bifrost)
        if let i = interactor, i.connected {
            i.killSession().cauterize()
        }
    }
}

extension BifrostManager {

    fileprivate func configure(interactor: VBInteractor) {

        let chainId = 1
        let currentAddress = HDWalletManager.instance.account!.address

        interactor.onSessionPintTimeout = { [weak self] in
            plog(level: .info, log: "callback onSessionPintTimeout", tag: .bifrost)
            guard let `self` = self else { return }
            self.disConnect()
        }

        interactor.onDisconnect = { [weak self] (error) in
            plog(level: .info, log: "callback onDisconnect", tag: .bifrost)
            guard let `self` = self else { return }
            self.tasks = [BifrostViteSendTxTask]()
            self.isConnectedAndApprovedBehaviorRelay.accept(false)
        }

        interactor.onSessionRequest = { [weak self] (id, peer) in
            HUD.hide()
            guard let `self` = self else { return }

            let message: String
            if self.isConnectedAndApproved {
                message = R.string.localizable.bifrostAlertApproveSessionAgainMessage(peer.url)
            } else {
                if let address = peer.lastAccount, address.isViteAddress, address != currentAddress {
                    message = R.string.localizable.bifrostAlertApproveSessionAnotherAddressMessage(address, currentAddress, peer.url)
                } else {
                    message = R.string.localizable.bifrostAlertApproveSessionMessage(peer.url)
                }
            }

            Alert.show(title: R.string.localizable.bifrostAlertTipTitle(),
                       message: message,
                       actions: [
                        (.cancel, { _ in
                            plog(level: .info, log: "user canceled session, exit bifrost", tag: .bifrost)
                            self.interactor?.rejectSession().cauterize()
                            self.approveFailed(message: nil)
                        }),
                        (.default(title: R.string.localizable.confirm()), { _ in
                            plog(level: .info, log: "user approved session, congratulations", tag: .bifrost)
                            self.interactor?.approveSession(accounts: [currentAddress], chainId: chainId).cauterize()
                            self.isConnectedAndApprovedBehaviorRelay.accept(true)
                        })
                ])
        }

        interactor.onViteSendTx = { [weak self] (id, tx) in
            guard let `self` = self else { return }
            BifrostConfrimInfoFactory.generateConfrimInfo(tx).done({[weak self] (info, tokenInfo) in
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

