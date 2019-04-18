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

        var promise: Promise<ETHBalanceInfo>!
        if tokenInfo.isEtherCoin {
            promise = EtherWallet.shared.getEtherBalanceInfo()
        } else {
            promise = EtherWallet.shared.getETHTokenBalanceInfo(tokenInfo: tokenInfo)
        }

        promise
            .done { (ret) in
                completion(Result(value: ret))
            }.catch { (e) in
                completion(Result(error: e))
        }
    }
}


extension EtherWallet {

    func getEtherBalanceInfo() -> Promise<ETHBalanceInfo> {
        return Promise<ETHBalanceInfo> { seal in
            DispatchQueue.global().async {
                do {
                    let balance = try self.etherBalanceSync()
                    DispatchQueue.main.async {
                        seal.fulfill(ETHBalanceInfo(tokenCode: TokenCode.etherCoin, balance: balance))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        seal.reject(error)
                    }
                }
            }
        }
    }

    func getETHTokenBalanceInfo(tokenInfo: TokenInfo) -> Promise<ETHBalanceInfo> {
        guard let token = tokenInfo.toETHToken() else { fatalError() }
        return Promise<ETHBalanceInfo> { seal in
            DispatchQueue.global().async {
                do {
                    let balance = try self.tokenBalanceSync(contractAddress: token.contractAddress)
                    DispatchQueue.main.async {
                        seal.fulfill(ETHBalanceInfo(tokenCode: tokenInfo.tokenCode, balance: balance))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        seal.reject(error)
                    }
                }
            }
        }
    }
}
