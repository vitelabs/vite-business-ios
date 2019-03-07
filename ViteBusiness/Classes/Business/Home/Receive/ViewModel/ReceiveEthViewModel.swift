//
//  ReceiveEthViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/7.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import ViteWallet

class ReceiveEthViewModel: ReceiveViewModelType {

    let addressName: String?
    let address: String

    var tipStringDriver: Driver<String> {
        return self.amountStringBehaviorRelay.asDriver().map({ [weak self] (amountString) -> String in
            guard let `self` = self else { return "" }
            if let amountString = amountString {
                return "\(amountString) \(self.token.symbol)"
            } else {
                return R.string.localizable.receivePageTokenNameLabel(self.token.symbol)
            }
        })
    }

    var uriStringDriver: Driver<String> {
        return self.amountStringBehaviorRelay.asDriver()
            .map({ [weak self] amount -> String in
                guard let `self` = self else { return "" }
                return ETHURI.transferURI(address: self.address, contractAddress: self.token.contractAddress, decimal: self.token.decimals, amount: amount).string()
            })
    }

    let amountStringBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let noteStringBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    private var tipStringBehaviorRelay: BehaviorRelay<String>
    private var uriStringBehaviorRelay: BehaviorRelay<String>

    let isShowNoteView = false

    private let token: ETHToken
    init(tokenInfo: TokenInfo) {
        self.token = tokenInfo.toETHToken()!

        self.address = HDWalletManager.instance.ethAddress ?? ""
        self.addressName = nil

        self.tipStringBehaviorRelay = BehaviorRelay(value: R.string.localizable.receivePageTokenNameLabel(token.symbol))
        self.uriStringBehaviorRelay = BehaviorRelay(value: ETHURI.transferURI(address: address, contractAddress: token.contractAddress, decimal: token.decimals, amount: nil).string())
    }

}
