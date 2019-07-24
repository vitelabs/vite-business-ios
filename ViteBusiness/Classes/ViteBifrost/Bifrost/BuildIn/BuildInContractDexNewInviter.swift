//
//  BuildInContractDexNewInviter.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit
import SwiftyJSON

struct BuildInContractDexNewInviter: BuildInContractProtocol {

    let functionSignatureHexString = "da85ec8a"
    let toAddress = ViteWalletConst.ContractAddress.dexFund.rawValue
    let abi = "{\"type\":\"function\",\"name\":\"DexFundNewInviter\",\"inputs\":[]}"
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Create Referral Code\",\"zh\":\"生成邀请码\"}},\"inputs\":[{\"name\":{\"base\":\"Current Address\",\"zh\":\"当前地址\"}},{\"name\":{\"base\":\"Cost\",\"zh\":\"扣款金额\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard let account = HDWalletManager.instance.account else { return Promise(error: ConfirmError.unknown("not logon")) }
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        guard let e = sendTx.extend, let json = try? JSON(e), json["type"].string == "dexNewInviter",
            let costString = json["cost"].string else {
                return Promise(error: ConfirmError.InvalidExtend)
        }

        let items = [description.inputs[0].confirmItemInfo(text: account.address),
                     description.inputs[1].confirmItemInfo(text: costString)
        ]
        return Promise.value(BifrostConfirmInfo(title: title, items: items))
    }
}
