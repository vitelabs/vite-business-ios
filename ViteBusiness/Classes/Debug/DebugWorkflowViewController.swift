//
//  DebugWorkflowViewController.swift
//  Action
//
//  Created by Stone on 2019/1/3.
//
#if DEBUG || TEST
import UIKit
import Eureka
import ViteWallet
import BigInt

class DebugWorkflowViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        form
            +++
            Section {
                $0.header = HeaderFooterView(title: "")
            }
            <<< LabelRow("Transaction") {
                $0.title =  "Transaction"
                }.onCellSelection({ _, _  in
                    if let account = HDWalletManager.instance.account {
                        Workflow.sendTransactionWithConfirm(account: account, toAddress: account.address, tokenInfo: TokenInfoCacheService.instance.tokenInfo(forViteTokenId: ViteWalletConst.viteToken.id)!, amount: Amount("10000000000000000000")!, note: "haha", utString: "--") { (r) in
                            print(r)
                        }
                    } else {
                        Toast.show("Login firstly")
                    }
                })
            <<< LabelRow("Vote") {
                $0.title =  "Vote"
                }.onCellSelection({ _, _  in
                    if let account = HDWalletManager.instance.account {
                        Workflow.voteWithConfirm(account: account, name: "s1") { (r) in
                            print(r)
                        }
                    } else {
                        Toast.show("Login firstly")
                    }
                })
            <<< LabelRow("Desposit") {
                $0.title =  "Desposit"
                }.onCellSelection({ _, _  in
                    if let account = HDWalletManager.instance.account {
                        Workflow.dexDepositWithConfirm(account: account, tokenInfo: TokenInfoCacheService.instance.tokenInfo(forViteTokenId: ViteWalletConst.viteToken.id)!, amount: Amount("1000000000000000000"), completion: { (r) in
                            print(r)

                        })
                    } else {
                        Toast.show("Login firstly")
                    }
                })
            <<< LabelRow("Withdraw") {
                $0.title =  "Withdraw"
                }.onCellSelection({ _, _  in
                    if let account = HDWalletManager.instance.account {
                        Workflow.dexWithdrawWithConfirm(account: account, tokenInfo: TokenInfoCacheService.instance.tokenInfo(forViteTokenId: ViteWalletConst.viteToken.id)!, amount: Amount("1000000000000000000"), completion: { (r) in
                            print(r)

                        })
                    } else {
                        Toast.show("Login firstly")
                    }
                })
    }
}
#endif
