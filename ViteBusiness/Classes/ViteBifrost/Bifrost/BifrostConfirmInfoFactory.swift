//
//  BifrostConfirmInfoFactory.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//

import Foundation
import PromiseKit
import SwiftyJSON
import ViteWallet

public enum ConfirmError: Error, DisplayableError {
    case InvalidParameters
    case InvalidToAddress
    case InvalidTokenId
    case InvalidAmount
    case InvalidFee
    case InvalidData
    case InvalidExtend
    case InvalidAbi
    case InvalidDescription
    case unknown(String)

    public var errorMessage: String {
        switch self {
        case .InvalidParameters:
            return "InvalidParameters"
        case .InvalidToAddress:
            return "InvalidToAddress"
        case .InvalidTokenId:
            return "InvalidTokenId"
        case .InvalidAmount:
            return "InvalidAmount"
        case .InvalidFee:
            return "InvalidFee"
        case .InvalidData:
            return "InvalidData"
        case .InvalidExtend:
            return "InvalidExtend"
        case .InvalidAbi:
            return "InvalidAbi"
        case .InvalidDescription:
            return "InvalidDescription"
        case .unknown(let text):
            return "unknown: \(text)"
        }
    }
}

struct BifrostConfirmInfoFactory {

    static public func generateConfirmInfo(_ sendTx: VBViteSendTx) -> Promise<(BifrostConfirmInfo, TokenInfo)> {
        let block = sendTx.block!
        let extend = sendTx.extend

        guard let addressType = block.toAddress.viteAddressType else {
            return Promise(error: ConfirmError.InvalidToAddress)
        }

        return Promise<TokenInfo> { seal in
            MyTokenInfosService.instance.tokenInfo(forViteTokenId: block.tokenId) { result in
                switch result {
                case .success(let r):
                    seal.fulfill(r)
                case .failure(let e):
                    seal.reject(e)
                }
            }
            }.then({ (tokenInfo) -> Promise<(BifrostConfirmInfo, TokenInfo)> in

                switch addressType {
                case .user:
                    guard let type = BuildInTransfer.matchType(sendTx) else {
                        throw ConfirmError.InvalidParameters
                    }
                    return type.info.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                case .contract:
                    let map = BuildInContract.toAddressAndDataPrefixMap
                    if let data = block.data, data.count >= 4,
                        let type = map["\(block.toAddress!)_\(data[0..<4].toHexString())"] {
                        return type.info.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                    } else {
                        return BuildInContractOthers.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                    }
                }
            })
    }

    enum BuildInTransfer: CaseIterable {

        case normal
        case crossChain

        fileprivate var info: BuildInTransferProtocol {
            switch self {
            case .normal:
                return BuildInTransferNormal()
            case .crossChain:
                return BuildInTransferCrossChain()
            }
        }

        static func matchType(_ sendTx: VBViteSendTx) -> BuildInTransfer? {
            for type in BuildInTransfer.allCases {
                if type.info.match(sendTx) {
                    return type
                }
            }
            return nil
        }
    }

    enum BuildInContract: CaseIterable {

        fileprivate static let toAddressAndDataPrefixMap: [String: BuildInContract] =
            BuildInContract.allCases.reduce([String: BuildInContract]()) { (r, c) -> [String: BuildInContract] in
                var ret = r
                let abi = c.info.abi
                let key = "\(abi.toAddress)_\(abi.encodedFunctionSignature.toHexString())"
                ret[key] = c
                return ret
        }

        case register
        case registerUpdate
        case cancelRegister
        case extractReward

        case vote
        case cancelVote
        case pledge
        case cancelPledge

        case coinMint
        case coinIssue
        case coinTransferOwner
        case coinChangeTokenType

        case dexDeposit
        case dexWithdraw
        case dexPost
        case dexCancel

        case dexNewInviter
        case dexBindInviter

        case dexTransferTokenOwner
        case dexNewMarket
        case dexMarketConfig

        case dexStakingAsMining
        case dexVip

        fileprivate var info: BuildInContractProtocol {

            switch self {
            case .register:
                return BuildInContractRegister()
            case .registerUpdate:
                return BuildInContractRegisterUpdate()
            case .cancelRegister:
                return BuildInContractCancelRegister()
            case .extractReward:
                return BuildInContractExtractReward()
            case .vote:
                return BuildInContractVote()
            case .cancelVote:
                return BuildInContractCancelVote()
            case .pledge:
                return BuildInContractPledge()
            case .cancelPledge:
                return BuildInContractCancelPledge()
            case .coinMint:
                return BuildInContractCoinMint()
            case .coinIssue:
                return BuildInContractCoinIssue()
            case .coinTransferOwner:
                return BuildInContractCoinTransferOwner()
            case .coinChangeTokenType:
                return BuildInContractCoinChangeTokenType()
            case .dexDeposit:
                return BuildInContractDexDeposit()
            case .dexWithdraw:
                return BuildInContractDexWithdraw()
            case .dexPost:
                return BuildInContractDexPost()
            case .dexCancel:
                return BuildInContractDexCancel()
            case .dexNewInviter:
                return BuildInContractDexNewInviter()
            case .dexBindInviter:
                return BuildInContractDexBindInviter()
            case .dexTransferTokenOwner:
                return BuildInContractDexTransferTokenOwner()
            case .dexNewMarket:
                return BuildInContractDexNewMarket()
            case .dexMarketConfig:
                return BuildInContractDexMarketConfig()
            case .dexStakingAsMining:
                return BuildInContractDexStakingAsMining()
            case .dexVip:
                return BuildInContractDexVip()
            }
        }
    }
}
