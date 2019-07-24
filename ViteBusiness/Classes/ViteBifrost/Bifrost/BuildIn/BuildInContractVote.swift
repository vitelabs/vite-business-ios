//
//  BuildInContractVote.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractVote: BuildInContractProtocol {

    let functionSignatureHexString = "fdc17f25"
    let toAddress = ViteWalletConst.ContractAddress.consensus.rawValue
    let abi = ABI.BuildIn.vote.rawValue
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Vote\",\"zh\":\"投票\"}},\"inputs\":[{\"name\":{\"base\":\"SBP Candidates\",\"zh\":\"投票节点名称\"}},{\"name\":{\"base\":\"Votes\",\"zh\":\"投票量\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi)
            guard let gidValue = values[0] as? ABIGIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            guard let nameValue = values[1] as? ABIStringValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            let balance = ViteBalanceInfoManager.instance.balanceInfo(forViteTokenId: ViteWalletConst.viteToken.id)?.balance ?? Amount(0)
            let items = [description.inputs[0].confirmItemInfo(text: nameValue.toString()),
                         description.inputs[1].confirmItemInfo(text: balance.amountFullWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals))
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
