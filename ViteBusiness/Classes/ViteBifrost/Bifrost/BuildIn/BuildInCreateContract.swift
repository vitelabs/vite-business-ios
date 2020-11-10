//
//  BuildInCreateContract.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInCreateContract {

    static func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard let fee = sendTx.block.fee else { return Promise(error: ConfirmError.InvalidFee) }

        let amount = "\(sendTx.block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let feeString = "\(fee.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(ViteWalletConst.viteToken.symbol)"
        let addressItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostCreateContractTitleContractAddress(),
                                                 text: sendTx.block.toAddress)
        let amountItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostCreateContractTitleAmount(),
                                                 text: amount)
        let feeItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostCreateContractTitleFee(),
                                                 text: feeString)
        let dataItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostCreateContractTitleData(),
                                              text: sendTx.block.data?.toHexString() ?? "")

        return Promise.value(BifrostConfirmInfo(title: R.string.localizable.bifrostCreateContractTitle(), items: [addressItem, amountItem, feeItem, dataItem]))
    }
}
