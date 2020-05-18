//
//  BuildInContractDexPost.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractDexPost: BuildInContractProtocol {

    let abi =  ABI.BuildIn.dexPlaceOrder
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Place Order on ViteX\",\"zh\":\"交易所挂单\"}},\"inputs\":[{\"name\":{\"base\":\"Order Type\",\"zh\":\"订单类型\"},\"style\":{\"textColor\":\"5BC500\",\"backgroundColor\":\"007AFF0F\"}},{\"name\":{\"base\":\"Market\",\"zh\":\"市场\"}},{\"name\":{\"base\":\"Price\",\"zh\":\"价格\"}},{\"name\":{\"base\":\"Amount\",\"zh\":\"数量\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
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

            return TokenInfoCacheService.instance.tokenInfos(forViteTokenIds: [tradeTokenIdValue.toString(),
                                                                               quoteTokenIdValue.toString()])
                .then { tokenInfos -> Promise<BifrostConfirmInfo> in
                    let tradeToken = tokenInfos[0].toViteToken()!
                    let quoteToken = tokenInfos[1].toViteToken()!
                    let orderType: String
                    let textColor: UIColor
                    if sideValue.toBool() {
                        let type = LocalizationService.sharedInstance.currentLanguage == .chinese ? "卖": "Sell"
                        orderType = "\(type) \(tradeToken.uniqueSymbol)"
                        textColor = UIColor(netHex: 0xFF0008)
                    } else {
                        let type = LocalizationService.sharedInstance.currentLanguage == .chinese ? "买": "Buy"
                        orderType = "\(type) \(tradeToken.uniqueSymbol)"
                        textColor = UIColor(netHex: 0x01D764)
                    }

                    let market = "\(tradeToken.uniqueSymbol)/\(quoteToken.uniqueSymbol)"
                    let price = "\(priceValue.toString()) \(quoteToken.symbol)"
                    let quantity = "\(Amount(quantityValue.toBigUInt()).amountFull(decimals: tradeToken.decimals)) \(tradeToken.symbol)"
                    let items = [self.description.inputs[0].confirmItemInfo(text: orderType,
                                                                            textColor: textColor,
                                                                            backgroundColor: UIColor(netHex: 0x007AFF, alpha: 0.06)),
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
