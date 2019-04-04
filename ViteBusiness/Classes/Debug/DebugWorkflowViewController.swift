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
                        Workflow.sendTransactionWithConfirm(account: account, toAddress: account.address, tokenInfo: MyTokenInfosService.instance.tokenInfo(forViteTokenId: ViteWalletConst.viteToken.id)!, amount: Balance(value: BigInt("10000000000000000000")!), note: "haha") { (r) in
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
    }
}
#endif
