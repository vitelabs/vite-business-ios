//
//  BifrostManager.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/11.
//

import enum Alamofire.Result
import RxSwift
import RxCocoa


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

    private init() {
        isConnectedAndApprovedDriver.drive(onNext: { (connected) in
            guard let current = UIViewController.current else { return }
            if connected {
                guard !(current is BifrostViewController) else { return }
                let vc = BifrostViewController()
                if let scanVc = current as? ScanViewController {
                    scanVc.popSelfAndPush(vc)
                } else {
                    current.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if current is BifrostViewController {
                    current.navigationController?.popViewController(animated: true)
                }
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
    }

    func showBifrostViewControllerIfNeeded() {
        guard let current = UIViewController.current else { return }
        guard isConnectedAndApprovedBehaviorRelay.value else { return }
        if !(current is BifrostViewController) {
            let vc = BifrostViewController()
            current.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension BifrostManager {

    fileprivate func configure(interactor: WCInteractor) {

        let accounts = [""]
        let chainId = 1

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
                            self?.interactor?.approveSession(accounts: accounts, chainId: chainId).cauterize()
                            self?.isConnectedAndApprovedBehaviorRelay.accept(true)
                        })
                ])
        }
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
