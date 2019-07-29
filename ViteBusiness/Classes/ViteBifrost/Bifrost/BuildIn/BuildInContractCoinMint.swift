//
//  BuildInContractCoinMint.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractCoinMint: BuildInContractProtocol {

    let abi = ABI.BuildIn.coinMint

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard let fee = sendTx.block.fee else { return Promise(error: ConfirmError.InvalidFee) }
        guard let account = HDWalletManager.instance.account else { return Promise(error: ConfirmError.unknown("not logon")) }

        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
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
            let maxSupplyString = Amount(maxSupplyValue.toBigUInt()).amountFullWithGroupSeparator(decimals: Int(decimalsValue.toBigUInt()))
            let isReIssuable = isReIssuableValue.toBool()
            let isReIssuableString = isReIssuable ? R.string.localizable.buildinCoinIssuanceItem5YesValue() : R.string.localizable.buildinCoinIssuanceItem5NoValue()


            let inputs = [
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinIssuanceItem0Title()),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinIssuanceItem1Title()),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinIssuanceItem2Title()),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinIssuanceItem3Title()),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinIssuanceItem4Title()),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinIssuanceItem5Title()),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinIssuanceItem6Title()),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinIssuanceItem7Title(), style: VBViteSendTx.InputDescription.Style.blue),
            ]

            var items: [BifrostConfirmItemInfo] = [
                inputs[0].confirmItemInfo(text: account.address),
                inputs[1].confirmItemInfo(text: tokenNameValue.toString()),
                inputs[2].confirmItemInfo(text: tokenSymbolValue.toString()),
                inputs[3].confirmItemInfo(text: totalSupplyString),
                inputs[4].confirmItemInfo(text: decimalsValue.toString()),
                inputs[5].confirmItemInfo(text: isReIssuableString)
            ]

            if isReIssuable {
                items.append(inputs[6].confirmItemInfo(text: maxSupplyString))
            }

            items.append(inputs[7].confirmItemInfo(text: feeString))
            return Promise.value(BifrostConfirmInfo(title: R.string.localizable.buildinCoinIssuanceFunctionTitle(),
                                                    items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
