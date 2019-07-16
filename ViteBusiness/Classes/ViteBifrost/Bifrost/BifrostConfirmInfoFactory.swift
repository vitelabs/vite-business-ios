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

struct BifrostConfirmInfoFactory {

    public enum ConfirmError: Error, DisplayableError {
        case InvalidParameters
        case InvalidToAddress
        case InvalidAmount
        case InvalidData
        case InvalidExtend
        case missingAbi
        case missingDescription
        case unknown(String)

        public var errorMessage: String {
            switch self {
            case .InvalidParameters:
                return "InvalidParameters"
            case .InvalidToAddress:
                return "InvalidToAddress"
            case .InvalidAmount:
                return "InvalidAmount"
            case .InvalidData:
                return "InvalidData"
            case .InvalidExtend:
                return "InvalidExtend"
            case .missingAbi:
                return "missingAbi"
            case .missingDescription:
                return "missingDescription"
            case .unknown(let text):
                return "unknown: \(text)"
            }
        }
    }

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
                    if let e = extend {
                        guard let json = try? JSON(e), json["type"].string == "crossChainTransfer" else {
                            throw ConfirmError.InvalidExtend
                        }

                        guard let data = block.data, data.contentTypeInUInt16 == 0x0bc3 else {
                            throw ConfirmError.InvalidData
                        }

                        return BuildInTransfer.crossChainTransfer.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                    } else {
                        if let data = block.data, !data.isEmpty {
                            guard data.contentTypeInUInt16 == AccountBlockDataContentType.utf8string.rawValue else {
                                throw ConfirmError.InvalidData
                            }
                        }
                        return BuildInTransfer.transfer.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                    }
                case .contract:
                    if let data = block.data,
                        data.count >= 4,
                        let type = BuildInContract.dataPrefixMap[data[0..<4].toHexString()],
                        BuildInContract.typeToAddressMap[type] == block.toAddress {
                        return type.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                    } else {
                        return Other.confirmInfo(sendTx, tokenInfo).map { ($0, tokenInfo) }
                    }
                }
            })
    }

    struct Other {
        static func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
            let account = HDWalletManager.instance.account!
            let block = sendTx.block!

            guard let abi = sendTx.abi else { return Promise(error: ConfirmError.InvalidParameters) }
            guard let des = sendTx.description else { return Promise(error: ConfirmError.InvalidParameters) }
            let title = des.function.title ?? ""

            do {
                let addressItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleContractAddress(),
                                                         text: block.toAddress)
                let tokenItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleTokenSymbol(),
                                                       text: tokenInfo.uniqueSymbol)
                let amountItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleAmount(),
                                                        text: block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals))

                guard let abi = sendTx.abi else { return Promise(error: ConfirmError.missingAbi) }
                guard let des = sendTx.description else { return Promise(error: ConfirmError.missingDescription) }

                let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                guard values.count == des.inputs.count else { return Promise(error: ConfirmError.InvalidParameters) }
                var items: [BifrostConfirmItemInfo] = [addressItem, tokenItem, amountItem]

                for i in 0..<values.count {
                    let input = des.inputs[i]
                    let text = values[i].toString()
                    items.append(input.confirmItemInfo(text: text))
                }

                return Promise.value(BifrostConfirmInfo(title: des.function.title ?? "", items: items))
            } catch {
                return Promise(error: ConfirmError.InvalidData)
            }
        }
    }

    enum BuildInTransfer {

        case transfer
        case crossChainTransfer

        fileprivate static let DesMap = [
            BuildInTransfer.transfer: "{\"function\":{\"name\":{\"base\":\"Transfer\",\"zh\":\"转账\"}},\"inputs\":[{\"name\":{\"base\":\"Transaction Address\",\"zh\":\"交易地址\"}},{\"name\":{\"base\":\"Amount\",\"zh\":\"交易金额\"},\"style\":{\"textColor\":\"007AFF\",\"backgroundColor\":\"007AFF0F\"}},{\"name\":{\"base\":\"Comment\",\"zh\":\"备注信息\"}}]}",
            BuildInTransfer.crossChainTransfer: "{\"function\":{\"name\":{\"base\":\"Cross-Chain Transfer\",\"zh\":\"跨链转出\"}},\"inputs\":[{\"name\":{\"base\":\"Amount\",\"zh\":\"转出金额\"},\"style\":{\"textColor\":\"007AFF\",\"backgroundColor\":\"007AFF0F\"}},{\"name\":{\"base\":\"Receive Address\",\"zh\":\"收款地址\"}},{\"name\":{\"base\":\"Fee\",\"zh\":\"手续费\"}}]}"
        ]

        func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
            let account = HDWalletManager.instance.account!
            let des = VBViteSendTx.Description(JSONString: BuildInTransfer.DesMap[self]!)!
            let title = des.function.title ?? ""
            let block = sendTx.block!

            switch self {
            case .transfer:
                let amount = "\(block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
                let items = [des.inputs[0].confirmItemInfo(text: block.toAddress),
                             des.inputs[1].confirmItemInfo(text: amount),
                             des.inputs[2].confirmItemInfo(text: block.data?.toAccountBlockNote ?? "")
                ]
                return Promise.value(BifrostConfirmInfo(title: title, items: items))
            case .crossChainTransfer:

                guard let data = block.data, data.count > 3 else { return Promise(error: ConfirmError.InvalidData) }
                let type = data[2]

                let address: String
                if type == 0x00 {
                    guard let a = String(bytes: data[3...], encoding: .utf8) else { return Promise(error: ConfirmError.InvalidData) }
                    address = a
                } else if type == 0x01 {
                    let addressSize = Int(UInt8(data[3]))
                    let addressOffset: Int = 3 + 1
                    guard data.count > addressOffset + addressSize + 1 else { return Promise(error: ConfirmError.InvalidData) }
                    guard let a = String(bytes: data[addressOffset..<addressOffset + addressSize], encoding: .utf8) else { return Promise(error: ConfirmError.InvalidData) }
                    let labelSize = Int(data[Int(addressOffset + addressSize)])
                    let labelOffset: Int = addressOffset + addressSize + 1
                    guard data.count == labelOffset + labelSize else { return Promise(error: ConfirmError.InvalidData) }
                    guard let l = String(bytes: data[labelOffset..<labelOffset + labelSize], encoding: .utf8) else { return Promise(error: ConfirmError.InvalidData) }
                    address = "\(a) \(l)"
                } else {
                    return Promise(error: ConfirmError.InvalidData)
                }

                let amount = "\(block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
                let items = [des.inputs[0].confirmItemInfo(text: amount),
                             des.inputs[1].confirmItemInfo(text: address)
                ]
                return Promise.value(BifrostConfirmInfo(title: title, items: items))
            }
        }
    }

    enum BuildInContract {

        case register
        case registerUpdate
        case cancelRegister
        case extractReward

        case vote
        case cancelVote
        case pledge
        case cancelPledge
        case coin
//        case cancelCoin

        case dexDeposit
        case dexWithdraw
        case dexPost
        case dexCancel

        fileprivate static let dataPrefixMap: [String: BuildInContract] = [
            "f29c6ce2": .register,
            "3b7bdf74": .registerUpdate,
            "60862fe2": .cancelRegister,
            "ce1f27a7": .extractReward,
            "fdc17f25": .vote,
            "a629c531": .cancelVote,
            "8de7dcfd": .pledge,
            "9ff9c7b6": .cancelPledge,
            "cbf0e4fa": .coin,
//            "7d925ef1": .cancelCoin,
            "9dfb67ff": .dexDeposit,
            "cc329169": .dexWithdraw,
            "147927ec": .dexPost,
            "b251adc5": .dexCancel,
        ]

        fileprivate static let dexFundContractAddress = "vite_0000000000000000000000000000000000000006e82b8ba657"
        fileprivate static let dexTradeContractAddress = "vite_00000000000000000000000000000000000000079710f19dc7"

        fileprivate static let typeToAddressMap: [BuildInContract: String] = [
            .register: ViteWalletConst.ContractAddress.consensus.rawValue,
            .registerUpdate: ViteWalletConst.ContractAddress.consensus.rawValue,
            .cancelRegister: ViteWalletConst.ContractAddress.consensus.rawValue,
            .extractReward: ViteWalletConst.ContractAddress.consensus.rawValue,
            .vote: ViteWalletConst.ContractAddress.consensus.rawValue,
            .cancelVote: ViteWalletConst.ContractAddress.consensus.rawValue,
            .pledge: ViteWalletConst.ContractAddress.pledge.rawValue,
            .cancelPledge: ViteWalletConst.ContractAddress.pledge.rawValue,
            .coin: ViteWalletConst.ContractAddress.coin.rawValue,
//            .cancelCoin: ViteWalletConst.ContractAddress.coin.rawValue,
            .dexDeposit: dexFundContractAddress,
            .dexWithdraw: dexFundContractAddress,
            .dexPost: dexFundContractAddress,
            .dexCancel: dexTradeContractAddress,
        ]

        fileprivate static let AbiMap: [BuildInContract: String] = [
            .register: "{\"type\":\"function\",\"name\":\"Register\", \"inputs\":[{\"name\":\"gid\",\"type\":\"gid\"},{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"nodeAddr\",\"type\":\"address\"}]}",
            .registerUpdate: "{\"type\":\"function\",\"name\":\"UpdateRegistration\",\"inputs\":[{\"name\":\"gid\",\"type\":\"gid\"},{\"Name\":\"name\",\"type\":\"string\"},{\"name\":\"nodeAddr\",\"type\":\"address\"}]}",
            .cancelRegister: "{\"type\":\"function\",\"name\":\"CancelRegister\",\"inputs\":[{\"name\":\"gid\",\"type\":\"gid\"},{\"name\":\"name\",\"type\":\"string\"}]}",
            .extractReward: "{\"type\":\"function\",\"name\":\"Reward\",\"inputs\":[{\"name\":\"gid\",\"type\":\"gid\"},{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"beneficialAddr\",\"type\":\"address\"}]}",
            .vote: "{\"type\":\"function\",\"name\":\"Vote\", \"inputs\":[{\"name\":\"gid\",\"type\":\"gid\"},{\"name\":\"nodeName\",\"type\":\"string\"}]}",
            .cancelVote: "{\"type\":\"function\",\"name\":\"CancelVote\",\"inputs\":[{\"name\":\"gid\",\"type\":\"gid\"}]}",
            .pledge: "{\"type\":\"function\",\"name\":\"Pledge\", \"inputs\":[{\"name\":\"beneficial\",\"type\":\"address\"}]}",
            .cancelPledge: "{\"type\":\"function\",\"name\":\"CancelPledge\",\"inputs\":[{\"name\":\"beneficial\",\"type\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\"}]}",
            .dexDeposit: "{\"type\":\"function\",\"name\":\"DexFundUserDeposit\",\"inputs\":[]}",
            .coin: "{\"type\":\"function\",\"name\":\"Mint\",\"inputs\":[{\"name\":\"isReIssuable\",\"type\":\"bool\"},{\"name\":\"tokenName\",\"type\":\"string\"},{\"name\":\"tokenSymbol\",\"type\":\"string\"},{\"name\":\"totalSupply\",\"type\":\"uint256\"},{\"name\":\"decimals\",\"type\":\"uint8\"},{\"name\":\"maxSupply\",\"type\":\"uint256\"},{\"name\":\"ownerBurnOnly\",\"type\":\"bool\"}]}",
            .dexWithdraw: "{\"type\":\"function\",\"name\":\"DexFundUserWithdraw\",\"inputs\":[{\"name\":\"token\",\"type\":\"tokenId\"},{\"name\":\"amount\",\"type\":\"uint256\"}]}",
            .dexPost: "{\"type\":\"function\",\"name\":\"DexFundNewOrder\",\"inputs\":[{\"name\":\"tradeToken\",\"type\":\"tokenId\"},{\"name\":\"quoteToken\",\"type\":\"tokenId\"},{\"name\":\"side\",\"type\":\"bool\"},{\"name\":\"orderType\",\"type\":\"uint8\"},{\"name\":\"price\",\"type\":\"string\"},{\"name\":\"quantity\",\"type\":\"uint256\"}]}",
            .dexCancel: "{\"type\":\"function\",\"name\":\"DexTradeCancelOrder\",\"inputs\":[{\"name\":\"orderId\",\"type\":\"bytes\"}]}",
        ]
        fileprivate static let DesMap: [BuildInContract: String] = [
            .register: "{\"function\":{\"name\":{\"base\":\"Register SBP\",\"zh\":\"注册 SBP\"}},\"inputs\":[{\"name\":{\"base\":\"SBP Name\",\"zh\":\"SBP 名称\"}},{\"name\":{\"base\":\"Amount\",\"zh\":\"抵押金额\"}}]}",
            .registerUpdate: "{\"function\":{\"name\":{\"base\":\"Update SBP\",\"zh\":\"更新 SBP\"}},\"inputs\":[{\"name\":{\"base\":\"Update Address\",\"zh\":\"更新地址\"}}]}",
            .cancelRegister: "{\"function\":{\"name\":{\"base\":\"Revoke SBP Registration\",\"zh\":\"撤销 SBP 注册\"}},\"inputs\":[{\"name\":{\"base\":\"SBP Name\",\"zh\":\"SBP名称\"}}]}",
            .extractReward: "{\"function\":{\"name\":{\"base\":\"Claim Rewards\",\"zh\":\"提取奖励\"}},\"inputs\":[{\"name\":{\"base\":\"Recipient Address\",\"zh\":\"收款地址\"}}]}",
            .vote: "{\"function\":{\"name\":{\"base\":\"Vote\",\"zh\":\"投票\"}},\"inputs\":[{\"name\":{\"base\":\"SBP Candidates\",\"zh\":\"投票节点名称\"}},{\"name\":{\"base\":\"Votes\",\"zh\":\"投票量\"}}]}",
            .cancelVote: "{\"function\":{\"name\":{\"base\":\"Revoke Voting\",\"zh\":\"撤销投票\"}},\"inputs\":[{\"name\":{\"base\":\"Votes Revoked\",\"zh\":\"撤销投票量\"}}]}",
            .pledge: "{\"function\":{\"name\":{\"base\":\"Acquire Quota\",\"zh\":\"获取配额\"}},\"inputs\":[{\"name\":{\"base\":\"Amount\",\"zh\":\"抵押金额\"}},{\"name\":{\"base\":\"Beneficiary Address\",\"zh\":\"配额受益地址\"}}]}",
            .cancelPledge: "{\"function\":{\"name\":{\"base\":\"Retrieve Staking for Quota\",\"zh\":\"取回配额抵押\"}},\"inputs\":[{\"name\":{\"base\":\"Amount\",\"zh\":\"取回抵押金额\"}}]}",
            .coin: "{\"function\":{\"name\":{\"base\":\"Token Issuance\",\"zh\":\"铸币\"}},\"inputs\":[{\"name\":{\"base\":\"Token Name\",\"zh\":\"代币全称\"}},{\"name\":{\"base\":\"Token Symbol\",\"zh\":\"代币简称\"}},{\"name\":{\"base\":\"Total Supply\",\"zh\":\"总发行量\"}},{\"name\":{\"base\":\"Decimals\",\"zh\":\"价格精度\"}}]}",
            .dexDeposit: "{\"function\":{\"name\":{\"base\":\"ViteX Deposit\",\"zh\":\"交易所充值\"}},\"inputs\":[{\"name\":{\"base\":\"Amount\",\"zh\":\"充值金额\"},\"style\":{\"textColor\":\"007AFF\",\"backgroundColor\":\"007AFF0F\"}}]}",
            .dexWithdraw: "{\"function\":{\"name\":{\"base\":\"ViteX Withdrawal\",\"zh\":\"交易所提现\"}},\"inputs\":[{\"name\":{\"base\":\"Amount\",\"zh\":\"提现金额\"},\"style\":{\"textColor\":\"007AFF\",\"backgroundColor\":\"007AFF0F\"}}]}",
            .dexPost: "{\"function\":{\"name\":{\"base\":\"Place Order on ViteX\",\"zh\":\"交易所挂单\"}},\"inputs\":[{\"name\":{\"base\":\"Order Type\",\"zh\":\"订单类型\"},\"style\":{\"textColor\":\"5BC500\",\"backgroundColor\":\"007AFF0F\"}},{\"name\":{\"base\":\"Market\",\"zh\":\"市场\"}},{\"name\":{\"base\":\"Price\",\"zh\":\"价格\"}},{\"name\":{\"base\":\"Amount\",\"zh\":\"数量\"}}]}",
            .dexCancel: "{\"function\":{\"name\":{\"base\":\"Cancel Order on ViteX\",\"zh\":\"交易所撤单\"}},\"inputs\":[{\"name\":{\"base\":\"Order ID\",\"zh\":\"订单 ID\"}},{\"name\":{\"base\":\"Order Type\",\"zh\":\"订单类型\"},\"style\":{\"textColor\":\"5BC500\",\"backgroundColor\":\"007AFF0F\"}},{\"name\":{\"base\":\"Market\",\"zh\":\"市场\"}},{\"name\":{\"base\":\"Price\",\"zh\":\"价格\"}}]}",
        ]

        func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
            let account = HDWalletManager.instance.account!
            let abi = BuildInContract.AbiMap[self]!
            let des = VBViteSendTx.Description(JSONString: BuildInContract.DesMap[self]!)!
            let title = des.function.title ?? ""
            let block = sendTx.block!

            switch self {
            case .register:
                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let gidValue = values[0] as? ABIGIdValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    guard let nameValue = values[1] as? ABIStringValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    guard let addressValue = values[2] as? ABIAddressValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    let amount = "\(block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
                    let items = [des.inputs[0].confirmItemInfo(text: nameValue.toString()),
                                 des.inputs[1].confirmItemInfo(text: amount)
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .registerUpdate:
                guard block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }

                do {

                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let gidValue = values[0] as? ABIGIdValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    guard let nameValue = values[1] as? ABIStringValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    guard let addressValue = values[2] as? ABIAddressValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    let items = [des.inputs[0].confirmItemInfo(text: addressValue.toString()),
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .cancelRegister:
                guard block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }

                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let gidValue = values[0] as? ABIGIdValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    guard let nameValue = values[1] as? ABIStringValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    let items = [des.inputs[0].confirmItemInfo(text: nameValue.toString())
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .extractReward:
                guard block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }

                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let gidValue = values[0] as? ABIGIdValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    guard let nameValue = values[1] as? ABIStringValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    guard let addressValue = values[2] as? ABIAddressValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    let items = [des.inputs[0].confirmItemInfo(text: addressValue.toString())
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .vote:
                guard block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }

                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let gidValue = values[0] as? ABIGIdValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    guard let nameValue = values[1] as? ABIStringValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    let balance = ViteBalanceInfoManager.instance.balanceInfo(forViteTokenId: ViteWalletConst.viteToken.id)?.balance ?? Amount(0)
                    let items = [des.inputs[0].confirmItemInfo(text: nameValue.toString()),
                                 des.inputs[1].confirmItemInfo(text: balance.amountFullWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals))
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .cancelVote:
                guard block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }

                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let gidValue = values[0] as? ABIGIdValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    let balance = ViteBalanceInfoManager.instance.balanceInfo(forViteTokenId: ViteWalletConst.viteToken.id)?.balance ?? Amount(0)
                    let items = [des.inputs[0].confirmItemInfo(text: balance.amountFullWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals))
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .pledge:
                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let value = values[0] as? ABIAddressValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    let amount = "\(block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
                    let items = [des.inputs[0].confirmItemInfo(text: amount),
                                 des.inputs[1].confirmItemInfo(text: value.toString())
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .cancelPledge:
                guard block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }

                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let addressValue = values[0] as? ABIAddressValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let amountValue = values[1] as? ABIUnsignedIntegerValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    let amount = "\(Amount(amountValue.toBigUInt()).amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
                    let items = [des.inputs[0].confirmItemInfo(text: amount)
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .coin:
                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let isReIssuableValue = values[0] as? ABIBoolValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let tokenNameValue = values[1] as? ABIStringValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let tokenSymbolValue = values[2] as? ABIStringValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let totalSupplyValue = values[3] as? ABIUnsignedIntegerValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let decimalsValue = values[4] as? ABIUnsignedIntegerValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let maxSupplyValue = values[5] as? ABIUnsignedIntegerValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let ownerBurnOnlyValue = values[6] as? ABIBoolValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }


                    let items = [des.inputs[0].confirmItemInfo(text: tokenNameValue.toString()),
                                 des.inputs[1].confirmItemInfo(text: tokenSymbolValue.toString()),
                                 des.inputs[2].confirmItemInfo(text: maxSupplyValue.toString()),
                                 des.inputs[3].confirmItemInfo(text: decimalsValue.toString())
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .dexDeposit:
                let amount = "\(block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
                let items = [des.inputs[0].confirmItemInfo(text: amount)
                ]
                return Promise.value(BifrostConfirmInfo(title: title, items: items))
            case .dexWithdraw:
                guard block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }

                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let tokenIdValue = values[0] as? ABITokenIdValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let amountValue = values[1] as? ABIUnsignedIntegerValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    return ViteNode.mintage.getToken(tokenId: tokenIdValue.toString()).then({ (token) -> Promise<BifrostConfirmInfo> in
                        let amount = "\(Amount(amountValue.toBigUInt()).amountFullWithGroupSeparator(decimals: token.decimals)) \(token.symbol)"
                        let items = [des.inputs[0].confirmItemInfo(text: amount)
                        ]
                        return Promise.value(BifrostConfirmInfo(title: title, items: items))
                    })
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .dexPost:
                guard block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }

                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let tradeTokenIdValue = values[0] as? ABITokenIdValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let quoteTokenIdValue = values[1] as? ABITokenIdValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let sideValue = values[2] as? ABIBoolValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let orderTypeValue = values[3] as? ABIUnsignedIntegerValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let priceValue = values[4] as? ABIStringValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    guard let quantityValue = values[5] as? ABIUnsignedIntegerValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    return when(fulfilled: ViteNode.mintage.getToken(tokenId: tradeTokenIdValue.toString()),
                                ViteNode.mintage.getToken(tokenId: quoteTokenIdValue.toString())).then { (tradeToken, quoteToken) -> Promise<BifrostConfirmInfo> in
                                    let orderType: String
                                    let textColor: UIColor
                                    if sideValue.toBool() {
                                        let type = LocalizationService.sharedInstance.currentLanguage == .chinese ? "卖": "Sell"
                                        orderType = "\(type) \(tradeToken.uniqueSymbol)"
                                        textColor = UIColor(netHex: 0xFF0008)
                                    } else {
                                        let type = LocalizationService.sharedInstance.currentLanguage == .chinese ? "买": "Buy"
                                        orderType = "\(type) \(tradeToken.uniqueSymbol)"
                                        textColor = UIColor(netHex: 0x5BC500)
                                    }

                                    let market = "\(tradeToken.uniqueSymbol)/\(quoteToken.uniqueSymbol)"
                                    let price = "\(priceValue.toString()) \(quoteToken.symbol)"
                                    let quantity = "\(Amount(quantityValue.toBigUInt()).amountFull(decimals: tradeToken.decimals)) \(tradeToken.symbol)"
                                    let items = [des.inputs[0].confirmItemInfo(text: orderType, textColor: textColor),
                                                 des.inputs[1].confirmItemInfo(text: market),
                                                 des.inputs[2].confirmItemInfo(text: price),
                                                 des.inputs[3].confirmItemInfo(text: quantity)
                                    ]
                                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                    }
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            case .dexCancel:
                guard block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }

                do {

                    guard let e = sendTx.extend, let json = try? JSON(e), json["type"].string == "dexCancel",
                        let side = json["side"].int ,
                        let tradeTokenSymbol = json["tradeTokenSymbol"].string ,
                        let quoteTokenSymbol = json["quoteTokenSymbol"].string ,
                        let price = json["price"].string else {
                            return Promise(error: ConfirmError.InvalidExtend)
                    }

                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let orderIdValue = values[0] as? ABIBytesValue else {
                        return Promise(error: ConfirmError.InvalidData)
                    }
                    let rawId = orderIdValue.toString()
                    guard rawId.count == 44 else { return Promise(error: ConfirmError.InvalidData) }
                    let id = "\(rawId.prefix(8))...\(rawId.suffix(8))"

                    let orderType: String
                    let textColor: UIColor
                    if side == 1 {
                        let type = LocalizationService.sharedInstance.currentLanguage == .chinese ? "卖": "Sell"
                        orderType = "\(type) \(tradeTokenSymbol)"
                        textColor = UIColor(netHex: 0xFF0008)
                    } else if side == 0 {
                        let type = LocalizationService.sharedInstance.currentLanguage == .chinese ? "买": "Buy"
                        orderType = "\(type) \(tradeTokenSymbol)"
                        textColor = UIColor(netHex: 0x5BC500)
                    } else {
                        return Promise(error: ConfirmError.InvalidData)
                    }

                    let market = "\(tradeTokenSymbol)/\(quoteTokenSymbol)"
                    let items = [des.inputs[0].confirmItemInfo(text: id),
                                 des.inputs[1].confirmItemInfo(text: orderType, textColor: textColor),
                                 des.inputs[2].confirmItemInfo(text: market),
                                 des.inputs[3].confirmItemInfo(text: price)
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfirmError.InvalidData)
                }
            }
        }
    }
}
