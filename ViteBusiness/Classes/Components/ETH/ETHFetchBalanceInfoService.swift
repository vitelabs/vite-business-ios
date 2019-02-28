//
//  ETHFetchBalanceInfoService.swift
//  Action
//
//  Created by Stone on 2019/2/26.
//

import ViteWallet
import PromiseKit
import ViteEthereum
import BigInt
import enum ViteWallet.Result

public class ETHFetchBalanceInfoService {

    public typealias Ret = Result<[CommonBalanceInfo]>

    deinit {
        printLog("")
    }

    public let address: Address
    public init(address: Address, interval: TimeInterval, completion: ((Result<[BalanceInfo]>) -> ())? = nil) {
        self.address = address
        self.interval = interval
        self.completion = completion
    }

    public var taskId: String = ""
    public var isPolling: Bool = false
    public var interval: TimeInterval = 0
    public var completion: ((Result<[BalanceInfo]>) -> ())?

    public func handle(completion: @escaping (Result<[BalanceInfo]>) -> ()) {

        Provider.default.getBalanceInfos(address: address)
            .done { (ret) in
                completion(Result(value: ret))
            }.catch { (e) in
                completion(Result(error: e))
        }
    }
}

extension ViteWallet.FetchBalanceInfoService {
    static func getBalanceInfo(tokenInfos: [TokenInfo], address: String) -> Promise<[CommonBalanceInfo]> {
        if tokenInfos.isEmpty {
            return Promise.value([CommonBalanceInfo]())
        } else {
            return Provider.default.getBalanceInfos(address: Address(string: address)).map { (viteBalanceInfos) -> [CommonBalanceInfo] in
                let map = viteBalanceInfos.reduce([String: BalanceInfo](), { (result, info) -> [String: BalanceInfo] in
                    var ret = result
                    ret[info.token.id] = info
                    return ret
                })

                var infos: [CommonBalanceInfo] = []
                for tokenInfo in tokenInfos {
                    if let info = map[tokenInfo.viteTokenId] {
                        infos.append(CommonBalanceInfo(tokenCode: tokenInfo.tokenCode, balance: info.balance))
                    } else {
                        infos.append(CommonBalanceInfo(tokenCode: tokenInfo.tokenCode, balance: Balance(value: BigInt(0))))
                    }
                }
                return infos
            }
        }
    }
}


extension EtherWallet {

    func getBalanceInfo(tokenInfos: [TokenInfo]) -> Promise<[CommonBalanceInfo]> {
        var etherTokenInfo: TokenInfo?
        var otherTokenInfos: [TokenInfo] = []

        for info in tokenInfos {
            if info.isEtherCoin {
                etherTokenInfo = info
            } else {
                otherTokenInfos.append(info)
            }
        }

        if otherTokenInfos.isEmpty {
            if let info = etherTokenInfo {
                return getEtherBalanceInfo().map { [$0] }
            } else {
                return Promise.value([CommonBalanceInfo]())
            }
        } else {
            let others = when(fulfilled: otherTokenInfos.map { getETHTokenBalanceInfo(tokenInfo: $0) })
            if let info = etherTokenInfo {
                return when(fulfilled: others, getEtherBalanceInfo()).map { (others, ether) -> [CommonBalanceInfo] in
                    let map = others.reduce([ether.tokenCode: ether], { (result, info) -> [String: CommonBalanceInfo] in
                        var ret = result
                        ret[info.tokenCode] = info
                        return ret
                    })
                    var infos: [CommonBalanceInfo] = []
                    for tokenInfo in tokenInfos {
                        if let info = map[tokenInfo.tokenCode] {
                            infos.append(info)
                        }
                    }
                    return infos
                }
            } else {
                return others
            }
        }
    }

    func getEtherBalanceInfo() -> Promise<CommonBalanceInfo> {
        return Promise<CommonBalanceInfo> { seal in
            DispatchQueue.global().async {
                do {
                    let balance = try self.etherBalanceSync()
                    DispatchQueue.main.async {
                        seal.fulfill(CommonBalanceInfo(tokenCode: TokenCode.etherCoin, balance: Balance(value: balance)))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        seal.reject(error)
                    }
                }
            }
        }
    }

    func getETHTokenBalanceInfo(tokenInfo: TokenInfo) -> Promise<CommonBalanceInfo> {
        guard let token = tokenInfo.toETHToken() else { fatalError() }
        return Promise<CommonBalanceInfo> { seal in
            DispatchQueue.global().async {
                do {
                    let balance = try self.tokenBalanceSync(contractAddress: token.contractAddress)
                    DispatchQueue.main.async {
                        seal.fulfill(CommonBalanceInfo(tokenCode: tokenInfo.tokenCode, balance: Balance(value: balance)))
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
