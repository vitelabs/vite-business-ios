//
//  CrossChainGatewayService.swift
//  Action
//
//  Created by haoshenyang on 2019/6/13.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import Moya
import SwiftyJSON
import ObjectMapper
import PromiseKit
import enum Alamofire.Result


class CrossChainGatewayInfoService {

    var tokenId: String {
        return self.tokenInfo.id
    }

    let tokenInfo: TokenInfo
    fileprivate let providers: [CrossChainGatewayProvider]
    
    fileprivate(set) var index = 0
    
    fileprivate var provider: CrossChainGatewayProvider {
        providers[index]
    }
    
    fileprivate var allMappedTokenExtraInfos: [MappedTokenExtraInfo]
    
    var currentMappedToken: MappedTokenExtraInfo {
        allMappedTokenExtraInfos[index]
    }

    init(tokenInfo: TokenInfo) {
        guard let gatewayInfo = tokenInfo.gatewayInfo else  {
            fatalError()
        }
        self.tokenInfo = tokenInfo
        self.allMappedTokenExtraInfos = gatewayInfo.allMappedTokenExtraInfos
        self.providers = allMappedTokenExtraInfos.map {
            CrossChainGatewayProvider(baseURL: URL(string: $0.url)!)
        }
    }


    func getMetaInfo() -> Promise<TokenMetaInfo>  {
         return provider.getMetaInfo(for: tokenId)
    }
    
    fileprivate var depositInfoMap: [Int: DepositInfo] = [:]
    fileprivate var withdrawInfoMap: [Int: WithdrawInfo] = [:]

    func depositInfo(viteAddress: String, index: Int) -> Promise<DepositInfo> {
        if let info = depositInfoMap[index] {
            self.index = index
            return Promise.value(info)
        }
        
        return providers[index].depositInfo(for: tokenId, viteAddress: viteAddress).then {[weak self] info -> Promise<DepositInfo> in
            self?.depositInfoMap[index] = info
            self?.index = index
            return Promise.value(info)
        }
    }

    func withdrawInfo(viteAddress: String, index: Int) -> Promise<WithdrawInfo> {
        if let info = withdrawInfoMap[index] {
            self.index = index
            return Promise.value(info)
        }
        
        return providers[index].withdrawInfo(for: tokenId, viteAddress: viteAddress).then {[weak self] info -> Promise<WithdrawInfo> in
            self?.withdrawInfoMap[index] = info
            self?.index = index
            return Promise.value(info)
        }
    }

    func verifyWithdrawAddress(withdrawAddress: String, label: String?) -> Promise<Bool> {
        return provider.verifyWithdrawAddress(for: tokenId, withdrawAddress: withdrawAddress, label: label)
    }

    func withdrawFee(viteAddress: String,amount: String,containsFee: Bool) -> Promise<String> {
        return provider.withdrawFee(for: tokenId, viteAddress: viteAddress, amount: amount, containsFee: containsFee)
    }

    func depositRecords(viteAddress: String,pageNum: Int,pageSize: Int) -> Promise<DepositRecordInfos> {
        return provider.depositRecords(for: tokenId, viteAddress: viteAddress, pageNum: pageNum, pageSize: pageSize)
    }

    func withdrawRecords(viteAddress: String,pageNum: Int,pageSize: Int) -> Promise<WithdrawRecordInfos> {
        return provider.withdrawRecords(for: tokenId, viteAddress: viteAddress, pageNum: pageNum, pageSize: pageSize)
    }
}




