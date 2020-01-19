//
//  BuildInContractUpdateSBPRewardWithdrawAddress.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

//struct BuildInContractUpdateSBPRewardWithdrawAddress: BuildInContractProtocol {
//
//    let abi = ABI.BuildIn.updateSBPRewardWithdrawAddress
//    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Update SBP Reward Withdraw Address\",\"zh\":\"更新奖励提取地址\"}},\"inputs\":[{\"name\":{\"base\":\"Update Address\",\"zh\":\"更新地址\"}}]}")!
//
//    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
//        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
//        let title = description.function.title ?? ""
//        do {
//            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
//            guard let nameValue = values[0] as? ABIStringValue else {
//                return Promise(error: ConfirmError.InvalidData)
//            }
//            guard let addressValue = values[1] as? ABIAddressValue else {
//                return Promise(error: ConfirmError.InvalidData)
//            }
//            let items = [description.inputs[0].confirmItemInfo(text: addressValue.toString())
//            ]
//            return Promise.value(BifrostConfirmInfo(title: title, items: items))
//        } catch {
//            return Promise(error: ConfirmError.InvalidData)
//        }
//    }
//}
