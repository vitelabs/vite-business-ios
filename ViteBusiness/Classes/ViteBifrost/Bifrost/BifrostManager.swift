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
import Alamofire
import SwiftyJSON
import Vite_HDWalletKit

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

    private var currentIndex: Int = 0
    private var tasks = [BifrostViteSendTxTask]()
    private var isProcessing = false

    private func addTask(_ task: BifrostViteSendTxTask) {
        tasks.append(task)
        refreshAllTasks()
    }

    private var currentTask: BifrostViteSendTxTask? {
        guard tasks.count > currentIndex else { return nil }
        return tasks[currentIndex]
    }

    private func setTaskStatusProcessing(_ task: BifrostViteSendTxTask) {
        guard status != .disconnect else { return }

        guard currentTask?.id == task.id else {
            fatalError()
        }

        isProcessing = true
        task.status = .processing
        refreshAllTasks()
    }

    private func setTaskStatusWaitingForRetry(_ task: BifrostViteSendTxTask) {
        guard status != .disconnect else { return }

        guard currentTask?.id == task.id else {
            fatalError()
        }

        task.status = .waitingForRetry
        refreshAllTasks()
    }

    private enum ProcessedType {
        case finished
        case canceled
        case failed
    }

    private func processedTask(_ task: BifrostViteSendTxTask, processedType: ProcessedType) {
        guard status != .disconnect else { return }

        guard currentTask?.id == task.id else {
            fatalError()
        }

        switch processedType {
        case .finished:
            task.status = .finished
        case .canceled:
            task.status = .canceled
        case .failed:
            task.status = .failed
        }

        refreshAllTasks()
        currentIndex += 1
    }

    private func clearTasks() {
        tasks = [BifrostViteSendTxTask]()
        currentIndex = 0
        refreshAllTasks()
        isProcessing = false
        isAutoConfirmBehaviorRelay.accept(false)
    }

    private func refreshAllTasks() {
        allTasksBehaviorRelay.accept(tasks)
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
                for (index, vc) in viewControllers.enumerated() where vc is BifrostTaskDetailViewController {
                    viewControllers.remove(at: index)
                    hasVC = true
                }
                if hasVC {
                    current.navigationController?.setViewControllers(viewControllers, animated: true)
                }


                if let alertHandler = self.alertHandler {
                    alertHandler.disMiss(completion: nil)
                    self.alertHandler = nil
                }

                if let vc = current as? ScanViewController {
                    if old == .waitForUserApprove {
                        HUD.hide()
                        self.clearTasks()
                    } else {
                        self.approveFailed(message: nil)
                    }
                } else {
                    HUD.hide()
                    self.clearTasks()
                }


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

        BifrostManager.fetchAutoSigConfig()

    }
}

// Operation
extension BifrostManager {
    static let bridgeVersion = "2"

    // MARK: Const
    static let maxTryTimes = 10
    static let waitForRequestTimeout: TimeInterval = 10
    static let waitForPongTimeout: TimeInterval = 10

    // MARK: Public Operation
    func tryConnect(uri: BifrostURI) {
        HUD.show()

        func tryConnect() {
            let session = VBSession.from(uri: uri)
            let clientMeta = VBClientMeta(name: Bundle.main.appName,
                                          version: Bundle.main.versionNumber,
                                          versionCode: Bundle.main.buildNumber,
                                          bridgeVersion: BifrostManager.bridgeVersion,
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
                    self.alertHandler = nil
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
                let task = BifrostViteSendTxTask(id: id, info: info, tx: tx, tokenInfo: tokenInfo)
                self.addTask(task)
                self.processTaskIfHave()
            }).catch({ (error) in
                self.interactor?.rejectRequest(id: id, message: error.localizedDescription).cauterize()
            })
        }

        interactor.onViteSignMessage = { [weak self] (i, id, signMessage) in
            guard let `self` = self else { return }
            // make sure interactor is current, otherwise ignore
            guard i === self.interactor else { return }
            BifrostConfirmInfoFactory.generateConfirmInfo(signMessage).done { [weak self] info in
                guard let `self` = self else { return }
                let task = BifrostViteSendTxTask(id: id, info: info, signMessage: signMessage)
                self.addTask(task)
                self.processTaskIfHave()
            }.catch { (error) in
                self.interactor?.rejectRequest(id: id, message: error.localizedDescription).cauterize()
            }
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
                GCD.delay(reConnectingDelay(times: times)) {
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

    fileprivate func reConnectingDelay(times: Int) -> TimeInterval {
        return 2
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
            GCD.delay(reConnectingDelay(times: times)) {
                self.statusBehaviorRelay.accept(.reConnecting(times: times + 1))
                connect()
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
                plog(level: .info, log: "[peer] received pong", tag: .bifrost)
                self.statusBehaviorRelay.accept(.connected)
                self.processTaskIfHave()
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
        } else {
            if let f = finished { f() }
        }
    }

    fileprivate func disConnectByPeer() {
        plog(level: .info, log: "[peer] canceled session, exit bifrost", tag: .bifrost)
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
        if let task = currentTask, !(isAutoConfirmBehaviorRelay.value && canAutoConfirm(task: task)) {
            vc.showConfirm(task: task)
        }
    }

    // MARK: Private
    fileprivate func processTask(_ task: BifrostViteSendTxTask) {
        if self.isAutoConfirmBehaviorRelay.value && canAutoConfirm(task: task) {
            guard isInBackgroundBehaviorRelay.value == false else { return }
            guard let account = HDWalletManager.instance.account else { return }
            setTaskStatusProcessing(task)
            plog(level: .info, log: "[task] task: \(task.id) auto start sign", tag: .bifrost)
            switch task.type {
            case let .sendTx(tx, tokenInfo):
                Workflow.bifrostSendTx(needConfirm: false,
                                       title: task.info.title,
                                       account: account,
                                       toAddress: tx.block.toAddress,
                                       tokenId: tokenInfo.viteTokenId,
                                       amount: tx.block.amount,
                                       fee: tx.block.fee,
                                       data: tx.block.data,
                                       completion: { (ret) in
                                        switch ret {
                                        case .success(let accountBlock):
                                            self.processedTask(task, processedType: .finished)
                                            self.interactor?.approveViteTx(id: task.id, accountBlock: accountBlock)
                                            plog(level: .info, log: "[task] task: \(task.id) auto finished sign", tag: .bifrost)
                                            self.delaySetIsProcessingFalseAndProcessTaskIfHave()
                                        case .failure(let error):
                                            if self.retryMaybeRecover(error: error) {
                                                self.setTaskStatusWaitingForRetry(task)
                                                plog(level: .info, log: "[task] task: \(task.id) auto failed sign, then retry", tag: .bifrost)
                                                GCD.delay(1) { self.processTask(task) }
                                            } else {
                                                self.processedTask(task, processedType: .failed)
                                                plog(level: .info, log: "[task] task: \(task.id) auto failed sign, then failed", tag: .bifrost)
                                                self.delaySetIsProcessingFalseAndProcessTaskIfHave()
                                            }
                                            plog(level: .warning, log: "\(error.localizedDescription)", tag: .bifrost)
                                        }

                })
            case let .signMessage(signMessage):
                let response = self.signMessage(signMessage: signMessage)
                self.processedTask(task, processedType: .finished)
                self.interactor?.approveViteSignMessage(id: task.id, response: response)
                plog(level: .info, log: "[task] task: \(task.id) auto finished sign", tag: .bifrost)
                self.delaySetIsProcessingFalseAndProcessTaskIfHave()
            }

        } else {
            setTaskStatusProcessing(task)
            let vc = self.showBifrostViewController()
            vc.showConfirm(task: task)
        }
    }

    fileprivate func delaySetIsProcessingFalseAndProcessTaskIfHave() {
        GCD.delay(1) {
            self.isProcessing = false
            self.processTaskIfHave()
        }
    }

    fileprivate func processTaskIfHave() {
        guard status == .connected else { return }
        guard isProcessing == false else { return }
        guard let task = currentTask else { return }
        processTask(task)
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
                if UIViewController.current !== ret {
                    UIViewController.current?.navigationController?.popToViewController(e, animated: true)
                }
            } else {
                ret = BifrostHomeViewController(result: { [weak self] (ret, task, vc) in
                    guard let `self` = self else { return }
                    guard let account = HDWalletManager.instance.account else { return }
                    if ret {
                        plog(level: .info, log: "[task] task: \(task.id) manual start sign", tag: .bifrost)
                        switch task.type {
                        case let .sendTx(tx, tokenInfo):
                            Workflow.bifrostSendTx(needConfirm: true,
                                                   title: task.info.title,
                                                   account: account,
                                                   toAddress: tx.block.toAddress,
                                                   tokenId: tokenInfo.viteTokenId,
                                                   amount: tx.block.amount,
                                                   fee: tx.block.fee,
                                                   data: tx.block.data,
                                                   completion: { (ret) in
                                                    switch ret {
                                                    case .success(let accountBlock):
                                                        self.processedTask(task, processedType: .finished)
                                                        vc.hideConfirm()
                                                        self.interactor?.approveViteTx(id: task.id, accountBlock: accountBlock)
                                                        plog(level: .info, log: "[task] task: \(task.id) manual finished sign", tag: .bifrost)
                                                        self.delaySetIsProcessingFalseAndProcessTaskIfHave()
                                                    case .failure(let error):
                                                        plog(level: .info, log: "[task] task: \(task.id) manual failed sign, then manual retry", tag: .bifrost)
                                                        plog(level: .warning, log: "\(error.localizedDescription)", tag: .bifrost)
                                                    }
                            })
                        case let .signMessage(signMessage):
                            let response = self.signMessage(signMessage: signMessage)
                            self.processedTask(task, processedType: .finished)
                            vc.hideConfirm()
                            self.interactor?.approveViteSignMessage(id: task.id, response: response)
                            plog(level: .info, log: "[task] task: \(task.id) manual finished sign", tag: .bifrost)
                            self.delaySetIsProcessingFalseAndProcessTaskIfHave()
                        }
                    } else {
                        self.processedTask(task, processedType: .canceled)
                        vc.hideConfirm()
                        self.interactor?.cancelRequest(id: task.id).cauterize()
                        plog(level: .info, log: "[task] task: \(task.id) manual canceled sign", tag: .bifrost)
                        self.delaySetIsProcessingFalseAndProcessTaskIfHave()
                    }
                })
                UIViewController.current?.navigationController?.pushViewController(ret, animated: true)
            }
        }
        return ret
    }

    fileprivate func signMessage(signMessage: VBViteSignMessage) -> VBViteSignMessageResponse {
        let account = HDWalletManager.instance.account!
        let publicKey = Data(bytes: account.publicKey.hex2Bytes).base64EncodedString()
        let prefix = "Vite Signed Message:\n".data(using: .utf8)!
        let source = (prefix + signMessage.message).bytes
        let hash = Blake2b.hash(outLength: 32, in: source) ?? Bytes()
        let signature = Data(bytes: account.sign(hash: hash)).base64EncodedString()
        let response = VBViteSignMessageResponse(publicKey: publicKey, signature: signature)
        return response
    }

    fileprivate func approveFailed(message: String?) {
        let scanViewController: ScanViewController?
        if let vc = UIViewController.current as? ScanViewController {
            scanViewController = vc
        } else {
            scanViewController = nil
        }

        self.clearTasks()
        interactor?.onSessionRequest = nil
        interactor?.killSession().done({ [weak self] _ in
            self?.interactor = nil
            scanViewController?.startCaptureSession()
        })

        HUD.hide()
        if let msg = message {
            Toast.show(msg)
        }

    }
}


extension BifrostManager {

    fileprivate func retryMaybeRecover(error: Error) -> Bool {
        if let e = error as? ViteError, e.code.type == .rpc {
            if e.code == ViteErrorCode.rpcRetryMaybeRecover ||
                e.code == ViteErrorCode.rpcNotEnoughQuota ||
                e.code == ViteErrorCode.rpcRefrenceSameSnapshootBlock ||
                e.code == ViteErrorCode.rpcRefrenceSnapshootBlockIllegal {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

    fileprivate func canAutoConfirm(task: BifrostViteSendTxTask) -> Bool {

        guard case let .sendTx(tx, _) = task.type else {
            return false
        }

        guard let data = tx.block.data, data.count >= 4 else {
            return false
        }
        guard let toAddress = tx.block.toAddress else {
            return false
        }
        let toAddressAndDataPrefix = "\(toAddress).\(data[0..<4].toHexString())"
        if let (type, values) = ABI.BuildIn.type(data: tx.block.data, toAddress: toAddress) , type == .dexPlaceOrder {
            guard let tradeTokenIdValue = values[0] as? ABITokenIdValue,
                let quoteTokenIdValue = values[1] as? ABITokenIdValue else {
                    return false
            }
            let pairStr = tradeTokenIdValue.toString() + "/" + quoteTokenIdValue.toString()
            let allowMarkets = BifrostManager.AutoSigInfo.dexPostContractPairs
            if allowMarkets.contains(pairStr) {
                 return true
            }  else {
                return false
            }
        } else if BifrostManager.AutoSigInfo.contract.contains(toAddressAndDataPrefix) {
            return true
        } else {
            return false
        }
    }
}

extension BifrostManager {
    static func fetchAutoSigConfig() {
        Alamofire
            .request(ViteConst.instance.cos.strapi + "/vcconfigs/1")
            .responseJSON()
            .done { (json, resp) in
                if let dexPostContractPairs = JSON(json)["data"]["dexPostContractPairs"].arrayObject as? [String] {
                    AutoSigInfo.netconfig_dexPostContractPairs = dexPostContractPairs
                }
                if let contract = JSON(json)["data"]["contract"].arrayObject as? [String] {
                    AutoSigInfo.netconfig_contract = contract
                }
        }
        .catch { (error) in
            GCD.delay(8) {
                BifrostManager.fetchAutoSigConfig()
            }
        }

    }

    struct AutoSigInfo {

        static var contract: [String] {
            return netconfig_contract ?? localconfig_contract
        }
         static var dexPostContractPairs: [String] {
            return netconfig_dexPostContractPairs ?? localconfig_dexPostContractPairs
        }

        static var netconfig_contract: [String]?
        static var netconfig_dexPostContractPairs: [String]?

        static var localconfig_contract: [String] {
            return [
                "vite_0000000000000000000000000000000000000006e82b8ba657.319e46dd",
                "ViteWallet.ABI.BuildIn.dexDeposit",

                "vite_0000000000000000000000000000000000000006e82b8ba657.00365d82",
                "ViteWallet.ABI.BuildIn.dexWithdraw",

                "vite_0000000000000000000000000000000000000006e82b8ba657.21d811bc",
                "ViteWallet.ABI.BuildIn.dexStakeForVIP",

                "vite_0000000000000000000000000000000000000003f6af7459b9.d2fd352d",
                "ViteWallet.ABI.BuildIn.stakeForQuota",

                "vite_0000000000000000000000000000000000000003f6af7459b9.b7fb0919",
                "ViteWallet.ABI.BuildIn.cancelQuotaStaking",

                "vite_0000000000000000000000000000000000000003f6af7459b9.f19e3c6b",
                "ViteWallet.ABI.BuildIn.old_cancelStake",

                "vite_0000000000000000000000000000000000000006e82b8ba657.76db6cdd",
                "ViteWallet.ABI.BuildIn.dexStakeForMining",

                "vite_0000000000000000000000000000000000000004d28108e76b.42f2eee4",
                "ViteWallet.ABI.BuildIn.voteForSBP",

                "vite_0000000000000000000000000000000000000004d28108e76b.30b3f2ad",
                "ViteWallet.ABI.BuildIn.cancelSBPVoting",

                "vite_0000000000000000000000000000000000000006e82b8ba657.d8088efc",
                "ViteWallet.ABI.BuildIn.dexCreateInviteCode",

                "vite_0000000000000000000000000000000000000006e82b8ba657.f19ffbcb",
                "ViteWallet.ABI.BuildIn.dexBindInviteCode",

                "vite_00000000000000000000000000000000000000079710f19dc7.2205eb17",
                "ViteWallet.ABI.BuildIn.dexCancelOrder",

                "vite_0000000000000000000000000000000000000006e82b8ba657.0454f5ef",
                "ViteWallet.ABI.BuildIn.dexPlaceOrder",

                "vite_0000000000000000000000000000000000000006e82b8ba657.e7f03bc7",
                "ViteWallet.ABI.BuildIn.dexLockVxForDividend",

                "vite_0000000000000000000000000000000000000006e82b8ba657.4b8d9eae",
                "ViteWallet.ABI.BuildIn.dexCancelStakeById",
            ]
        }

        static var localconfig_dexPostContractPairs: [String] {
            let vite = ViteWalletConst.viteToken.id
           let btc = "tti_b90c9baffffc9dae58d1f33f"
           let pasc = "tti_22a818227bb47f072f92f428"
           let bis = "tti_e80bcafb642ce4898857eccc"
           let eth = "tti_687d8a93915393b219212c73"
           let vfc = "tti_18823e6e0b95b7d77b3a1b3a"
           let tera = "tti_60e20567a20282bfd25ab56c"
           let erg = "tti_661d467c3f4d9c6d7b9e9dc9"
           let grin = "tti_289ee0569c7d3d75eac1b100"
           let dero = "tti_26472d9be08f8f2fdeb3030d"
           let trtl = "tti_0570e763918b4355074661ac"
           let usdt = "tti_80f3751485e4e83456059473"
           let lrc = "tti_25e5f191cbb00a88a6267e0f"
           let vx = "tti_564954455820434f494e69b5"

            var allowMarkets = [
                   vite+"/"+btc,
                   pasc+"/"+btc,
                   bis+"/"+btc,
                   eth+"/"+btc,
                   vfc+"/"+btc,
                   tera+"/"+btc,
                   erg+"/"+btc,
                   grin+"/"+btc,
                   dero+"/"+btc,

                   vite+"/"+eth,
                   trtl+"/"+eth,
                   grin+"/"+eth,

                   bis+"/"+vite,
                   erg+"/"+vite,
                   trtl+"/"+vite,
                   grin+"/"+vite,
                   dero+"/"+vite,
                   pasc+"/"+vite,
                   tera+"/"+vite,

                   eth+"/"+usdt,
                   btc+"/"+usdt,
                   vite+"/"+usdt,
                   vfc+"/"+usdt,
                   lrc+"/"+usdt,
               ]
            allowMarkets.append(contentsOf: [
               "tti_564954455820434f494e69b5/tti_b90c9baffffc9dae58d1f33f",
                "tti_f7e187a151e9c74b81e87cce/tti_b90c9baffffc9dae58d1f33f",
                "tti_9b8b779b0ca5b55464e1cfda/tti_b90c9baffffc9dae58d1f33f",
                "tti_4a04203e28bb8f3dc3d8f9b1/tti_b90c9baffffc9dae58d1f33f",
                "tti_3d3bd4c43620ad1a3bcc630a/tti_b90c9baffffc9dae58d1f33f",
                "tti_c1968fde12be9bc60e56a055/tti_b90c9baffffc9dae58d1f33f",
                "tti_dfa872e9f0fccb1cc08502dd/tti_b90c9baffffc9dae58d1f33f",
                "tti_2f875c97d3a51b66a59c4411/tti_b90c9baffffc9dae58d1f33f",
                "tti_22a818227bb47f072f92f428/tti_687d8a93915393b219212c73",
                "tti_dfa872e9f0fccb1cc08502dd/tti_687d8a93915393b219212c73",
                "tti_564954455820434f494e69b5/tti_687d8a93915393b219212c73",
                "tti_c1968fde12be9bc60e56a055/tti_687d8a93915393b219212c73",
                "tti_564954455820434f494e69b5/tti_5649544520544f4b454e6e40",
                "tti_564954455820434f494e69b5/tti_80f3751485e4e83456059473",
                "tti_c8c9ad17bc7b45e38eb88a44/tti_80f3751485e4e83456059473",
                "tti_22a818227bb47f072f92f428/tti_80f3751485e4e83456059473",
                "tti_c1968fde12be9bc60e56a055/tti_80f3751485e4e83456059473",
                "tti_3d3bd4c43620ad1a3bcc630a/tti_80f3751485e4e83456059473",])

            return allowMarkets
        }
    }
}
