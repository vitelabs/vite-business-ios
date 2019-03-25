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
import BigInt


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
    let transferVM = GrinTransactVM()

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
            .map { GrinTransactVM.Action.inputTx(amount: $0)}
            .bind(to: transferVM.action)
            .disposed(by: rx.disposeBag)

        transferVM.txFee.asObservable()
            .bind(to: feeLabel.rx.text)
            .disposed(by: rx.disposeBag)

        transferVM.sendSlateCreated.asObserver()
            .bind { [weak self] (slate, url) in
                let vc = SlateViewController(nibName: "SlateViewController", bundle: businessBundle())
                (vc.opendSlate, vc.opendSlateUrl) = (slate, url)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: rx.disposeBag)

        transferVM.message.asObservable()
            .bind { message in
                Toast.show(message)
            }
            .disposed(by: rx.disposeBag)

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
        guard let amountString = amountTextField.text else { return }
       transferVM.txStrategies(amountString: self.amountTextField.text) { (fee) in
            guard !fee.isEmpty else { return }
            let confirmType = ConfirmGrinTransactionViewModel(amountString: amountString, feeString: fee)
            Workflow.confirmWorkflow(viewModel: confirmType, completion: { (result) in

            }) {
                let amountString = self.amountTextField.text
                if self.transferMethod == .file {
                    self.transferVM.action.onNext(.creatTxFile(amount: amountString))
                } else if let destnation = self.addressTextField.text {
                    self.transferVM.action.onNext(.sentTx(amountString: amountString, destnation: ""))
                }
            }
        }
    }

    @IBAction func selectAddress(_ sender: Any) {
        let viewModel = AddressListViewModel.createAddressListViewModel(for: CoinType.grin)
        let vc = AddressListViewController(viewModel: viewModel)
        vc.selectAddress.asObservable().bind(to: addressTextField.rx.text).disposed(by: rx.disposeBag)
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
    }

}
