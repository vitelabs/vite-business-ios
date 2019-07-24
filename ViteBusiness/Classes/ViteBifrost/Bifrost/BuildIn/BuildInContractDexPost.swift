//
//  BuildInContractDexPost.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractDexPost: BuildInContractProtocol {

    let functionSignatureHexString = "147927ec"
    let toAddress = ViteWalletConst.ContractAddress.dexFund.rawValue
    let abi = "{\"type\":\"function\",\"name\":\"DexFundNewOrder\",\"inputs\":[{\"name\":\"tradeToken\",\"type\":\"tokenId\"},{\"name\":\"quoteToken\",\"type\":\"tokenId\"},{\"name\":\"side\",\"type\":\"bool\"},{\"name\":\"orderType\",\"type\":\"uint8\"},{\"name\":\"price\",\"type\":\"string\"},{\"name\":\"quantity\",\"type\":\"uint256\"}]}"
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Place Order on ViteX\",\"zh\":\"交易所挂单\"}},\"inputs\":[{\"name\":{\"base\":\"Order Type\",\"zh\":\"订单类型\"},\"style\":{\"textColor\":\"5BC500\",\"backgroundColor\":\"007AFF0F\"}},{\"name\":{\"base\":\"Market\",\"zh\":\"市场\"}},{\"name\":{\"base\":\"Price\",\"zh\":\"价格\"}},{\"name\":{\"base\":\"Amount\",\"zh\":\"数量\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi)
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
                            let items = [self.description.inputs[0].confirmItemInfo(text: orderType, textColor: textColor),
                                         self.description.inputs[1].confirmItemInfo(text: market),
                                         self.description.inputs[2].confirmItemInfo(text: price),
                                         self.description.inputs[3].confirmItemInfo(text: quantity)
                            ]
                            return Promise.value(BifrostConfirmInfo(title: title, items: items))
            }
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
