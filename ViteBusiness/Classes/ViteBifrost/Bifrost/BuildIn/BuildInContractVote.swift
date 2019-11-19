//
//  BuildInContractVote.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractVote: BuildInContractProtocol {

    let abi = ABI.BuildIn.vote
    let description = VBViteSendTx.Description(
        function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinVoteFunctionTitle()),
        inputs: [
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinVoteItem0Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinVoteItem1Title()),
        ])

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
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

struct BuildInContractVoteForSBP: BuildInContractProtocol {

    let abi = ABI.BuildIn.voteForSBP
    let description = VBViteSendTx.Description(
        function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinVoteFunctionTitle()),
        inputs: [
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinVoteItem0Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinVoteItem1Title()),
        ])

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let nameValue = values[0] as? ABIStringValue else {
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
