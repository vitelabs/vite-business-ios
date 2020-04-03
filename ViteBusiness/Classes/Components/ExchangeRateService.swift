//
//  ExchangeRateService.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/18.
//

import ViteWallet
import PromiseKit
import BigInt
import enum Alamofire.Result



public class ExchangeRateService: PollService {

    public typealias Ret = Result<ExchangeRateMap>

    deinit {
        printLog("")
    }

    public var tokenCodes: [TokenCode]
    public init(tokenCodes: [TokenCode], interval: TimeInterval, completion: ((Ret) -> ())? = nil) {
        self.tokenCodes = tokenCodes
        self.interval = interval
        self.completion = completion
    }

    public var taskId: String = ""
    public var isPolling: Bool = false
    public var interval: TimeInterval = 0
    public var completion: ((Ret) -> ())?

    public func handle(completion: @escaping (Ret) -> ()) {
        ExchangeProvider.instance.getRate(for: tokenCodes) { [weak self] (ret) in
            switch ret {
            case .success(let map):
                completion(Result.success(map))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

    func getRateImmediately(for tokenCode: TokenCode, completion: @escaping (Ret) -> ()) {
        let taskId = self.taskId
        tokenCodes.append(tokenCode)
        ExchangeProvider.instance.getRate(for: [tokenCode]) { [weak self] (ret) in
            guard let `self` = self else { return }
            guard taskId == self.taskId else { return }
            switch ret {
            case .success(let map):
                completion(Result.success(map))
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
}
