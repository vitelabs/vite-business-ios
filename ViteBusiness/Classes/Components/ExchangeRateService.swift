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
        UnifyProvider.vitex.getRate(tokenCodes: tokenCodes).done { (map) in
            completion(Result.success(map))
        }.catch { (error) in
            completion(Result.failure(error))
        }
    }

    func getRateImmediately(for tokenCode: TokenCode, completion: @escaping (Ret) -> ()) {
        let taskId = self.taskId
        tokenCodes.append(tokenCode)
        UnifyProvider.vitex.getRate(tokenCodes: tokenCodes).done {[weak self] (map) in
            guard let `self` = self else { return }
            guard taskId == self.taskId else { return }
            completion(Result.success(map))
        }.catch {[weak self] (error) in
            guard let `self` = self else { return }
            guard taskId == self.taskId else { return }
            completion(Result.failure(error))
        }
    }
}
