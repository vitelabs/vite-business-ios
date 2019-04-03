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
                self?.fileHelper = grinFileHelper()
                self?.password =  GrinManager.getPassword()
                self?.walletUrl =  GrinManager.getWalletUrl()
                self?.balance.accept(GrinBalance())
                self?.creatWalletIfNeeded()
                GrinTxByViteService().reportViteAddress().done {_ in}
                self?.handleSavedTx()
            })
            .disposed(by: self.bag)

        Observable<Int>.interval(45, scheduler: MainScheduler.asyncInstance)
            .bind{ [weak self] _ in self?.getBalance()}
            .disposed(by: self.bag)

        NotificationCenter.default.rx.notification(NSNotification.Name.homePageDidAppear)
            .bind { [weak self] n in
                self?.gotoSlateVCIfNeed()
            }
            .disposed(by: self.bag)
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
                break
            case .failure(let error):
                plog(level: .error, log: "grin:" + error.message)
                //Toast.show("grin:" + error.message)
                break
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
        #if DEBUG
        return .usernet
        #elseif TEST
        return .usernet
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
