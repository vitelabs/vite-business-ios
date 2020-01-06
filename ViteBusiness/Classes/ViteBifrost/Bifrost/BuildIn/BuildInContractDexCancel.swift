//
//  BuildInContractDexCancel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit
import SwiftyJSON

struct BuildInContractDexCancel: BuildInContractProtocol {

    let abi =  ABI.BuildIn.dexCancelOrder
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Cancel Order on ViteX\",\"zh\":\"交易所撤单\"}},\"inputs\":[{\"name\":{\"base\":\"Order ID\",\"zh\":\"订单 ID\"}},{\"name\":{\"base\":\"Order Type\",\"zh\":\"订单类型\"},\"style\":{\"textColor\":\"5BC500\",\"backgroundColor\":\"007AFF0F\"}},{\"name\":{\"base\":\"Market\",\"zh\":\"市场\"}},{\"name\":{\"base\":\"Price\",\"zh\":\"价格\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {

            guard let e = sendTx.extend, let json = try? JSON(e), json["type"].string == "dexCancel",
                let side = json["side"].int ,
                let tradeTokenSymbol = json["tradeTokenSymbol"].string ,
                let quoteTokenSymbol = json["quoteTokenSymbol"].string ,
                let price = json["price"].string else {
                    return Promise(error: ConfirmError.InvalidExtend)
            }

            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let orderIdValue = values[0] as? ABIBytesValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            let rawId = orderIdValue.toHexString()
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
            let items = [description.inputs[0].confirmItemInfo(text: id),
                         description.inputs[1].confirmItemInfo(text: orderType, textColor: textColor),
                         description.inputs[2].confirmItemInfo(text: market),
                         description.inputs[3].confirmItemInfo(text: price)
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
