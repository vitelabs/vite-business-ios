//
//  TokenListManageViewModel.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/22.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

public typealias TokenListArray = [[TokenInfo]]

final class TokenListManageViewModel {
    fileprivate var newAssetTokens : [TokenInfo] = []
    func isHasNewAssetTokens() -> Bool {
        return self.newAssetTokens.count > 0 ? true : false
    }
    func newAssetTokenCount() -> Int {
        return self.newAssetTokens.count 
    }

    lazy var tokenListRefreshDriver = self.tokenListRefreshRelay.asDriver()
    fileprivate  var tokenListRefreshRelay = BehaviorRelay<TokenListArray>(value: TokenListArray())

    let disposeBag = DisposeBag()

    init() {
        NewAssetService.instance.isNewTipTokenInfosDriver.asObservable().bind { [weak self] tokens in
                self?.newAssetTokens = tokens
        }.disposed(by: disposeBag)
    }

    func refreshList() {
        TokenListService.instance.fetchTokenListCacheData()
        self.mergeData()
    }

    func mergeData() {
        var localData = MyTokenInfosService.instance.tokenInfos
        let map = TokenListService.instance.tokenListMap
        var defaultList = [TokenInfo]()
        //make map in a line list
        for item in map {
            defaultList.append(contentsOf: item.value)
        }

        //remove
        for server in defaultList {
            for (index,local) in localData.enumerated() {
                if local.tokenCode == server.tokenCode {
                    localData.remove(at: index)
                }
            }
        }

        var localViteToken = [TokenInfo]()
        var localEthToken = [TokenInfo]()
        var localGrinToken = [TokenInfo]()
        var localBnbToken = [TokenInfo]()
        for item in localData {
            if item.coinType == .vite {
                localViteToken.append(item)
            }else if item.coinType == .eth {
                localEthToken.append(item)
            } else if item.coinType == .grin {
                localGrinToken.append(item)
            } else if item.coinType == .bnb {
                localBnbToken.append(item)
            }
        }

        var list = Array<[TokenInfo]>()

        if self.isHasNewAssetTokens() {
            list.append(self.newAssetTokens)
        }

        if var vite = map["VITE"] {
            vite.append(contentsOf: localViteToken)
            list.append(vite)
        }else {
            list.append(localViteToken)
        }
        
        if var bnb = map["BNB"] {
            bnb.append(contentsOf: localBnbToken)
            list.append(bnb)
        }else {
            list.append(localBnbToken)
        }

        if var eth = map["ETH"] {
            eth.append(contentsOf: localEthToken)
            list.append(eth)
        }else {
            list.append(localEthToken)
        }
        if var grin = map["GRIN"] {
            grin.append(contentsOf: localGrinToken)
            list.append(grin)
        }else {
            list.append(localGrinToken)
        }



        tokenListRefreshRelay.accept(list)
    }

}
