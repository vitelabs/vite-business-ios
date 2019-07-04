//
//  WCEthereumSendTransaction.swift
//  WalletConnect
//
//  Created by Tao Xu on 4/3/19.
//  Copyright © 2019 Trust. All rights reserved.
//

import Foundation
import ObjectMapper
import ViteWallet
import BigInt
import enum Result.Result
import PromiseKit

public struct VBJSONRPCRequest<T: Mappable>: Mappable {
    public var id: Int64!
    public var jsonrpc: String!
    public var method: String!
    public var params: [T]!

    public init?(map: Map) {
//        guard let id = map.JSON["id"] as? Int64 else {
//            return nil
//        }

        guard let jsonrpc = map.JSON["jsonrpc"] as? String, jsonrpc == "2.0" else {
            return nil
        }

        guard let method = map.JSON["method"] as? String, !method.isEmpty else {
            return nil
        }

//        guard let params = map.JSON["params"] as? [T] else {
//            return nil
//        }
    }

    public mutating func mapping(map: Map) {
        id <- map["id"]
        jsonrpc <- map["jsonrpc"]
        method <- map["method"]
        params <- map["params"]
    }
}

struct VBJSONRPCResponse<T: Mappable>: Mappable {

    public var jsonrpc = "2.0"
    public var id: Int64!
    public var result: T!

    init(id: Int64, result: T) {
        self.id = id
        self.result = result
    }

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        jsonrpc <- map["jsonrpc"]
        result <- map["result"]
    }
}

public struct VBViteTxConfirmParam: Mappable {
    public var accountBlock: AccountBlock?
    public var errorMsg: String?

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        accountBlock <- map["accountBlock"]
        errorMsg <- map["errorMsg"]
    }
}

public struct VBViteSendTx: Mappable {

    public var block: Block!
    public var abi: String?
    public var description: Description?

    public init(block: Block, abi: String?, description: Description?) {
        self.block = block
        self.abi = abi
        self.description = description
    }

    public init?(map: Map) {
        guard let json = map.JSON["block"] as? Dictionary<String, Any>,
            let _ = Block(JSON: json) else {
                return nil
        }
    }

    public mutating func mapping(map: Map) {
        block <- map["block"]
        abi <- map["abi"]
        description <- map["description"]
    }

    public struct Block: Mappable {
        public var toAddress: ViteAddress!
        public var tokenId: ViteTokenId!
        public var amount: Amount!
        public var data: Data?

        public init?(map: Map) {
            guard let toAddress = map.JSON["toAddress"] as? ViteAddress, toAddress.isViteAddress else {
                return nil
            }

            guard let tokenId = map.JSON["tokenId"] as? ViteTokenId, tokenId.isViteTokenId else {
                return nil
            }

            guard let amount = map.JSON["amount"] as? String, let _ = BigInt(amount) else {
                return nil
            }

            if let data = map.JSON["data"] as? String {
                guard let _ = Data(base64Encoded: data) else {
                    return nil
                }
            }
        }

        public mutating func mapping(map: Map) {
            toAddress <- map["toAddress"]
            tokenId <- map["tokenId"]
            amount <- (map["amount"], JSONTransformer.balance)
            data <- (map["data"], JSONTransformer.dataToBase64)
        }
    }

    public struct Description: Mappable {
        public var function: InputDescription = InputDescription()
        public var inputs: [InputDescription] = []

        init(function: InputDescription, inputs: [InputDescription]) {
            self.function = function
            self.inputs = inputs
        }

        public init?(map: Map) { }
        public mutating func mapping(map: Map) {
            function <- map["function"]
            inputs <- map["inputs"]
        }
    }


    public struct InputDescription: Mappable {

        public struct Style: Mappable {
            public var textColor: UIColor?
            public var backgroundColor: UIColor?

            public init?(map: Map) {}

            public mutating func mapping(map: Map) {
                textColor <- (map["textColor"], type(of: self).TransformOfColor)
                backgroundColor <- (map["backgroundColor"], type(of: self).TransformOfColor)
            }

            static let TransformOfColor = TransformOf<UIColor, String>(fromJSON: { (string) -> UIColor? in
                guard let string = string, let color = UIColor(hexa: string) else { return nil }
                return color
            }, toJSON: { (color) -> String? in
                guard let color = color else { return nil }
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                var a: CGFloat = 0
                color.getRed(&r, green: &g, blue: &b, alpha: &a)
                let rInt = Int(r * 255) << 24
                let gInt = Int(g * 255) << 16
                let bInt = Int(b * 255) << 8
                let aInt = Int(a * 255)
                let rgba = rInt | gInt | bInt | aInt
                return String(format:"%08x", rgba)
            })
        }

        fileprivate var name: [String: String] = [:]
        fileprivate var style: Style?

        init() {}

        public init?(map: Map) { }

        mutating public func mapping(map: Map) {
            name <- map["name"]
            style <- map["style"]
        }

        public var title: String? {
            let key = LocalizationService.sharedInstance.currentLanguage == .chinese ? "zh": "base"
            return name[key]
        }

        public func confrimItemInfo(text: String) -> BifrostConfrimItemInfo {
            return BifrostConfrimItemInfo(title: title ?? "", text: text, textColor: style?.textColor, backgroundColor: style?.backgroundColor)
        }
    }
}

public extension VBViteSendTx {
    public enum ConfrimError: Error {
        case InvalidToAddress
        case InvalidData
        case unknown(String)
        case notVoteYet
    }

    public func generateConfrimInfo() -> Promise<(BifrostConfrimInfo, TokenInfo)> {
        let block = self.block!

        guard let addressType = block.toAddress.viteAddressType else {
            return Promise(error: ConfrimError.InvalidToAddress)
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
            }.then({ (tokenInfo) -> Promise<(BifrostConfrimInfo, TokenInfo)> in

                switch addressType {
                case .user:
                    if let data = block.data {
                        guard data.contentTypeInUInt16 == AccountBlockDataContentType.utf8string.rawValue else {
                            throw ConfrimError.InvalidData
                        }
                    }

                    return BuildInContract.transfer.confrimInfo(block, tokenInfo).map { ($0, tokenInfo) }
                case .contract:
                    if let data = block.data,
                        data.count >= 4,
                        let type = BuildInContract.dataPrefixMap[data[0..<4].toHexString()],
                        BuildInContract.typeToAddressMap[type] == block.toAddress {
                        return type.confrimInfo(block, tokenInfo).map { ($0, tokenInfo) }
                    } else {
                        fatalError()
                    }
                }
            })
    }
}

extension VBViteSendTx {

    enum BuildInContract {

        fileprivate static let dataPrefixMap: [String: BuildInContract] = [
//            "f29c6ce2": .register,
//            "3b7bdf74": .registerUpdate,
//            "60862fe2": .cancelRegister,
//            "ce1f27a7": .extractReward,
            "fdc17f25": .vote,
            "a629c531": .cancelVote,
//            "8de7dcfd": .pledge,
//            "9ff9c7b6": .cancelPledge,
//            "27ad872e": .coin,
//            "7d925ef1": .cancelCoin,
        ]

        fileprivate static let typeToAddressMap: [BuildInContract: String] = [
//            .register: ViteWalletConst.ContractAddress.consensus.rawValue,
//            .registerUpdate: ViteWalletConst.ContractAddress.consensus.rawValue,
//            .cancelRegister: ViteWalletConst.ContractAddress.consensus.rawValue,
//            .extractReward: ViteWalletConst.ContractAddress.consensus.rawValue,
            .vote: ViteWalletConst.ContractAddress.consensus.rawValue,
            .cancelVote: ViteWalletConst.ContractAddress.consensus.rawValue,
//            .pledge: ViteWalletConst.ContractAddress.pledge.rawValue,
//            .cancelPledge: ViteWalletConst.ContractAddress.pledge.rawValue,
//            .coin: ViteWalletConst.ContractAddress.coin.rawValue,
//            .cancelCoin: ViteWalletConst.ContractAddress.coin.rawValue,
        ]

        fileprivate static let AbiMap = [
            BuildInContract.transfer: "",
            BuildInContract.vote: "{\"type\":\"function\",\"name\":\"Vote\", \"inputs\":[{\"name\":\"gid\",\"type\":\"gid\"},{\"name\":\"nodeName\",\"type\":\"string\"}]}",
            BuildInContract.cancelVote: "{\"type\":\"function\",\"name\":\"CancelVote\",\"inputs\":[{\"name\":\"gid\",\"type\":\"gid\"}]}",
        ]
        fileprivate static let DesMap = [
            BuildInContract.transfer: "{\"function\":{\"name\":{\"base\":\"转账\",\"zh\":\"转账\"}},\"inputs\":[{\"name\":{\"base\":\"交易地址\",\"zh\":\"交易地址\"}},{\"name\":{\"base\":\"交易金额\",\"zh\":\"交易金额\"},\"style\":{\"textColor\":\"007AFF\",\"backgroundColor\":\"007AFF0F\"}},{\"name\":{\"base\":\"币种\",\"zh\":\"币种\"}},{\"name\":{\"base\":\"备注信息\",\"zh\":\"备注信息\"}}]}",
            BuildInContract.vote: "{\"function\":{\"name\":{\"base\":\"投票\",\"zh\":\"投票\"}},\"inputs\":[{\"name\":{\"base\":\"投票节点名称\",\"zh\":\"投票节点名称\"}},{\"name\":{\"base\":\"投票量\",\"zh\":\"投票量\"}}]}",
            BuildInContract.cancelVote: "{\"function\":{\"name\":{\"base\":\"撤销投票\",\"zh\":\"撤销投票\"}},\"inputs\":[{\"name\":{\"base\":\"投票节点名称\",\"zh\":\"投票节点名称\"}},{\"name\":{\"base\":\"撤销投票量\",\"zh\":\"撤销投票量\"}}]}",
        ]

        case transfer
        case vote
        case cancelVote

        func confrimInfo(_ block: Block, _ tokenInfo: TokenInfo) -> Promise<BifrostConfrimInfo> {
            let account = HDWalletManager.instance.account!
            let abi = BuildInContract.AbiMap[self]!
            let des = Description(JSONString: BuildInContract.DesMap[self]!)!
            let title = des.function.title ?? ""

            switch self {
            case .transfer:
                let items = [des.inputs[0].confrimItemInfo(text: block.toAddress),
                             des.inputs[1].confrimItemInfo(text: block.amount.amountFull(decimals: tokenInfo.decimals)),
                             des.inputs[2].confrimItemInfo(text: tokenInfo.symbol),
                             des.inputs[3].confrimItemInfo(text: block.data?.toAccountBlockNote ?? "")
                ]
                return Promise.value(BifrostConfrimInfo(title: title, items: items))
            case .vote:
                do {
                    let values = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    guard let name = values[1] as? ABIStringValue else {
                        return Promise(error: ConfrimError.InvalidData)
                    }
                    let balance = ViteBalanceInfoManager.instance.balanceInfo(forViteTokenId: ViteWalletConst.viteToken.id)?.balance ?? Amount(0)
                    let items = [des.inputs[0].confrimItemInfo(text: name.toString()),
                                 des.inputs[1].confrimItemInfo(text: balance.amountFull(decimals: ViteWalletConst.viteToken.decimals))
                    ]
                    return Promise.value(BifrostConfrimInfo(title: title, items: items))
                } catch {
                    return Promise(error: ConfrimError.InvalidData)
                }
            case .cancelVote:
                do {
                    let _ = try ABI.Decoding.decodeParameters(block.data!, abiString: abi)
                    let balance = ViteBalanceInfoManager.instance.balanceInfo(forViteTokenId: ViteWalletConst.viteToken.id)?.balance ?? Amount(0)
                    return ViteNode.vote.info.getVoteInfo(gid: ViteWalletConst.ConsensusGroup.snapshot.id, address: account.address).then({ (vi) -> Promise<BifrostConfrimInfo> in
                        guard let voteInfo = vi else {
                            throw ConfrimError.notVoteYet
                        }

                        let items = [des.inputs[0].confrimItemInfo(text: voteInfo.nodeName ?? ""),
                                     des.inputs[1].confrimItemInfo(text: balance.amountFull(decimals: ViteWalletConst.viteToken.decimals))
                        ]
                        return Promise.value(BifrostConfrimInfo(title: title, items: items))
                    })
                } catch {
                    return Promise(error: ConfrimError.InvalidData)
                }
            }
        }
    }

//    struct buildIn {
//
//        static let ABIs = [
//            ""
//        ]
//        static let Dess = [
//        "{\"function\":{\"name\":{\"base\":\"转账\",\"zh\":\"转账\"}},\"inputs\":[{\"name\":{\"base\":\"交易地址\",\"zh\":\"交易地址\"}},{\"name\":{\"base\":\"交易金额\",\"zh\":\"交易金额\"},\"style\":{\"textColor\":\"007AFF\",\"backgroundColor\":\"007AFF0F\"}},{\"name\":{\"base\":\"币种\",\"zh\":\"币种\"}},{\"name\":{\"base\":\"备注信息\",\"zh\":\"备注信息\"}}]}"
//        ]
//
//
//        struct AbiAndDes {
//            let confrimInfo: (Block) -> BifrostConfrimInfo
//        }
//
//        static let transfer = AbiAndDes { (block) -> BifrostConfrimInfo in
//            let des = Description(JSONString: buildIn.Dess[0])!
//
//            let items = [des.inputs[0].confrimItemInfo(text: block.toAddress),
//                         des.inputs[1].confrimItemInfo(text: block.amount.amountFull(decimals: block.tokenInfo.decimals)),
//                         des.inputs[2].confrimItemInfo(text: block.tokenInfo.symbol),
//                         des.inputs[3].confrimItemInfo(text: block.data?.toAccountBlockNote ?? "")
//            ]
//            return BifrostConfrimInfo(title: des.function.title ?? "", items: items)
//        }
//
//    }

}


