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
import enum Alamofire.Result

public class ETHBalanceInfoService: PollService {

    public typealias Ret = Result<CommonBalanceInfo>

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

        let promise: Promise<CommonBalanceInfo>
        let tokenCode = tokenInfo.tokenCode
        if tokenInfo.isEtherCoin {
            promise = EtherWallet.balance.etherBalance().map {
                CommonBalanceInfo(tokenCode: tokenCode, balance: $0)
            }
        } else {
            guard let token = tokenInfo.toETHToken() else { fatalError() }
            promise = EtherWallet.balance.tokenBalance(contractAddress: token.contractAddress).map {
                CommonBalanceInfo(tokenCode: tokenCode, balance: $0)
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
