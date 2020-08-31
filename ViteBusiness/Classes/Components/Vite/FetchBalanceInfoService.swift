//
//  FetchBalanceInfoService.swift
//  Vite
//
//  Created by Stone on 2018/9/19.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import ViteWallet
import PromiseKit
import JSONRPCKit
import enum Alamofire.Result

public class FetchBalanceInfoService: PollService {

    public typealias Ret = Result<([BalanceInfo], [DexBalanceInfo])>

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

        let batch = BatchFactory().create(
            GetDexCurrentMiningStakingAmountByAddressRequest(address: address),
            GetDexVIPStakeInfoListRequest(address: address, index: 0, count: 0))
        let request = RPCRequest(for: Provider.default.server, batch: batch).promise

        when(fulfilled:
            ViteNode.utils.getBalanceInfos(address: address),
            ViteNode.dex.info.getDexBalanceInfos(address: address, tokenId: nil)
                .recover { (_) -> Promise<[DexBalanceInfo]> in
                    return Promise.value([])
            },
            ViteNode.dex.info.getDexAccountFundInfo(address: address, tokenId: nil)
                .recover { (_) -> Promise<[ViteTokenId: DexAccountFundInfo]> in
                    return Promise.value([:])
            },
            request)
            .done { (wallet, dex, map, ret) in
                let (viteStake, pledgeDetail) = ret
                let vx = map[TokenInfo.BuildIn.vx.value.viteTokenId] ?? DexAccountFundInfo(token: TokenInfo.BuildIn.vx.value.toViteToken()!)
                let vite = map[TokenInfo.BuildIn.vite.value.viteTokenId] ?? DexAccountFundInfo(token: TokenInfo.BuildIn.vite.value.toViteToken()!)
                let lockedInfo = DexBalanceLocked(vxLocked: vx.vxLocked,
                                                  vxUnlocking: vx.vxUnlocking,
                                                  viteStakeForVip: pledgeDetail.totalPledgeAmount,
                                                  viteStakeForMining: viteStake,
                                                  viteCancellingStakeForMining: vite.viteCancellingStake)
                
                var merged = [DexBalanceInfo]()
                var set = Set<String>()
                for var balance in dex {
                    balance.mergeLockedInfoIfNeeded(info: lockedInfo)
                    merged.append(balance)
                    set.insert(balance.token.id)
                }

                if !set.contains(TokenInfo.BuildIn.vite.value.viteTokenId) {
                    var balance = DexBalanceInfo(token: TokenInfo.BuildIn.vite.value.toViteToken()!)
                    balance.mergeLockedInfoIfNeeded(info: lockedInfo)
                    merged.append(balance)
                }

                if !set.contains(TokenInfo.BuildIn.vx.value.viteTokenId) {
                    var balance = DexBalanceInfo(token: TokenInfo.BuildIn.vx.value.toViteToken()!)
                    balance.mergeLockedInfoIfNeeded(info: lockedInfo)
                    merged.append(balance)
                }

                completion(Result.success((wallet, merged)))
        }.catch { (e) in
            completion(Result.failure(e))
        }
    }
}
