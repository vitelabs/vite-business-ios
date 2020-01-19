//
//  TokenListService.swift
//  Action
//
//  Created by Water on 2019/2/25.
//
import UIKit
import RxSwift
import RxCocoa
import Then
import SwiftyJSON

public typealias TokenListMap = [String: [TokenInfo]]

extension BehaviorRelay : Then {

}

class TokenListService {
    public static let instance = TokenListService()

    lazy var tokenListRefreshDriver: Driver<TokenListMap> = self.tokenListRefreshBehaviorRelay.asDriver()
    fileprivate lazy var tokenListRefreshBehaviorRelay: BehaviorRelay<TokenListMap> = BehaviorRelay(value: TokenListMap()).then {_ in
        self.fetchTokenListCacheData()
    }
    var tokenListMap: TokenListMap{
        return tokenListRefreshBehaviorRelay.value
    }
    fileprivate let fileHelper = FileHelper.createForApp()
    fileprivate static let saveKey = "tokenInfoListData"

    public func fetchTokenListCacheData() {
        if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
             {
            var map = [String: [TokenInfo]]()
            if let json = json as? [String: Any] {
                json.forEach({ (key, value) in
                    if let array = value as? [[String: Any]] {
                        map[key] = [TokenInfo](JSONArray: array).compactMap { $0 }
                    }
                })
            }
            tokenListRefreshBehaviorRelay = BehaviorRelay(value: map)
        } else {
            tokenListRefreshBehaviorRelay = BehaviorRelay(value: TokenListMap())
        }
    }

    public func fetchTokenListServerData() {
        ExchangeProvider.instance.recommendTokenInfos { [weak self](result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let map):
                //plog(level: .debug, log: "get tokenList data  finished", tag: .exchange)
                self.tokenListRefreshBehaviorRelay.accept(map)
                self.pri_save()
            case .failure(let error):
                plog(level: .warning, log: error.localizedDescription, tag: .discover)
            }
        }
    }

    private func pri_save() {
        let json = tokenListRefreshBehaviorRelay.value

        var map = [String: [[String: Any]]]()
        if let json = json as? [String:[TokenInfo]] {
            json.forEach({ (key,model) in
                if let array = model as? [TokenInfo] {
                    map[key] =  array.toJSON()
                }
            })
        }

        if let data = try? JSON.init(map).rawData() {
            if let error = self.fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }
}
