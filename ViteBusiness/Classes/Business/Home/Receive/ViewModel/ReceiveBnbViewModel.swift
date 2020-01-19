//
//  ReceiveBnbViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/7.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import ViteWallet
import web3swift
import BinanceChain

class ReceiveBnbViewModel: ReceiveViewModelType {

    let addressName: String?
    let address: String

    var tipStringDriver: Driver<String> {
        return self.amountStringBehaviorRelay.asDriver().map({ [weak self] (amountString) -> String in
            guard let `self` = self else { return "" }
            if let amountString = amountString {
                return R.string.localizable.receivePageTokenNameLabel("\(amountString) \(self.tokenInfo.symbol)")
            } else {
                return R.string.localizable.receivePageTokenNameLabel(self.tokenInfo.symbol)
            }
        })
    }

    var uriStringDriver: Driver<String> {
        return self.amountStringBehaviorRelay.asDriver()
            .map({ [weak self] a -> String in
                guard let `self` = self else { return "" }

                let amount: String?
                if let a = a {
                    if a.isEmpty || a == "0" {
                        amount = nil
                    } else {
                        amount = a
                    }
                } else {
                    amount = nil
                }

                return BnbURI(address: self.address, amount: a, bnbSymbol: self.tokenInfo.id).string()
            })
    }

    let amountStringBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let noteStringBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    private var tipStringBehaviorRelay: BehaviorRelay<String>
    private var uriStringBehaviorRelay: BehaviorRelay<String>

    let isShowNoteView = false

    private let tokenInfo: TokenInfo
    init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo

        self.address = HDWalletManager.instance.bnbAddress ?? ""
        self.addressName = nil

        self.tipStringBehaviorRelay = BehaviorRelay(value: R.string.localizable.receivePageTokenNameLabel(tokenInfo.symbol))
        self.uriStringBehaviorRelay = BehaviorRelay(value: BnbURI(address: self.address, amount: nil, bnbSymbol: tokenInfo.id).string())
    }

}
