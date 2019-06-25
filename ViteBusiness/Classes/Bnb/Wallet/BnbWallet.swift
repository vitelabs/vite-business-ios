//
//  BnbWallet.swift
//  Vite
//
//  Created by Water on 2018/12/20.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import BinanceChain

public class BnbWallet {
    public static let shared = BnbWallet()
    var test: Test?
    let binance = BinanceChain()
    var wallet : Wallet? = nil
    var fromAddress : String? = nil

    public func loginWallet(_ mnemonic:String) {
        self.wallet = Wallet(mnemonic: mnemonic,endpoint: .mainnet)

        // Access keys
        let privateKey = wallet!.privateKey
        let publicKey = wallet!.publicKey
        let account = wallet!.account
        self.fromAddress = wallet!.account
    }

    public func logoutWallet() {
        self.wallet = nil
        self.fromAddress = nil
    }


    private init() {




        // Run tests
        self.test = Test()
        self.test?.runTestsOnTestnet(.allMinimised)

        // Get the latest block time and current time
        binance.time() { (response) in
            if let error = response.error { return print(error) }
            print(response.time)
        }

        // Get node information
        binance.nodeInfo() { (response) in
            print(response.nodeInfo)
        }

        // Get the list of validators used in consensus
        binance.validators() { (response) in
            print(response.validators)
        }

        // Get the list of network peers
        binance.peers() { (response) in
            print(response.peers)
        }

    }
}

