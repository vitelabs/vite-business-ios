//
//  ReceiveViteViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/7.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import ViteWallet

class ReceiveViteViewModel: ReceiveViewModelType {

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
        return Driver.combineLatest(
            self.amountStringBehaviorRelay.asDriver(),
            self.noteStringBehaviorRelay.asDriver())
            .map({ [weak self] (amount, note) -> String in
                guard let `self` = self else { return "" }
                return ViteURI.transferURI(address: Address(string: self.address),
                                           tokenId: self.token.id, amount: amount, note: note).string()
            })
    }

    let amountStringBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let noteStringBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    private var tipStringBehaviorRelay: BehaviorRelay<String>
    private var uriStringBehaviorRelay: BehaviorRelay<String>

    let isShowNoteView = true

    private let token: Token
    init(tokenInfo: TokenInfo) {
        self.token = tokenInfo.toViteToken()!

        self.address = HDWalletManager.instance.account?.address.description ?? ""
        self.addressName = AddressManageService.instance.name(for: Address(string: self.address))

        self.tipStringBehaviorRelay = BehaviorRelay(value: R.string.localizable.receivePageTokenNameLabel(token.symbol))
        self.uriStringBehaviorRelay = BehaviorRelay(value: ViteURI.transferURI(address: Address(string: address), tokenId: token.id, amount: nil, note: nil).string())
    }

}
