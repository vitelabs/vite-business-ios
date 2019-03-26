//
//  GrinManager.swift
//  Action
//
//  Created by haoshenyang on 2019/3/13.
//

import UIKit
import Vite_GrinWallet
import ViteUtils
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
    return FileHelper(.library, appending: FileHelper.walletPathComponent + "/grin")
}

class GrinManager: GrinBridge {


    static let `default` = GrinManager()
    private let bag = DisposeBag()
    fileprivate var fileHelper = grinFileHelper()

    lazy var balanceDriver: Driver<GrinBalance> = self.balance.asDriver()
    private let balance = BehaviorRelay<GrinBalance>(value: GrinBalance())

    private var receivedSlateUrl: URL?

    private convenience init() {
        self.init(chainType: GrinManager.getChainType(), walletUrl: GrinManager.getWalletUrl(), password: GrinManager.getPassword())

        HDWalletManager.instance.walletDriver
            .filterNil()
            .map { $0.uuid }
            .distinctUntilChanged()
            .drive(onNext: { [weak self] (_) in
                self?.password =  GrinManager.getPassword()
                self?.walletUrl =  GrinManager.getWalletUrl()
                self?.creatWalletIfNeeded()
                self?.getBalance()
            })
            .disposed(by: self.bag)

        Observable<Int>.interval(30, scheduler: MainScheduler.asyncInstance)
            .bind{ [weak self] _ in self?.getBalance()}
            .disposed(by: self.bag)
        getBalance()

        NotificationCenter.default.rx.notification(NSNotification.Name.homePageDidAppear)
            .bind { [weak self] n in
                self?.gotoSlateVCIfNeed()
            }
            .disposed(by: self.bag)
    }

    static func getChainType() -> GrinChainType {
        #if DEBUG
            return .usernet
        #elseif TEST
            return .floonet
        #else
            return .usernet
        #endif
    }

    static func getWalletUrl() -> URL {
        let chainType = self.getChainType()
        let fileHelper = grinFileHelper()
        var url = URL.init(fileURLWithPath: fileHelper.rootPath)
        url.appendPathComponent(chainType.rawValue)
        return url
    }

    private static func getPassword() -> String {
        guard let encryptedKey = HDWalletManager.instance.encryptedKey else {
            return ""
        }
        return encryptedKey
    }

    static var tokenInfo: TokenInfo {
        return MyTokenInfosService.instance.tokenInfo(for: .grinCoin) ??
        TokenInfo(tokenCode: .grinCoin,
                  coinType: .grin,
                  name: "Grin",
                  symbol: "Grin",
                  decimals: 9,
                  icon: "https://static.aicoinstorge.com/attachment/article/20181206/1544125293262.jpg",
                  id: "Grin")

    }

    func creatWalletIfNeeded()  {
        if !self.walletExists() {
            guard let mnemonic = HDWalletManager.instance.mnemonic else { return } 
//            let mnemonic = "whip swim spike cousin dinosaur vacuum save few boring monster crush ocean brown suspect swamp zone bounce hard sadness bulk reform crack crack accuse"
            let result = self.walletRecovery(mnemonic)
            switch result {
            case .success(_):
                checkDirectories()
                checkApiSecret()
            case .failure(let error):
                break
            }
        }
    }

    private let finalizedTxsPath = "finalizedTxs/finalizedTxs"

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

    private func getBalance() {
        let result = self.walletInfo(refreshFromNode: true)
        switch result {
        case .success(let info):
            self.balance.accept(GrinBalance(info))
        case .failure(let error):
            break
        }
    }


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
