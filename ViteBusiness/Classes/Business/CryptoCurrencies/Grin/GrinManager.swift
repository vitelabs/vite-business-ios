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
        self.init(chainType: .usernet, walletUrl: GrinManager.getWalletUrl(), password: GrinManager.getPassword())

        let a = self.txStrategies(amount: 1)
        print(a)


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

            NotificationCenter.default.rx.notification(NSNotification.Name.homePageDidAppear)
                .bind { [weak self] n in
                    self?.gotoSlateVCIfNeed()
                }
                .disposed(by: self.bag)

    }

    static func getWalletUrl() -> URL {
        let fileHelper = grinFileHelper()
        let url = URL.init(fileURLWithPath: fileHelper.rootPath)
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
                  icon: "https://s2.coinmarketcap.com/static/img/coins/64x64/2937.png",
                  id: "Grin")

    }

    func creatWalletIfNeeded()  {
        if !self.walletExists() {
//            let mnemonic = HDWalletManager.instance.mnemonic
            let mnemonic = "whip swim spike cousin dinosaur vacuum save few boring monster crush ocean brown suspect swamp zone bounce hard sadness bulk reform crack crack accuse"
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
        let a = "file:///private/var/mobile/Containers/Data/Application/42A9AC2E-02F4-443B-8D56-6F14CF23AA11/tmp/net.vite.wallet.ep-Inbox/00117c3a-6c7c-44c3-8ae1-2080e4f5e02d.grinslate"
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
