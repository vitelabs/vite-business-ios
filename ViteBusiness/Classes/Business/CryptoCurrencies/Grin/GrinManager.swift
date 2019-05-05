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

        HDWalletManager.instance.accountDriver
            .filterNil()
            .distinctUntilChanged({ (a0, a1) -> Bool in
                a0.address.description == a1.address.description
            })
            .drive(onNext: { _ in
                GrinTxByViteService().reportViteAddress().done {_ in}
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

        FMDatabase()

    }


    func configGrinWallet() {
        self.fileHelper = grinFileHelper()
        self.password =  GrinManager.getPassword()
        self.walletUrl = GrinManager.getWalletUrl()
        #if DEBUG || TEST
        print("grinwalletpath:\(self.walletUrl.path)")
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
        self.balance.accept(GrinBalance())
        DispatchQueue.main.async {
            GrinLocalInfoService.share.creatDBIfNeeded()
            self.handleSavedTx()
        }
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
                plog(level: .info, log: "wallet recover failed:" + error.message, tag: .grin)
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
        plog(level: .info, log: "grin-0-handleviteData-fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
        guard let fileName = String.init(data: viteData, encoding: .utf8) else {
            plog(level: .info, log: "grin-1-paresreceiveFnamefnamefailed-fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
            return
        }
        plog(level: .info, log: "grin-1-receiveFname.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
        let accountAddress = account.address.description
        let record = fileName + "," + accountAddress + "," + fromAddress
        var records = [String]()
        if let data = fileHelper.contentsAtRelativePath(relativePath),
            let savedRecords = (try? JSON.init(data: data))?.arrayObject as? [String] {
            records = savedRecords
            while records.count >= 10 {
                records.removeFirst()
            }
            plog(level: .info, log: "grin-2-readTxs.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(accountAddress)", tag: .grin)
        }
        records.append(record)
        do {
            let data = try JSON(records).rawData()
            self.fileHelper.writeData(data, relativePath: self.relativePath)
            plog(level: .info, log: "grin-3-saveTxs.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(accountAddress),", tag: .grin)
        } catch {
            plog(level: .info, log: "grin-3-saveTxsFailed.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(accountAddress),", tag: .grin)
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
        guard let last = lastItem else {
            isHandlingSavedTx = false
            plog(level: .info, log: "grin-4-paresSavedTxs-no last item", tag: .grin)
            return
        }

        let detail = last.components(separatedBy: ",")
        guard let fileName = detail.first else {
            isHandlingSavedTx = false
            plog(level: .info, log: "grin-4-paresSavedTxs-getfnameFailed,lastItem:\(last)", tag: .grin)
            failed.append(last)
            handleSavedTx()
            return
        }
        guard let fromAddress = detail.last else {
            isHandlingSavedTx = false
            plog(level: .info, log: "grin-4-paresSavedTxsFailed-getFromAddressFailed,lastItem:\(last)", tag: .grin)
            failed.append(last)
            handleSavedTx()
            return
        }

        var account: Wallet.Account?
        if detail.count == 3 {
            let accountAddress = detail[1]
             account = HDWalletManager.instance.accounts.filter { (a) -> Bool in
                a.address.description == accountAddress
            }.first
        }

        if account == nil {
            plog(level: .info, log: "grin-4-getAccountFailed,lastItem:\(last)", tag: .grin)
            account = HDWalletManager.instance.accounts.first
        }
        
        guard let a = account else {
            plog(level: .info, log: "grin-4-getFirstAccountFailed,lastItem:\(last)", tag: .grin)
            failed.append(last)
            handleSavedTx()
            return
        }

        plog(level: .info, log: "grin-4-GrinTxByViteServiceHandle.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(a.address.description)", tag: .grin)

        GrinTxByViteService.init().handle(fileName: fileName, fromAddress: fromAddress, account: a)
            .done {
                plog(level: .info, log: "grin-10-GrinTxByViteServiceSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(a.address.description)", tag: .grin)
                guard let data = self.fileHelper.contentsAtRelativePath(self.relativePath),
                    var savedRecords = (try? JSON.init(data: data))?.arrayObject as? [String]else {
                        plog(level: .info, log: "grin-10-readSaveTxsFailed.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(a.address.description)", tag: .grin)
                        return
                }

                if let index = savedRecords.lastIndex(of: last) {
                    savedRecords.remove(at: index)
                    plog(level: .info, log: "grin-10-removeHandledInfo:\(fileName),fromAddress:\(fromAddress),accountAddress:\(a.address.description)", tag: .grin)
                }

                let isResponse = fileName.contains("response")
                if !isResponse {
                    GrinManager.default.remove_handleSendFileSuccess_createdResponeseFilePath(fileName: fileName)
                }

                do {
                    let newData = try JSON(savedRecords).rawData()
                    self.fileHelper.writeData(newData, relativePath: self.relativePath)
                    plog(level: .info, log: "grin-10-SaveTxsSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(a.address.description)", tag: .grin)
                } catch {
                    plog(level: .info, log: "grin-10-SaveTxsFailed.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(a.address.description)", tag: .grin)
                }
            }
            .catch { error in
                plog(level: .info, log: "grin-10-GrinTxByViteServiceFailed.fname:\(fileName),fromAddress:\(fromAddress),error:\(error),accountAddress:\(a.address.description)", tag: .grin)
                self.failed.append(last)
            }
            .finally {
                plog(level: .info, log: "grin-11-GrinTxByViteServiceFinally.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(a.address.description)", tag: .grin)
                self.isHandlingSavedTx = false
                self.handleSavedTx()
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

    var handleSendFileSuccess_createdResponeseFile_Path: String {
        return "handleSendFileSuccessCreatedResponeseFile/handleSendFileSuccessCreatedResponeseFile"
    }

    func handleSendFileSuccess_createdResponeseFilePathInfos() -> [String: String] {
        if let data = fileHelper.contentsAtRelativePath(handleSendFileSuccess_createdResponeseFile_Path),
            let json = try? JSON.init(data: data),
            let dict = json.dictionaryObject as? [String: String] {
            return dict
        } else {
            return [String: String]()
        }
    }

    func get_handleSendFileSuccess_createdResponeseFilePath(fileName: String) -> String? {
        let infos = handleSendFileSuccess_createdResponeseFilePathInfos()
        if let slateId = infos[fileName] {
            let url = getSlateUrl(slateId: slateId, isResponse: true)
            return url.path
        }
        return nil
    }

    func set_handleSendFileSuccess_createdResponeseFile(fileName: String, slateId: String) {
        var infos = handleSendFileSuccess_createdResponeseFilePathInfos()
        infos[fileName] = slateId
        if let data = try? JSON(infos).rawData() {
            fileHelper.writeData(data, relativePath: handleSendFileSuccess_createdResponeseFile_Path)
        }
    }

    func remove_handleSendFileSuccess_createdResponeseFilePath(fileName: String) {
        var infos = handleSendFileSuccess_createdResponeseFilePathInfos()
        infos[fileName] = nil
        if let data = try? JSON(infos).rawData() {
            fileHelper.writeData(data, relativePath: handleSendFileSuccess_createdResponeseFile_Path)
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
