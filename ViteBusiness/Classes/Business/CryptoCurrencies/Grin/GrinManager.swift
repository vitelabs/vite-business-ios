//
//  GrinManager.swift
//  Action
//
//  Created by haoshenyang on 2019/3/13.
//

import UIKit
import Vite_GrinWallet
import ViteUtils

class GrinManager: GrinBridge {

    static let `default`: GrinManager =  {

        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(FileHelper.appPathComponent).appendingPathComponent("grin")
        let manager = GrinManager.init(walletUrl: url, chainType: .usernet, getPassword: {
            guard let encryptedKey = HDWalletManager.instance.encryptedKey else {
                fatalError()
            }
            return encryptedKey
        })

        HDWalletManager.instance.walletDriver.drive(onNext: { [unowned manager] (wallet) in
            if wallet != nil {
                manager.creatWalletIfNeeded()
            }
        })

        return manager
    }()

    func creatWalletIfNeeded()  {
        if !self.walletExists() {
//            let mnemonic = HDWalletManager.instance.mnemonic
            let mnemonic = "whip swim spike cousin dinosaur vacuum save few boring monster crush ocean brown suspect swamp zone bounce hard sadness bulk reform crack crack accuse"
            let result = self.walletRecovery(mnemonic)
            switch result {
            case .success(_):
                break
            case .failure(let error):
                break
            }
        }
    }
}
