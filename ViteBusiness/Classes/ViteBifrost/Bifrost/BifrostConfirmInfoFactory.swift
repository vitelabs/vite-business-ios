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

        return TokenInfoCacheService.instance.tokenInfo(forViteTokenId: block.tokenId)
            .then({ (tokenInfo) -> Promise<(BifrostConfirmInfo, TokenInfo)> in

                switch addressType {
                case .user:
                    guard let type = BuildInTransfer.matchType(sendTx) else {
                        throw ConfirmError.InvalidParameters
                    }
                    return type.info.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                case .contract:
                    if let type = block.blockType, type == .createSend {
                        return BuildInCreateContract.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                    } else {
                        let map = BuildInContract.toAddressAndDataPrefixMap
                        if let data = block.data, data.count >= 4,
                            let type = map["\(block.toAddress!).\(data[0..<4].toHexString())"] {
                            return type.info.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                        } else {
                            return BuildInContractOthers.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                        }
                    }
                }
            })
    }

    static public func generateConfirmInfo(_ signMessage: VBViteSignMessage) -> Promise<BifrostConfirmInfo> {

        let addressItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationSignMessageAddress(), text: HDWalletManager.instance.account!.address)
        let typeItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationSignMessageType(), text: R.string.localizable.bifrostOperationSignMessageTypeTradeValue())
        let contentItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationSignMessageContent(), text: signMessage.message.toHexString())
        return Promise.value(BifrostConfirmInfo(title: R.string.localizable.bifrostOperationSignMessageTitle(), items: [addressItem, typeItem, contentItem]))
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
                let key = "\(abi.toAddress).\(abi.encodedFunctionSignature.toHexString())"
                ret[key] = c
                return ret
        }

        case registerSBP
        case updateSBPBlockProducingAddress
//        case updateSBPRewardWithdrawAddress
        case revokeSBP
        case withdrawSBPReward

        case voteForSBP
        case cancelSBPVoting
        case stakeForQuota
        case cancelQuotaStaking
        case old_cancelStake

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
        case dexLockVxForDividend
        case dexCancelStakeById

        fileprivate var info: BuildInContractProtocol {

            switch self {
            case .registerSBP:
                return BuildInContractRegisterSBP()
            case .updateSBPBlockProducingAddress:
                return BuildInContractUpdateSBPBlockProducingAddress()
//            case .updateSBPRewardWithdrawAddress:
//                return BuildInContractUpdateSBPRewardWithdrawAddress()
            case .revokeSBP:
                return BuildInContractRevokeSBP()
            case .withdrawSBPReward:
                return BuildInContractWithdrawSBPReward()

            case .voteForSBP:
                return BuildInContractVoteForSBP()
            case .cancelSBPVoting:
                return BuildInContractCancelSBPVoting()

            case .stakeForQuota:
                return BuildInContractStakeForQuota()
            case .cancelQuotaStaking:
                return BuildInContractCancelQuotaStaking()
            case .old_cancelStake:
                return BuildInContractOldCancelStake()

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
            case .dexLockVxForDividend:
                return BuildInContractDexLockVxForDividend()
            case .dexCancelStakeById:
                return BuildInContractDexCancelStakeById()
            }
        }
    }
}
