//
//  FetchBalanceInfoService.swift
//  Vite
//
//  Created by Stone on 2018/9/19.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import ViteWallet
import PromiseKit
import enum Alamofire.Result

public class FetchBalanceInfoService: PollService {

    public typealias Ret = Result<([BalanceInfo], [DexBalanceInfo], [DefiBalanceInfo])>

    deinit {
        printLog("")
    }

    public let address: ViteAddress
    public init(address: ViteAddress, interval: TimeInterval, completion: ((Ret) -> ())? = nil) {
        self.address = address
        self.interval = interval
        self.completion = completion
    }

    public var taskId: String = ""
    public var isPolling: Bool = false
    public var interval: TimeInterval = 0
    public var completion: ((Ret) -> ())?

    public func handle(completion: @escaping (Ret) -> ()) {

        when(fulfilled: ViteNode.utils.getBalanceInfos(address: address),
             ViteNode.dex.info.getDexBalanceInfos(address: address, tokenId: nil)
                .recover({ (_) -> Promise<[DexBalanceInfo]> in
                    return Promise.value([])
                }),
             ViteNode.defi.info.getDefiAccountInfo(address: address, tokenId: nil)
                .recover({ (_) -> Promise<[DefiBalanceInfo]> in
                 return Promise.value([])
             }))
            .done { (ret) in
                completion(Result.success(ret))
            }.catch { (e) in
                completion(Result.failure(e))
        }
    }
}
