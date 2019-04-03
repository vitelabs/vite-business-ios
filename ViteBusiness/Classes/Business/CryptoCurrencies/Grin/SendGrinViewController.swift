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
import ViteWallet


class SendGrinViewController: UIViewController {

    @IBOutlet weak var titleView: GrinTransactionTitleView!
    @IBOutlet weak var spendableLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var amountConstraint: NSLayoutConstraint!
    @IBOutlet weak var balanceBackground: UIImageView!
    @IBOutlet weak var transactButton: UIButton!

    @IBOutlet weak var spendableTitleLabel: UILabel!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var feeTitleLable: UILabel!

    var transferMethod = TransferMethod.file
    let transferVM = GrinTransactVM()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(view)
    }

    func bind() {
        GrinManager.default.balanceDriver.drive(onNext: { [weak self] (balance) in
            self?.spendableLabel.text = balance.amountCurrentlySpendable
        })
        .disposed(by: rx.disposeBag)
        GrinManager.default.getBalance()

        amountTextField.rx.text
            .distinctUntilChanged()
            .throttle(1.5, scheduler: MainScheduler.instance)
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
                var viewControllers = self?.navigationController?.viewControllers
                viewControllers?.popLast()
                viewControllers?.append(vc)
                if let viewControllers = viewControllers {
                    self?.navigationController?.setViewControllers(viewControllers, animated: true)
                }
            }
            .disposed(by: rx.disposeBag)

        transferVM.message.asObservable()
            .bind { message in
                Toast.show(message)
            }
            .disposed(by: rx.disposeBag)


        transferVM.sendTxSuccess.asObserver()
            .delay(2, scheduler: MainScheduler.instance)
            .bind {
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: rx.disposeBag)
    }

    func setUpView()  {
        titleView.symbolLabel.text = R.string.localizable.grinSentTitle()
        titleView.tokenIconView.tokenInfo = GrinManager.tokenInfo
        spendableTitleLabel.text = R.string.localizable.grinBalanceSpendable()
        addressTitleLabel.text = R.string.localizable.confirmTransactionAddressTitle()
        amountTitleLabel.text = R.string.localizable.grinSentAmount()
        feeTitleLable.text = R.string.localizable.grinSentFee()

        view.backgroundColor = UIColor.init(netHex: 0xffffff)
        balanceBackground.backgroundColor = UIColor.init(netHex: 0xffffff)
        balanceBackground.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
        balanceBackground.layer.shadowOpacity = 0.1
        balanceBackground.layer.shadowOffset = CGSize(width: 0, height: 5)
        balanceBackground.layer.shadowRadius = 5

        amountTextField.delegate = self

        if self.transferMethod == .file {
            amountConstraint.constant = 10
            self.view.layoutIfNeeded()
            transactButton.setTitle(R.string.localizable.grinSentCreatFile(), for: .normal)
        } else {
            transactButton.setTitle(R.string.localizable.grinSentNext(), for: .normal)
        }
    }

    @IBAction func sendAction(_ sender: Any) {
        guard let amountString = amountTextField.text else { return }
        guard (transferMethod == .file || !(addressTextField.text?.isEmpty ?? true)) else { return }
        var send = {
            self.view.displayLoading()
            self.transferVM.txStrategies(amountString: self.amountTextField.text) { [weak self] (fee) in
                self?.view.hideLoading()
                guard !fee.isEmpty else { return }
                let confirmType = ConfirmGrinTransactionViewModel(amountString: amountString, feeString: fee)
                Workflow.confirmWorkflow(viewModel: confirmType, completion: { (result) in
                }) {
                    let amountString = self?.amountTextField.text
                    if self?.transferMethod == .file {
                        self?.transferVM.action.onNext(.creatTxFile(amount: amountString))
                    } else if let destnation = self?.addressTextField.text {
                        self?.transferVM.action.onNext(.sentTx(amountString: amountString, destnation: destnation))
                    }
                }
            }
        }

        if transferMethod != .file,
            let destination = self.addressTextField.text,
            destination.hasPrefix("http"),
            let viteAddress = destination.components(separatedBy: "/").last,
            Address.isValid(string: viteAddress) {
            Alert.show(into: self, title: R.string.localizable.grinSentSuggestUseViteTitle(), message: R.string.localizable.grinSentSuggestUseViteDesc(), actions: [
                (.default(title: R.string.localizable.grinSentStillUseHttp()), { _ in
                    send()
                }),
                (.default(title: R.string.localizable.grinSentSwitch()), { _ in
                    self.addressTextField.text = viteAddress
                    send()
                }),])
        } else {
            send()
        }

    }

    @IBAction func selectAddress(_ sender: Any) {
        let viewModel = AddressListViewModel.createAddressListViewModel(for: CoinType.grin)
        let vc = AddressListViewController(viewModel: viewModel)
        vc.selectAddressDrive.drive(addressTextField.rx.text).disposed(by: rx.disposeBag)
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
    }

}

extension SendGrinViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: 9)
            textField.text = text
            return ret
        } else {
            return true
        }
    }
}

