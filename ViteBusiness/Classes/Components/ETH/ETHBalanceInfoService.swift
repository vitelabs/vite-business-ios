//
//  ETHBalanceInfoService.swift
//  Action
//
//  Created by Stone on 2019/2/26.
//

import ViteWallet
import PromiseKit
import ViteEthereum
import BigInt
import enum ViteWallet.Result

public class ETHBalanceInfoService: PollService {

    public typealias Ret = Result<ETHBalanceInfo>

    deinit {
        printLog("")
    }

    public var tokenInfo: TokenInfo
    public init(tokenInfo: TokenInfo, interval: TimeInterval, completion: ((Ret) -> ())? = nil) {
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
            promise = EtherWallet.balance.etherBalance().map {
                ETHBalanceInfo(tokenCode: tokenCode, balance: Balance(value: $0))
            }
        } else {
            guard let token = tokenInfo.toETHToken() else { fatalError() }
            promise = EtherWallet.balance.tokenBalance(contractAddress: token.contractAddress).map {
                ETHBalanceInfo(tokenCode: tokenCode, balance: Balance(value: $0))
            }
        }

        promise
            .done { (ret) in
                completion(Result(value: ret))
            }.catch { (e) in
                completion(Result(error: e))
        }
    }
}
