//
//  CrossChainWithdraw.swift
//  Action
//
//  Created by haoshenyang on 2019/6/14.
//

import Foundation
import PromiseKit
import ViteWallet

struct CrossChainWithdraw {

    static func withDraw(tokenInfo: TokenInfo, viteAddress: String, withdrawAddress: String, amount: String) {
        let tokenId = tokenInfo.viteTokenId
        let gateWayInfo = CrossChainGatewayInfoService.init(tokenInfo: tokenInfo)

        let metalInfo = gateWayInfo.getMetaInfo()
        let withdrawInfo = gateWayInfo.withdrawInfo(viteAddress: viteAddress)
        let verifyWithdrawAddress = gateWayInfo.verifyWithdrawAddress(withdrawAddress: withdrawAddress)

        when(fulfilled: metalInfo,withdrawInfo,verifyWithdrawAddress)
            .done { (arg0)  in
                let (metalInfo, withdrawInfo, verifyWithdrawAddress) = arg0

                guard metalInfo.withdrawState == .open else {
                    return
                }

                guard verifyWithdrawAddress == true else {
                    return
                }

                guard amount >= withdrawInfo.minimumWithdrawAmount else {
                    return 
                }

                guard amount <= withdrawInfo.maximumWithdrawAmount else {
                    return
                }

                guard let account = HDWalletManager.instance.accounts.filter({ (account) -> Bool in
                    account.address == viteAddress
                }).first else {
                    return
                }

                guard let amount = Amount(amount) else {
                    return
                }

                Workflow.sendTransactionWithConfirm(account: account, toAddress: withdrawInfo.gatewayAddress, tokenInfo: tokenInfo, amount: amount, note: withdrawAddress, completion: { (accountBlock) in


                })
        }

    }
}
