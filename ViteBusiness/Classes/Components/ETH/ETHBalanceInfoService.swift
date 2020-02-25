//
//  ETHBalanceInfoService.swift
//  Action
//
//  Created by Stone on 2019/2/26.
//

import ViteWallet
import PromiseKit

import BigInt
import enum Alamofire.Result

public class ETHBalanceInfoService: PollService {

    public typealias Ret = Result<ETHBalanceInfo>

    deinit {
        printLog("")
    }

    public var ethAccount: ETHAccount
    public var tokenInfo: TokenInfo
    public init(ethAccount: ETHAccount, tokenInfo: TokenInfo, interval: TimeInterval, completion: ((Ret) -> ())? = nil) {
        self.ethAccount = ethAccount
        self.tokenInfo = tokenInfo
        self.interval = interval
        self.completion = completion
    }

    public var taskId: String = ""
    public var isPolling: Bool = false
    public var interval: TimeInterval = 0
    public var completion: ((Ret) -> ())?

    public func handle(completion: @escaping (Ret) -> ()) {

        let promise: Promise<ETHBalanceInfo>
        let tokenCode = tokenInfo.tokenCode
        if tokenInfo.isEtherCoin {
            promise = ethAccount.etherBalance().map {
                ETHBalanceInfo(tokenCode: tokenCode, balance: $0)
            }
        } else {
            guard let token = tokenInfo.toETHToken() else { fatalError() }
            promise = ethAccount.tokenBalance(contractAddress: token.contractAddress).map {
                ETHBalanceInfo(tokenCode: tokenCode, balance: $0)
            }
        }

        promise
            .done { (ret) in
                completion(Result.success(ret))
            }.catch { (e) in
                completion(Result.failure(e))
        }
    }
}
