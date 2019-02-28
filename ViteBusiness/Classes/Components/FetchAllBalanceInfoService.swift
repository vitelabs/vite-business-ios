//
//  FetchAllBalanceInfoService.swift
//  ViteBusiness
//
//  Created by Stone on 2019/2/28.
//

import Foundation
import ViteWallet
import PromiseKit
import RxSwift
import RxCocoa
import RxOptional
import ViteUtils
import ViteEthereum
import enum ViteWallet.Result

public class FetchAllBalanceInfoService: PollService {

    public typealias Ret = Result<[CommonBalanceInfo]>

    deinit {
        printLog("")
    }

    public let address: Address
    public init(address: Address, interval: TimeInterval, completion: ((Result<[CommonBalanceInfo]>) -> ())? = nil) {
        self.address = address
        self.interval = interval
        self.completion = completion
    }

    public var taskId: String = ""
    public var isPolling: Bool = false
    public var interval: TimeInterval = 0
    public var completion: ((Result<[CommonBalanceInfo]>) -> ())?

    public func handle(completion: @escaping (Result<[CommonBalanceInfo]>) -> ()) {
        let tokenInfos = MyTokenInfosService.instance.tokenInfos
        self.getBalanceInfo(tokenInfos: tokenInfos, viteAddress: address.description)
            .done { (ret) in
                completion(Result(value: ret))
            }.catch { (e) in
                completion(Result(error: e))
        }
    }

    private func getBalanceInfo(tokenInfos: [TokenInfo], viteAddress: String) -> Promise<[CommonBalanceInfo]> {
        let viteTokenInfos = tokenInfos.filter { $0.chainType == .vite }
        let ethTokenInfos = tokenInfos.filter { $0.chainType == .eth }

        return when(fulfilled: ViteWallet.FetchBalanceInfoService.getBalanceInfo(tokenInfos: viteTokenInfos, address: viteAddress),
                    EtherWallet.shared.getBalanceInfo(tokenInfos: ethTokenInfos)).map { (viteBalanceInfos, ethBalanceInfos) -> [CommonBalanceInfo] in
                        var map: [String: CommonBalanceInfo] = [:]
                        for info in viteBalanceInfos {
                            map[info.tokenCode] = info
                        }
                        for info in ethBalanceInfos {
                            map[info.tokenCode] = info
                        }

                        var balanceInfos: [CommonBalanceInfo] = []
                        for tokenInfo in tokenInfos {
                            if let balanceInfo = map[tokenInfo.tokenCode] {
                                balanceInfos.append(balanceInfo)
                            }
                        }
                        return balanceInfos
        }
    }
}
