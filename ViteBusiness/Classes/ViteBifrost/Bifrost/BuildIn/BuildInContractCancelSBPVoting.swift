//
//  BuildInContractCancelSBPVoting.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractCancelSBPVoting: BuildInContractProtocol {

    let abi = ABI.BuildIn.cancelSBPVoting
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Revoke Voting\",\"zh\":\"撤销投票\"}},\"inputs\":[{\"name\":{\"base\":\"Votes Revoked\",\"zh\":\"撤销投票量\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)

            let balance = ViteBalanceInfoManager.instance.balanceInfo(forViteTokenId: ViteWalletConst.viteToken.id)?.balance ?? Amount(0)
            let items = [description.inputs[0].confirmItemInfo(text: balance.amountFullWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals))
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
