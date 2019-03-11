//
//  TokenListManageViewModel.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/22.
//

import Foundation
import RxSwift
import RxCocoa

public typealias TokenListArray = [[TokenInfo]]

final class TokenListManageViewModel {
    lazy var tokenListRefreshDriver = self.tokenListRefreshRelay.asDriver()
    fileprivate  var tokenListRefreshRelay = BehaviorRelay<TokenListArray>(value: TokenListArray())

    func refreshList() {
        TokenListService.instance.fetchTokenListCacheData()
        let map = TokenListService.instance.tokenListMap
        var list = Array<[TokenInfo]>()
        if let vite = map["VITE"] {
            list.append(vite)
        }
        if let eth = map["ETH"] {
            list.append(eth)
        }
        tokenListRefreshRelay.accept(list)
    }
}
