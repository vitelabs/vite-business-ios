//
//  DebugWorkflowViewController.swift
//  Action
//
//  Created by Stone on 2019/1/3.
//

import UIKit
import Eureka
import ViteUtils
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
                        Workflow.sendTransactionWithConfirm(account: account, toAddress: account.address, token: ViteWalletConst.viteToken, amount: Balance(value: BigInt("10000000000000000000")!), note: "haha") { (r) in
                            print(r)
                        }
                    } else {
                        Toast.show("Login firstly")
                    }
                })
    }
}
