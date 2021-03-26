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

    static var gateway = [ViteConst.instance.crossChain.eth.tokenId: ViteConst.instance.crossChain.eth.gateway]

    var tokenId: String {
        return self.tokenInfo.id
    }

    let provider = CrossChainGatewayProvider()

    let tokenInfo: TokenInfo


    init(tokenInfo: TokenInfo) {
        if !tokenInfo.isGateway {
            fatalError()
        }
        self.tokenInfo = tokenInfo

        CrossChainGatewayInfoService.gateway[tokenInfo.id] = tokenInfo.gatewayInfo!.urlString
    }

    func getMetaInfo() -> Promise<TokenMetaInfo>  {
         return provider.getMetaInfo(for: tokenId)
    }

    func depositInfo(viteAddress: String) -> Promise<DepositInfo> {
        return provider.depositInfo(for: tokenId, viteAddress: viteAddress)
    }

    func withdrawInfo(viteAddress: String) -> Promise<WithdrawInfo> {
        return provider.withdrawInfo(for: tokenId, viteAddress: viteAddress)
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




