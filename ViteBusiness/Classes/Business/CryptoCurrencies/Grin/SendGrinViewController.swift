//
//  SendGrinViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/3/11.
//

import UIKit
import Vite_GrinWallet
import RxSwift
import RxCocoa


class SendGrinViewController: UIViewController {

    @IBOutlet weak var titleView: GrinTransactionTitleView!
    @IBOutlet weak var spendableLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var amountConstraint: NSLayoutConstraint!
    @IBOutlet weak var balanceBackground: UIImageView!
    @IBOutlet weak var transactButton: UIButton!

    var transferMethod = TransferMethod.file

    let transferVM = GrinTransferVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bind()
    }

    func bind() {
        GrinManager.default.balanceDriver.drive(onNext: { [weak self] (balance) in
            self?.spendableLabel.text = balance.amountCurrentlySpendable
        })

        amountTextField.rx.text
            .distinctUntilChanged()
            .map { GrinTransferVM.Action.inputTx(amount: $0)}
            .bind(to: transferVM.action)

        transferVM.txFee.asObservable()
            .bind(to: feeLabel.rx.text)

        transferVM.sendTxCreated.asObserver()
            .filterNil()
            .bind { [weak self] slate in
                let vc = SlateViewController(nibName: "SlateViewController", bundle: businessBundle())
                vc.opendSlate = slate
                vc.opendSlateUrl = GrinManager.default.getSlateUrl(slateId: slate.id, isResponse: false)
                self?.navigationController?.pushViewController(vc, animated: true)
        }

        transferVM.errorMessage.asObservable()
            .bind { message in
                Toast.show(message)
        }

    }

    func setUpView()  {
        titleView.symbolLabel.text = "Grin转账"
        titleView.tokenIconView.tokenInfo = GrinManager.tokenInfo

        balanceBackground.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
        balanceBackground.layer.shadowOpacity = 0.1
        balanceBackground.layer.shadowOffset = CGSize(width: 0, height: 5)
        balanceBackground.layer.shadowRadius = 20

        if self.transferMethod == .file {
            amountConstraint.constant = 10
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func sendAction(_ sender: Any) {
        guard let text = self.amountTextField.text,
        let fee = transferVM.txFee.value else {
            return
        }
        let confirmGrinTransactionViewModel = ConfirmGrinTransactionViewModel.init(amountString: text, feeString: fee)
        Workflow.confirmWorkflow(viewModel: confirmGrinTransactionViewModel, completion: { (result) in

        }) {
            if self.transferMethod == .file {
                self.transferVM.action.onNext(.creatTxFile(amount: self.amountTextField.text))
            } else if self.transferMethod == .httpURL {

            } else if self.transferMethod == .viteAddress {

            }
        }


        
    }

}
