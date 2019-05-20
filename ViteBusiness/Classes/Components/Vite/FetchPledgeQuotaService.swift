//
//  FetchPledgeQuotaService.swift
//  Vite
//
//  Created by Stone on 2018/10/26.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import ViteWallet
import PromiseKit
import enum Alamofire.Result

public class FetchPledgeQuotaService: PollService {

    public typealias Ret = Result<Quota>

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

        ViteNode.pledge.info.getPledgeQuota(address: address)
            .done { (ret) in
                completion(Result.success(ret))
            }.catch { (e) in
                completion(Result.failure(e))
        }
    }
}
