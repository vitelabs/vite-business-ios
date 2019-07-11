//
//  TokenListSearchViewModel.swift
//  ViteBusiness
//
//  Created by Water on 2019/3/11.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import Moya

final class TokenListSearchViewModel {
    lazy var tokenListSearchDriver = self.tokenListSearchRelay.asDriver()
    fileprivate  var tokenListSearchRelay = BehaviorRelay<TokenListArray>(value: TokenListArray())

    var searchCancellable:Cancellable?=nil

    public lazy var searchAction: Action<String, Void> =
        Action {
        [weak self] (key) in
            self?.searchCancellable?.cancel()
            self?.searchCancellable =
        ExchangeProvider.instance.searchTokenInfo(key: key) {
            [weak self](result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let map):
                var list = Array<[TokenInfo]>()
                if let vite = map["VITE"] {
                    list.append(vite)
                }
                if let eth = map["ETH"] {
                    list.append(eth)
                }
                if let grin = map["GRIN"] {
                    list.append(grin)
                }
                if let bnb = map["BNB"] {
                    list.append(bnb)
                }
                self.tokenListSearchRelay.accept(list)
            case .failure(let error): break
            }
        }
        return Observable.empty()
    }
}
