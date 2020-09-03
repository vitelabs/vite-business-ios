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
import BigInt

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
        let address = self.address
        let batch = BatchFactory().create(
            GetSBPListRequest(address: address),
            GetPledgeDetailRequest(address: address, index: 0, count: 0),
            GetDexCurrentMiningStakingAmountByAddressRequest(address: address),
            GetDexVIPStakeInfoListRequest(address: address, index: 0, count: 0))
        let request = RPCRequest(for: Provider.default.server, batch: batch).promise

        #if DEBUG || TEST
        let getFullNodeTotalPledgeAmountPromise: Promise<Amount> = {
            if DebugService.instance.config.configEnvironment == .test {
                let string = address[address.index(address.startIndex, offsetBy: 5)]
                if string.isNumber {
                    return .value((BigDecimal(String(string))! * BigDecimal(BigInt(10).power(18))).round())
                } else {
                    return .value(BigInt(0))
                }
            } else {
                return UnifyProvider.vitex.getFullNodeTotalPledgeAmount(address: address)
            }
        }()
        #else
        let getFullNodeTotalPledgeAmountPromise = UnifyProvider.vitex.getFullNodeTotalPledgeAmount(address: address)
        #endif

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
            getFullNodeTotalPledgeAmountPromise,
            request)
            .done { (wallet, dex, map, fullNodeTotalPledgeAmount, ret) in
                let (sbpInfos, walletPledgeDetail, viteStake, dexPledgeDetail) = ret
                let walletTotalPledgeAmount = walletPledgeDetail.totalPledgeAmount

                let viteStakeForSBP = sbpInfos.filter { $0.stakeAddress == address }.map { $0.stakeAmount }.reduce(Amount(0), +)
                let walletLockedInfo = WalletBalanceLocked(viteStakeForPledge: walletPledgeDetail.totalPledgeAmount, viteStakeForSBP: viteStakeForSBP, viteStakeForFullNode: fullNodeTotalPledgeAmount)


                let vx = map[TokenInfo.BuildIn.vx.value.viteTokenId] ?? DexAccountFundInfo(token: TokenInfo.BuildIn.vx.value.toViteToken()!)
                let vite = map[TokenInfo.BuildIn.vite.value.viteTokenId] ?? DexAccountFundInfo(token: TokenInfo.BuildIn.vite.value.toViteToken()!)
                let lockedInfo = DexBalanceLocked(vxLocked: vx.vxLocked,
                                                  vxUnlocking: vx.vxUnlocking,
                                                  viteStakeForVip: dexPledgeDetail.totalPledgeAmount,
                                                  viteStakeForMining: viteStake,
                                                  viteCancellingStakeForMining: vite.viteCancellingStake)

                var walletMerged = [BalanceInfo]()
                var dexMerged = [DexBalanceInfo]()


                for var balance in wallet {
                    balance.mergeLockedInfoIfNeeded(info: walletLockedInfo)
                    walletMerged.append(balance)
                }

                var set = Set<String>()
                for var balance in dex {
                    balance.mergeLockedInfoIfNeeded(info: lockedInfo)
                    dexMerged.append(balance)
                    set.insert(balance.token.id)
                }

                if !set.contains(TokenInfo.BuildIn.vite.value.viteTokenId) {
                    var balance = DexBalanceInfo(token: TokenInfo.BuildIn.vite.value.toViteToken()!)
                    balance.mergeLockedInfoIfNeeded(info: lockedInfo)
                    dexMerged.append(balance)
                }

                if !set.contains(TokenInfo.BuildIn.vx.value.viteTokenId) {
                    var balance = DexBalanceInfo(token: TokenInfo.BuildIn.vx.value.toViteToken()!)
                    balance.mergeLockedInfoIfNeeded(info: lockedInfo)
                    dexMerged.append(balance)
                }

                completion(Result.success((walletMerged, dexMerged)))
        }.catch { (e) in
            completion(Result.failure(e))
        }
    }
}
