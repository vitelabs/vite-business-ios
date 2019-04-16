//
//  GrinManager.swift
//  Action
//
//  Created by haoshenyang on 2019/3/13.
//

import UIKit
import ViteWallet
import Vite_GrinWallet
import SwiftyJSON
import RxSwift
import RxCocoa

private func grinFileHelper() -> FileHelper {
    return FileHelper(.library, appending: FileHelper.walletPathComponent + "/grin" + GrinManager.getChainType().rawValue)
}

class GrinManager: GrinBridge {

    static let `default` = GrinManager()
    private let bag = DisposeBag()
    fileprivate var fileHelper = grinFileHelper()
    static let queue = DispatchQueue(label: "net.vite.grin")

    lazy var balanceDriver: Driver<GrinBalance> = self.balance.asDriver()
    private let balance = BehaviorRelay<GrinBalance>(value: GrinBalance())

    let walletCreated = BehaviorRelay<Bool>(value: false)

    private var receivedSlateUrl: URL?
    var failed = [String]()
    var isHandlingSavedTx = false

    private convenience init() {
        self.init(chainType: GrinManager.getChainType(), walletUrl: GrinManager.getWalletUrl(), password: GrinManager.getPassword())

        HDWalletManager.instance.walletDriver
            .filterNil()
            .map { $0.uuid }
            .distinctUntilChanged()
            .drive(onNext: { [weak self] (_) in
                self?.configGrinWallet()
            })
            .disposed(by: self.bag)

        #if DEBUG || TEST
        NotificationCenter.default.rx.notification(.appEnvironmentDidChange)
            .bind { [weak self] (n) in
                self?.configGrinWallet()
            }
            .disposed(by: self.bag)
        #endif

        Observable<Int>.interval(30, scheduler: MainScheduler.asyncInstance)
            .bind{ [weak self] _ in self?.getBalance()}
            .disposed(by: self.bag)

        NotificationCenter.default.rx.notification(NSNotification.Name.homePageDidAppear)
            .bind { [weak self] n in
                self?.gotoSlateVCIfNeed()
                self?.getBalance()
            }
            .disposed(by: self.bag)
    }


    func configGrinWallet() {
        self.fileHelper = grinFileHelper()
        self.password =  GrinManager.getPassword()
        self.walletUrl = GrinManager.getWalletUrl()
        #if DEBUG || TEST
        switch DebugService.instance.config.appEnvironment {
        case .online, .stage:
            self.checkNodeApiHttpAddr = "https://grin.vite.net/fullnode"
            self.apiSecret = "Pbwnf9nJDEVcVPR8B42u"
            self.chainType = GrinChainType.mainnet.rawValue
            break
        case .test, .custom:
            self.checkNodeApiHttpAddr = "http://45.40.197.46:23413"
            self.apiSecret = "Hpd670q3Bar0h8V1f2Z6"
            self.chainType = GrinChainType.usernet.rawValue
        }
        #else
        self.checkNodeApiHttpAddr = "https://grin.vite.net/fullnode"
        self.apiSecret = "Pbwnf9nJDEVcVPR8B42u"
        self.chainType = GrinChainType.mainnet.rawValue
        #endif
        self.creatWalletIfNeeded()
        GrinTxByViteService().reportViteAddress().done {_ in}
        self.balance.accept(GrinBalance())
        self.handleSavedTx()
    }

    func creatWalletIfNeeded()  {
        self.checkDirectories()
        self.checkApiSecret()
        guard !self.walletExists() else {
            self.walletCreated.accept(true)
            return
        }
        self.walletCreated.accept(false)
        guard let mnemonic = HDWalletManager.instance.mnemonic else { return }
        grin_async({ ()  in
            self.walletRecovery(mnemonic)
        },  { (result) in
            switch result {
            case .success(_):
                self.getBalance()
            case .failure(let error):
                Toast.show("error: \(error.message)")
                plog(level: .error, log: "grin:" + error.message)
            }
            if self.walletExists() {
                self.walletCreated.accept(true)
            }
        })
    }

    func getBalance() {
        guard self.walletCreated.value else { return }
        grin_async({ () in
            self.walletInfo(refreshFromNode: true)
        },  { (result) in
            switch result {
            case .success(let info):
                self.balance.accept(GrinBalance(info))
            case .failure(let error):
                break
            }
        })
    }
}

extension GrinManager {
    func handle(url: URL) {
        self.receivedSlateUrl = url
        gotoSlateVCIfNeed()
    }

    func gotoSlateVCIfNeed() {
        guard HDWalletManager.instance.wallet != nil,
            !HDWalletManager.instance.locked,
            let url = self.receivedSlateUrl,
            let data = JSON(FileManager.default.contents(atPath: url.path)).rawValue as? [String: Any],
            let slate = Slate(JSON:data) else {
                return
        }
        DispatchQueue.main.async {
            let vc = SlateViewController(nibName: "SlateViewController", bundle: businessBundle())
            vc.opendSlateUrl = url
            vc.opendSlate = slate
            if  url.path.contains("response") {
                vc.type = .finalize
            } else {
                vc.type = .receive
            }
            var topVC = Route.getTopVC()
            if let nav = topVC?.navigationController {
                nav.pushViewController(vc, animated: true)
            } else if let rootnav = (topVC?.presentingViewController as? UITabBarController)?.selectedViewController as? UINavigationController {
                rootnav.pushViewController(vc, animated: true)
            } else {
                topVC?.present(vc, animated: true, completion: nil)
            }
            self.receivedSlateUrl = nil
        }
    }
}

extension GrinManager {
    var relativePath: String { return "viteTxData" }

    func handle(viteData: Data, fromAddress: String, account: Wallet.Account)  {
        plog(level: .info, log: "grin-0-handle(viteData,fromAddress:\(fromAddress)", tag: .grin)
        guard let fileName = String.init(data: viteData, encoding: .utf8) else {
            plog(level: .info, log: "grin-1-receiveFname.fname:failed", tag: .grin)
            return
        }
        plog(level: .info, log: "grin-1-receiveFname.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
        let record = "\(fileName),\(fromAddress)"
        var records = [String]()
        if let data = fileHelper.contentsAtRelativePath(relativePath),
            let savedRecords = (try? JSON.init(data: data))?.arrayObject as? [String] {
            records = savedRecords
            while records.count >= 10 {
                records.removeFirst()
            }
            plog(level: .info, log: "grin-2-readTxs.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
        }
        records.append(record)
        do {
            let data = try JSON(records).rawData()
            self.fileHelper.writeData(data, relativePath: self.relativePath)
            plog(level: .info, log: "grin-3-saveTxs.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
        } catch {
            plog(level: .info, log: "grin-3-saveTxsFailed.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
        }
        handleSavedTx()
    }

    func handleSavedTx() {
        if isHandlingSavedTx {
            plog(level: .info, log: "grin-4-starthandleSavedTx-isHandleingSavedTx", tag: .grin)
            return
        }
        isHandlingSavedTx = true
        plog(level: .info, log: "grin-4-starthandleSavedTx", tag: .grin)

        guard let data = fileHelper.contentsAtRelativePath(relativePath),
            let savedRecords = (try? JSON.init(data: data))?.arrayObject as? [String] else {
                isHandlingSavedTx = false
                plog(level: .info, log: "grin-4-readSaveTxsFailed.", tag: .grin)
                return
        }

        var lastItem: String? = nil
        for item in savedRecords.reversed() where failed.lastIndex(of: item) == nil {
            lastItem = item
            break
        }
        guard let last = lastItem,
            let fileName = last.components(separatedBy: ",").first,
            let address = last.components(separatedBy: ",").last else {
                isHandlingSavedTx = false
                plog(level: .info, log: "grin-4-paresSavedTxsFailed", tag: .grin)
                return
        }

        plog(level: .info, log: "grin-4-GrinTxByViteServiceHandle.fname:\(fileName),fromAddress:\(address)", tag: .grin)

        GrinTxByViteService.init().handle(fileName: fileName, fromAddress: address)
            .done {
                plog(level: .info, log: "grin-10-GrinTxByViteServiceSuccess.fname:\(fileName),fromAddress:\(address)", tag: .grin)
                guard let data = self.fileHelper.contentsAtRelativePath(self.relativePath),
                    var savedRecords = (try? JSON.init(data: data))?.arrayObject as? [String],
                    let index = savedRecords.lastIndex(of: last) else {
                        plog(level: .info, log: "grin-10-readSaveTxsFailed.fname:\(fileName),fromAddress:\(address)", tag: .grin)
                        return
                }
                savedRecords.remove(at: index)
                do {
                    let newData = try JSON(savedRecords).rawData()
                    self.fileHelper.writeData(newData, relativePath: self.relativePath)
                } catch {
                    plog(level: .info, log: "grin-10-SaveTxsFailed.fname:\(fileName),fromAddress:\(address)", tag: .grin)
                }
            }
            .catch { error in
                plog(level: .info, log: "grin-10-GrinTxByViteServiceFailed.fname:\(fileName),fromAddress:\(address),error:\(error)", tag: .grin)
                self.failed.append(last)
            }
            .finally {
                self.isHandlingSavedTx = false
                self.handleSavedTx()
                plog(level: .info, log: "grin-11-GrinTxByViteServiceFinally.fname:\(fileName),fromAddress:\(address)", tag: .grin)

        }
    }
}

extension GrinManager {
    private var finalizedTxsPath: String  { return "finalizedTxs/finalizedTxs"}

    func finalizedTxs() -> [String] {
        if let data = fileHelper.contentsAtRelativePath(finalizedTxsPath),
            let finalizedTxs = (try? JSON.init(data: data))?.arrayObject as? [String] {
            return finalizedTxs
        }
        return []
    }

    func setFinalizedTx(_ slateId: String) {
        var finalizedTxs = self.finalizedTxs()
        finalizedTxs.append(slateId)
        if let data = try? JSON(finalizedTxs).rawData() {
            fileHelper.writeData(data, relativePath: finalizedTxsPath)
        }
    }
}

extension GrinManager {
    static func getChainType() -> GrinChainType {
        #if DEBUG || TEST
        switch DebugService.instance.config.appEnvironment {
        case .online, .stage:
            return .mainnet
        case .test, .custom:
            return .usernet
        }
        #else
        return .mainnet
        #endif
    }

    static func getWalletUrl() -> URL {
        let chainType = self.getChainType()
        let fileHelper = grinFileHelper()
        var url = URL.init(fileURLWithPath: fileHelper.rootPath)
        return url
    }

    static var tokenInfo: TokenInfo {
        return MyTokenInfosService.instance.tokenInfo(for: .grinCoin) ??
            TokenInfo(tokenCode: .grinCoin,
                      coinType: .grin,
                      name: "grin",
                      symbol: "GRIN",
                      decimals: 9,
                      icon: "https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon/645fc653c016c2fa55d2683bc49b8803.png",
                      id: "GRIN")
    }

    fileprivate static func getPassword() -> String {
        guard let encryptedKey = HDWalletManager.instance.encryptedKey else {
            return ""
        }
        return encryptedKey
    }
}

func withInMainThread(_ a: @escaping () ->  ()) {
    if Thread.isMainThread {
        a()
    } else {
        DispatchQueue.main.async {
            a()
        }
    }
}

func grin_async<T>(_ a: @escaping ()-> T,
              _ b: @escaping (T) -> (),
              qa: DispatchQueue = GrinManager.queue,
              qb: DispatchQueue = DispatchQueue.main) {
    qa.async {
        let v = a()
        qb.async {
            b(v)
        }
    }
}
