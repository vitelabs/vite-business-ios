//
//  BuildInContractDexNewMarket.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit
import SwiftyJSON

struct BuildInContractDexNewMarket: BuildInContractProtocol {

    let abi =  ABI.BuildIn.dexNewMarket
    let description = VBViteSendTx.Description(
        function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexOpenTradingPairFunctionTitle()),
        inputs: [
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexOpenTradingPairItem0Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexOpenTradingPairItem1Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexOpenTradingPairItem2Title()),
        ])

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        guard sendTx.block.tokenId == ViteWalletConst.viteToken.id else { return Promise(error: ConfirmError.InvalidTokenId) }
        let title = description.function.title ?? ""
        do {
            guard let e = sendTx.extend, let json = try? JSON(e),
                json["type"].string == "dexNewMarket",
                let fee = json["fee"].string else {
                    return Promise(error: ConfirmError.InvalidExtend)
            }

            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let tradeTokenIdValue = values[0] as? ABITokenIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let quoteTokenIdValue = values[1] as? ABITokenIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let account = HDWalletManager.instance.account else {
                return Promise(error: ConfirmError.unknown("not logon"))
            }

            return when(fulfilled: ViteNode.mintage.getToken(tokenId: tradeTokenIdValue.toString()),
                        ViteNode.mintage.getToken(tokenId: quoteTokenIdValue.toString())).then { (tradeToken, quoteToken) -> Promise<BifrostConfirmInfo> in

                            let market = "\(tradeToken.uniqueSymbol)/\(quoteToken.uniqueSymbol)"
                            let items = [
                                self.description.inputs[0].confirmItemInfo(text: market),
                                self.description.inputs[1].confirmItemInfo(text: account.address),
                                self.description.inputs[2].confirmItemInfo(text: fee),
                            ]
                            return Promise.value(BifrostConfirmInfo(title: title, items: items))
            }
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
