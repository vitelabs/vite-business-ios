//
//  TokenListSearchViewModel.swift
//  ViteBusiness
//
//  Created by Water on 2019/3/11.
//

import Foundation
import RxSwift
import RxCocoa

final class TokenListSearchViewModel {
    lazy var tokenListSearchDriver = self.tokenListSearchRelay.asDriver()
    fileprivate  var tokenListSearchRelay = BehaviorRelay<TokenListArray>(value: TokenListArray())

    func search(_ key:String) {
        ExchangeProvider.instance.searchTokenInfo(key: key) { [weak self](result) in
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
                self.tokenListSearchRelay.accept(list)
            case .failure(let error): break
            }
        }
    }
}
