//
//  GrinManager.swift
//  Action
//
//  Created by haoshenyang on 2019/3/13.
//

import UIKit
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

    lazy var balanceDriver: Driver<GrinBalance> = self.balance.asDriver()
    private let balance = BehaviorRelay<GrinBalance>(value: GrinBalance())

    private var receivedSlateUrl: URL?

    var failed = [String]()
    var isHandleingSavedTx = false

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
        self.getBalance()
        self.handleSavedTx()
    }

    func creatWalletIfNeeded()  {
        self.checkDirectories()
        self.checkApiSecret()
        defer { self.getBalance() }
        if !self.walletExists() {
            guard let mnemonic = HDWalletManager.instance.mnemonic else { return }
            let result = self.walletRecovery(mnemonic)
            switch result {
            case .success(_):
                Toast.show("creat grin creat wallet success")
            case .failure(let error):
                plog(level: .error, log: "grin:" + error.message)
                Toast.show("creat grin wallet failed, please reimport the mnemonic. error: \(error.message)")
            }
        }
    }

    func getBalance() {
        let result = self.walletInfo(refreshFromNode: true)
        switch result {
        case .success(let info):
            self.balance.accept(GrinBalance(info))
        case .failure(let error):
            break
        }
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
            if url.path.components(separatedBy: ".").last == "response" {
                vc.type = .finalize
            } else {
                vc.type = .receive
            }
            let topVC = Route.getTopVC()
            if let nav = topVC?.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                topVC?.present(vc, animated: true, completion: nil)
            }
            self.receivedSlateUrl = nil
        }
    }
}

extension GrinManager {
    var relativePath: String { return "viteTxData" }

    func handle(viteData: Data, fromAddress: String)  {
        guard let fileName = String.init(data: viteData, encoding: .utf8) else {
            return
        }
        let record = "\(fileName),\(fromAddress)"
        var records = [String]()
        if let data = fileHelper.contentsAtRelativePath(relativePath),
            let savedRecords = (try? JSON.init(data: data))?.arrayObject as? [String] {
            records = savedRecords
            while records.count >= 10 {
                records.removeFirst()
            }
        }
        records.append(record)
        do {
            let data = try JSON(records).rawData()
            self.fileHelper.writeData(data, relativePath: self.relativePath)
        } catch {

        }
        handleSavedTx()
    }

    func handleSavedTx() {
        if isHandleingSavedTx { return }
        isHandleingSavedTx = true

        guard let data = fileHelper.contentsAtRelativePath(relativePath),
            let savedRecords = (try? JSON.init(data: data))?.arrayObject as? [String] else {
                isHandleingSavedTx = false
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
                isHandleingSavedTx = false
                return
        }

        GrinTxByViteService.init().handle(fileName: fileName, fromAddress: address)
            .done {
                guard let data = self.fileHelper.contentsAtRelativePath(self.relativePath),
                    var savedRecords = (try? JSON.init(data: data))?.arrayObject as? [String],
                    let index = savedRecords.lastIndex(of: last) else {
                        return
                }
                savedRecords.remove(at: index)
                do {
                    let newData = try JSON(savedRecords).rawData()
                    self.fileHelper.writeData(newData, relativePath: self.relativePath)
                } catch {

                }
            }
            .catch { _ in
                self.failed.append(last)
            }
            .finally {
                self.isHandleingSavedTx = false
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
                      name: "GRIN",
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



func async<T>(_ a: @escaping ()-> T,
              _ b: @escaping (T) -> (),
              qa: DispatchQueue = DispatchQueue.global(),
              qb: DispatchQueue = DispatchQueue.main) {
    qa.async {
        let v = a()
        qb.async {
            b(v)
        }
    }
}
