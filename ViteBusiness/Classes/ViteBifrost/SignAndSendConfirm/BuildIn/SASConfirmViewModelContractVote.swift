//
//  SASConfirmViewModelContractVote.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/26.
//

import PromiseKit
import ViteWallet

struct SASConfirmViewModelContractVote: SASConfirmViewModelContract {

    let abi = ABI.BuildIn.vote
    let description = VBViteSendTx.Description(
        function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinVoteFunctionTitle()),
        inputs: [
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinVoteItem0Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinVoteItem1Title()),
        ])
    func confirmInfo(uri: ViteURI, tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard uri.amountForSmallestUnit(decimals: tokenInfo.decimals) == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(uri.data!, abiString: abi.rawValue)
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

extension SASConfirmViewModelContractVote {
    static func makeURIBy(name: String, gid: String) -> ViteURI {
        return ViteURI(address: ABI.BuildIn.vote.toAddress,
                       chainId: nil,
                       type: .contract,
                       functionName: ABI.BuildIn.vote.abiRecord.name!,
                       tokenId: ViteWalletConst.viteToken.id,
                       amount: nil,
                       fee: nil,
                       data: ABI.BuildIn.getVoteData(gid: gid, name: name),
                       parameters: nil)
    }
}
