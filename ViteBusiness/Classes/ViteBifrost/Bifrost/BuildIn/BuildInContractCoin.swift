//
//  BuildInContractCoin.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractCoin: BuildInContractProtocol {

    let functionSignatureHexString = "cbf0e4fa"
    let toAddress = ViteWalletConst.ContractAddress.coin.rawValue
    let abi = ABI.BuildIn.coin.rawValue
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Token Issuance\",\"zh\":\"铸币\"}},\"inputs\":[{\"name\":{\"base\":\"Token Name\",\"zh\":\"代币全称\"}},{\"name\":{\"base\":\"Token Symbol\",\"zh\":\"代币简称\"}},{\"name\":{\"base\":\"Total Supply\",\"zh\":\"总发行量\"}},{\"name\":{\"base\":\"Decimals\",\"zh\":\"价格精度\"}},{\"name\":{\"base\":\"Issuance Fee\",\"zh\":\"铸币费\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard let fee = sendTx.block.fee else { return Promise(error: ConfirmError.InvalidFee) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi)
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

            let feeString = "\(fee.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(ViteWalletConst.viteToken.symbol)"
            let totalSupplyString = Amount(totalSupplyValue.toBigUInt()).amountFullWithGroupSeparator(decimals: Int(decimalsValue.toBigUInt()))
            let items = [description.inputs[0].confirmItemInfo(text: tokenNameValue.toString()),
                         description.inputs[1].confirmItemInfo(text: tokenSymbolValue.toString()),
                         description.inputs[2].confirmItemInfo(text: totalSupplyString),
                         description.inputs[3].confirmItemInfo(text: decimalsValue.toString()),
                         description.inputs[4].confirmItemInfo(text: feeString)
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
