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
import Starscream

public final class BifrostManager {
    public static let instance = BifrostManager()

    enum Status: Equatable {
        case disconnect
        case connecting(times: Int)
        case waitForRequest
        case waitForUserApprove
        case connected
        case reConnecting(times: Int)
        case waitForPong
    }

    enum BifrostManagerError: Error, DisplayableError {
        case connectTimeout
        case unknown

        var errorMessage: String {
            switch self {
            case .connectTimeout:
                return R.string.localizable.bifrostErrorMessageTimeout()
            case .unknown:
                return R.string.localizable.bifrostErrorMessageUnknown()
            }
        }
    }

    private var alertHandler: AlertControl?
    private let disposeBag = DisposeBag()
    private var interactor: VBInteractor?
    private let statusBehaviorRelay: BehaviorRelay<Status> = BehaviorRelay(value: .disconnect)

    // MARK: Public Property
    let isAutoConfirmBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    lazy var allTasksDriver: Driver<[BifrostViteSendTxTask]> = self.allTasksBehaviorRelay.asDriver()
    lazy var statusDriver: Driver<Status> = self.statusBehaviorRelay.asDriver()
    var status: Status { return statusBehaviorRelay.value }

    // MARK: Task
    private let isInBackgroundBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private var allTasksBehaviorRelay: BehaviorRelay<[BifrostViteSendTxTask]> = BehaviorRelay(value: [BifrostViteSendTxTask]())
    private var processedTasks = [BifrostViteSendTxTask]()
    private var currectProcessingTask: BifrostViteSendTxTask? = nil
    private var pendingTasks = [BifrostViteSendTxTask]()

    private func addTask(_ task: BifrostViteSendTxTask) {
        pendingTasks.append(task)
        refreshAllTasks()
    }

    private func processNextTaskIfHas() -> BifrostViteSendTxTask? {

        if let task = currectProcessingTask {
            if task.status == .failed {
                task.status = .processing
                refreshAllTasks()
                return task
            } else {
                return nil
            }
        }

        guard var task = pendingTasks.first else { return nil }
        pendingTasks.remove(at: 0)
        task.status = .processing
        currectProcessingTask = task
        refreshAllTasks()
        return task
    }

    private func setTaskStatusFailed(_ task: BifrostViteSendTxTask) {
        guard status != .disconnect else { return }

        guard currectProcessingTask?.id == task.id else {
            fatalError()
        }

        task.status = .failed
        refreshAllTasks()
    }

    private func processedTask(_ task: BifrostViteSendTxTask, isFinished: Bool) {
        guard status != .disconnect else { return }

        guard currectProcessingTask?.id == task.id else {
            fatalError()
        }

        task.status = isFinished ? .finished : .canceled
        currectProcessingTask = nil
        processedTasks.append(task)
        refreshAllTasks()
    }

    private func clearTasks() {
        processedTasks = [BifrostViteSendTxTask]()
        currectProcessingTask = nil
        pendingTasks = [BifrostViteSendTxTask]()
        refreshAllTasks()
    }

    private func refreshAllTasks() {
        if let c = currectProcessingTask {
            allTasksBehaviorRelay.accept(processedTasks + [c] + pendingTasks)
        } else {
            allTasksBehaviorRelay.accept(processedTasks)
        }
    }

    // MARK: Init
    private init() {

        statusDriver.scan((nil, nil)) { (pair, new) -> (Status?, Status?) in (pair.1, new) }.drive(onNext: { [weak self] (old, new) in
            plog(level: .info, log: "[state] changed: \(old == nil ? "nil" : "\(old!)") -> \(new!)", tag: .bifrost)

            guard let `self` = self else { return }
            guard let current = UIViewController.current else { return }

            UIApplication.shared.isIdleTimerDisabled = (new != .disconnect)

            if old == .waitForUserApprove && new == .connected {
                // first connected
                _ = self.showBifrostViewController()
            } else if new == .disconnect {
                // disconnect
                guard var viewControllers = current.navigationController?.viewControllers else { return }
                var hasVC = false
                for (index, vc) in viewControllers.enumerated() where vc is BifrostHomeViewController {
                    viewControllers.remove(at: index)
                    hasVC = true
                }
                for (index, vc) in viewControllers.enumerated() where vc is BifrostTaskListViewController {
                    viewControllers.remove(at: index)
                    hasVC = true
                }
                if hasVC {
                    current.navigationController?.setViewControllers(viewControllers, animated: true)
                }
                self.clearTasks()
            }
        }).disposed(by: disposeBag)

        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] (account) in
            if account == nil {
                self?.disConnectProactive()
            }
        }).disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification) .bind { [weak self] _ in
            plog(level: .info, log: "[user] didEnterBackgroundNotification", tag: .bifrost)
            self?.isInBackgroundBehaviorRelay.accept(true)
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification) .bind { [weak self] _ in
            plog(level: .info, log: "[user] willEnterForegroundNotification", tag: .bifrost)
            self?.isInBackgroundBehaviorRelay.accept(false)
        }.disposed(by: disposeBag)

        self.isInBackgroundBehaviorRelay.asDriver().distinctUntilChanged().filter { !$0 }.drive(onNext: { [weak self] (_) in
            self?.processTaskIfHave()
        }).disposed(by: disposeBag)

        self.isAutoConfirmBehaviorRelay.asDriver().drive(onNext: { isAuto in
            if isAuto {
                plog(level: .info, log: "[user] enable auto confirm", tag: .bifrost)
            } else {
                plog(level: .info, log: "[user] disable auto confirm", tag: .bifrost)
            }
        }).disposed(by: disposeBag)
    }
}

// Operation
extension BifrostManager {

    // MARK: Const
    static let maxTryTimes = 10
    static let retryDelay: TimeInterval = 2
    static let waitForRequestTimeout: TimeInterval = 5
    static let waitForPongTimeout: TimeInterval = 5

    // MARK: Public Operation
    func tryConnect(uri: BifrostURI) {
        HUD.show()

        func tryConnect() {
            let session = VBSession.from(uri: uri)
            let clientMeta = VBClientMeta(name: Bundle.main.appName,
                                          version: Bundle.main.versionNumber,
                                          versionCode: Bundle.main.buildNumber,
                                          vbVersion: "1.0.0",
                                          bundleId: Bundle.main.bundleIdentifier ?? "",
                                          platform: "ios",
                                          language: LocalizationService.sharedInstance.currentLanguage.code)
            interactor = VBInteractor(session: session, meta: clientMeta)
            configure(interactor: interactor!)
            connecting()
        }

        if interactor != nil {
            disConnectProactive() {
                tryConnect()
            }
        } else {
            tryConnect()
        }
    }

    func disConnectByUser() {
        plog(level: .info, log: "[user] closed session, exit bifrost", tag: .bifrost)
        disConnectProactive()
    }

    // MARK: Private Operation
    fileprivate func configure(interactor: VBInteractor) {

        interactor.onDisconnect = { [weak self] (i, error) in
            guard let `self` = self else { return }
            // make sure interactor is current, otherwise ignore
            guard i === self.interactor else { return }
            switch self.status {
            case .disconnect:
                // do nothing
                break
            case .connecting:
                self.connecting()
            case .waitForRequest:
                // do nothing, depend on waitForRequest timeout
                break
            case .waitForUserApprove:
                if let alertHandler = self.alertHandler {
                    alertHandler.disMiss(completion: nil)
                }
                self.statusBehaviorRelay.accept(.disconnect)
                self.approveFailed(message: BifrostManagerError.unknown.localizedDescription)
            case .connected, .reConnecting, .waitForPong:
                self.reConnecting()
            }
        }

        interactor.onDisconnectByPeer = { [weak self] i in
            guard let `self` = self else { return }
            // make sure interactor is current, otherwise ignore
            guard i === self.interactor else { return }
            self.disConnectByPeer()
        }

        interactor.onSessionRequest = { [weak self] (i, id, peer) in
            HUD.hide()
            guard let `self` = self else { return }
            // make sure interactor is current, otherwise ignore
            guard i === self.interactor else { return }
            guard let currentAddress = HDWalletManager.instance.account?.address else { return }

            self.statusBehaviorRelay.accept(.waitForUserApprove)

            let chainId = 1
            let message: String
            let cancel: String
            let ok: String

            if let address = peer.lastAccount, address.isViteAddress, address != currentAddress {
                message = R.string.localizable.bifrostAlertApproveSessionAnotherAddressMessage(peer.url)
                cancel = R.string.localizable.bifrostAlertApproveSessionAnotherAddressCancel()
                ok = R.string.localizable.bifrostAlertApproveSessionAnotherAddressOk()
            } else {
                message = R.string.localizable.bifrostAlertApproveSessionMessage(peer.url)
                cancel = R.string.localizable.cancel()
                ok = R.string.localizable.confirm()
            }

            self.alertHandler = Alert.show(title: R.string.localizable.bifrostAlertTipTitle(),
                       message: message,
                       actions: [
                        (.default(title: cancel), { _ in
                            plog(level: .info, log: "[user] canceled session, exit bifrost", tag: .bifrost)
                            self.statusBehaviorRelay.accept(.disconnect)
                            self.interactor?.rejectSession().cauterize()
                            self.approveFailed(message: nil)
                        }),
                        (.default(title: ok), { _ in
                            plog(level: .info, log: "[user] approved session, congratulations", tag: .bifrost)
                            self.statusBehaviorRelay.accept(.connected)
                            self.interactor?.approveSession(accounts: [currentAddress], chainId: chainId).cauterize()
                            Statistics.log(eventId: Statistics.Page.WalletHome.bifrostConnect.rawValue)
                        })
                ])
        }

        interactor.onViteSendTx = { [weak self] (i, id, tx) in
            guard let `self` = self else { return }
            // make sure interactor is current, otherwise ignore
            guard i === self.interactor else { return }
            BifrostConfirmInfoFactory.generateConfirmInfo(tx).done({[weak self] (info, tokenInfo) in
                guard let `self` = self else { return }
                let task = BifrostViteSendTxTask(id: id, tx: tx, info: info, tokenInfo: tokenInfo)
                self.addTask(task)
                self.processTaskIfHave()
            }).catch({ (error) in
                self.interactor?.rejectRequest(id: id, message: error.localizedDescription).cauterize()
            })
        }
    }

    fileprivate func connecting() {

        guard let interactor = self.interactor else {
            self.statusBehaviorRelay.accept(.disconnect)
            return
        }

        func connect() {
            interactor.connect()
                .done { [unowned self] (connected) in
                    if connected {
                        self.statusBehaviorRelay.accept(.waitForRequest)
                        // after n second, if not receive session request, disconnect and show error message
                        GCD.delay(type(of: self).waitForRequestTimeout, task: {
                            if self.status == .waitForRequest {
                                self.statusBehaviorRelay.accept(.disconnect)
                                self.approveFailed(message: BifrostManagerError.connectTimeout.localizedDescription)
                            }
                        })
                    } else {
                        self.statusBehaviorRelay.accept(.disconnect)
                        self.approveFailed(message: BifrostManagerError.unknown.localizedDescription)
                    }
            }
        }

        if case .disconnect = self.status {
            self.statusBehaviorRelay.accept(.connecting(times: 1))
            connect()
        } else if case .connecting(let times) = self.status {
            if times < type(of: self).maxTryTimes {
                GCD.delay(type(of: self).retryDelay) {
                    self.statusBehaviorRelay.accept(.connecting(times: times + 1))
                    connect()
                }
            } else {
                self.statusBehaviorRelay.accept(.disconnect)
                self.approveFailed(message: R.string.localizable.bifrostErrorMessageUnknown())
            }
        } else {
            fatalError()
        }
    }

    fileprivate func reConnecting() {

        guard self.status != .disconnect else { return }
        guard let interactor = self.interactor else {
            self.statusBehaviorRelay.accept(.disconnect)
            return
        }

        func connect() {
            interactor.connect()
                .done { [unowned self] (connected) in
                    if connected {
                        self.sendPing()
                    } else {
                        self.reConnecting()
                    }
            }
        }

        if case .reConnecting(let times) = self.status {
            if times < type(of: self).maxTryTimes {
                GCD.delay(type(of: self).retryDelay) {
                    self.statusBehaviorRelay.accept(.reConnecting(times: times + 1))
                    connect()
                }
            } else {
                self.disConnectProactive()
            }
        } else {
            self.statusBehaviorRelay.accept(.reConnecting(times: 1))
            connect()
        }
    }

    fileprivate func sendPing() {
        guard let interactor = self.interactor else {
            self.statusBehaviorRelay.accept(.disconnect)
            return
        }

        statusBehaviorRelay.accept(.waitForPong)

        interactor.sendPing(timeout: type(of: self).waitForPongTimeout)
            .done { [weak self] in
                guard let `self` = self else { return }
                self.statusBehaviorRelay.accept(.connected)
            }.catch { [weak self] (error) in
                guard let `self` = self else { return }
                self.statusBehaviorRelay.accept(.disconnect)
        }
    }

    fileprivate func disConnectProactive(finished: (() -> Void)? = nil) {
        self.statusBehaviorRelay.accept(.disconnect)
        self.clearTasks()
        if let i = interactor, i.connected {
            i.killSession().always { [unowned self] in
                self.interactor = nil
                if let f = finished { f() }
            }
        }
    }

    fileprivate func disConnectByPeer() {
        self.statusBehaviorRelay.accept(.disconnect)
        self.clearTasks()
        if let i = interactor, i.connected {
            i.disconnect()
            interactor = nil
        }
    }
}

extension BifrostManager {

    // MARK: Public
    func showHomeVC() {
        let vc = self.showBifrostViewController()
        if let task = self.processNextTaskIfHas(), !isAutoConfirmBehaviorRelay.value {
            vc.showConfirm(task: task)
        }
    }

    // MARK: Private
    fileprivate func processTaskIfHave() {

        if self.isAutoConfirmBehaviorRelay.value {
            guard isInBackgroundBehaviorRelay.value == false else { return }

            guard let account = HDWalletManager.instance.account else { return }
            guard let task = self.processNextTaskIfHas() else { return }

            plog(level: .info, log: "[task] task: \(task.id) auto start sign", tag: .bifrost)
            Workflow.bifrostSendTx(needConfirm: false,
                                   title: task.info.title,
                                   account: account,
                                   toAddress: task.tx.block.toAddress,
                                   tokenId: task.tokenInfo.viteTokenId,
                                   amount: task.tx.block.amount,
                                   fee: task.tx.block.fee,
                                   data: task.tx.block.data,
                                   completion: { (ret) in
                                    switch ret {
                                    case .success(let accountBlock):
                                        self.processedTask(task, isFinished: true)
                                        self.interactor?.approveViteTx(id: task.id, accountBlock: accountBlock)
                                        plog(level: .info, log: "[task] task: \(task.id) auto finished sign", tag: .bifrost)
                                        self.processTaskIfHave()
                                    case .failure(let error):
                                        self.setTaskStatusFailed(task)
                                        plog(level: .info, log: "[task] task: \(task.id) auto failed sign", tag: .bifrost)
                                        plog(level: .warning, log: "\(error.localizedDescription)", tag: .bifrost)
                                        GCD.delay(1) { self.processTaskIfHave() }
                                    }
            })
        } else {
            guard let task = self.processNextTaskIfHas() else { return }
            let vc = self.showBifrostViewController()
            vc.showConfirm(task: task)
        }
    }

    fileprivate func showBifrostViewController() -> BifrostHomeViewController {

        let ret: BifrostHomeViewController
        if let vc = UIViewController.current as? BifrostHomeViewController {
            ret = vc
        } else {
            var exist: BifrostHomeViewController? = nil
            let viewControllers = UIViewController.current?.navigationController?.viewControllers ?? [UIViewController]()
            for vc in viewControllers where vc is BifrostHomeViewController {
                exist = vc as! BifrostHomeViewController
                break
            }

            if let e = exist {
                ret = e
            } else {
                ret = BifrostHomeViewController(result: { [weak self] (ret, task, vc) in
                    guard let `self` = self else { return }
                    guard let account = HDWalletManager.instance.account else { return }
                    if ret {
                        plog(level: .info, log: "[task] task: \(task.id) manual start sign", tag: .bifrost)
                        Workflow.bifrostSendTx(needConfirm: true,
                                               title: task.info.title,
                                               account: account,
                                               toAddress: task.tx.block.toAddress,
                                               tokenId: task.tokenInfo.viteTokenId,
                                               amount: task.tx.block.amount,
                                               fee: task.tx.block.fee,
                                               data: task.tx.block.data,
                                               completion: { (ret) in
                                                switch ret {
                                                case .success(let accountBlock):
                                                    self.processedTask(task, isFinished: true)
                                                    vc.hideConfirm()
                                                    self.interactor?.approveViteTx(id: task.id, accountBlock: accountBlock)
                                                    plog(level: .info, log: "[task] task: \(task.id) manual finished sign", tag: .bifrost)
                                                    self.processTaskIfHave()
                                                case .failure(let error):
                                                    plog(level: .info, log: "[task] task: \(task.id) manual failed sign", tag: .bifrost)
                                                    plog(level: .warning, log: "\(error.localizedDescription)", tag: .bifrost)
                                                }
                        })
                    } else {
                        self.processedTask(task, isFinished: false)
                        vc.hideConfirm()
                        self.interactor?.cancelRequest(id: task.id).cauterize()
                        plog(level: .info, log: "[task] task: \(task.id) manual canceled sign", tag: .bifrost)
                        self.processTaskIfHave()
                    }
                })
                UIViewController.current?.navigationController?.pushViewController(ret, animated: true)
            }
        }
        return ret
    }

    fileprivate func approveFailed(message: String?) {
        let scanViewController: ScanViewController?
        if let vc = UIViewController.current as? ScanViewController {
            scanViewController = vc
        } else {
            scanViewController = nil
        }

        interactor?.onSessionRequest = nil
        interactor?.killSession().cauterize()
        scanViewController?.startCaptureSession()

        HUD.hide()
        if let msg = message {
            Toast.show(msg)
        }
    }
}

