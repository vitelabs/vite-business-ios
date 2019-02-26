//
//  TokenListService.swift
//  Action
//
//  Created by Water on 2019/2/25.
//
import UIKit
import RxSwift
import RxCocoa
import ViteUtils

class TokenListService {
    lazy var discoverRefreshDriver: Driver<Bool> = self.discoverRefreshBehaviorRelay.asDriver()
    fileprivate var discoverRefreshBehaviorRelay: BehaviorRelay<Bool>

    var tokenInfoListData: [TokenInfo]?
    var requestError: Error?
    fileprivate let fileHelper = FileHelper(.caches, appending: "tokenInfoListData")

    fileprivate func saveKey()->String {
        return "tokenInfoListData"
    }

    init() {
        tokenInfoListData = nil
        discoverRefreshBehaviorRelay = BehaviorRelay(value: true)
    }
    public func fetchDiscoverCacheData() {
        if let data = self.fileHelper.contentsAtRelativePath(self.saveKey()),
            let jsonString = String(data: data, encoding: .utf8),
            let jsonData = TokenInfo(JSONString: jsonString) {
            discoverRefreshBehaviorRelay = BehaviorRelay(value: true)
        }else{

        }
    }

    public func fetchDiscoverServerData() {
        TokenInfoProvider.instance.getAllList { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let jsonString):
                plog(level: .debug, log: "get discover data  finished", tag: .discover)
                guard let string = jsonString else { return }
                plog(level: .debug, log: "md5: \(string.md5())", tag: .discover)
                if let data = string.data(using: .utf8) {
                    DispatchQueue.global(qos: .background).async {
                        if let error = self.fileHelper.writeData(data, relativePath: self.saveKey()) {
                        }
                    }
                }
                let jsonData = TokenInfo(JSONString: string )
                self.requestError = nil
                self.discoverRefreshBehaviorRelay.accept(true)
            case .failure(let error):
                self.requestError = error
                self.discoverRefreshBehaviorRelay.accept(false)
                plog(level: .warning, log: error.localizedDescription, tag: .discover)
            }
        }
    }
}
