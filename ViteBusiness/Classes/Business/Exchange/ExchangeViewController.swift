//
//  ExchangeViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/7/25.
//

import UIKit
import BigInt
import ViteWallet
import RxSwift
import RxCocoa

class ExchangeViewController: BaseViewController {

    let vm = ExchangeViewModel()

    let viteTextField = UITextField()
    let ethTextField = UITextField()
    let rateLabel = UILabel()
    let exchangeButton = UIButton.init(style: .blueWithShadow, title: "exchange")

    override func viewDidLoad() {

        super.viewDidLoad()
        setupViews()
        bind()
        vm.action.onNext(.getRate)
    }

    func setupViews()  {
         let button = UIButton()
        button.setTitle("历史", for:  .normal)
        button.setTitleColor(.red, for: .normal)
        button.sizeToFit()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: button)

        button.rx.tap.bind { _ in

            UIViewController.current?.navigationController?.pushViewController(ExchangeHistoryViewController(), animated: true)

            }.disposed(by: rx.disposeBag)

        view.addSubview(viteTextField)
        view.addSubview(ethTextField)
        view.addSubview(rateLabel)
        view.addSubview(exchangeButton)

        viteTextField.backgroundColor = .blue
        ethTextField.backgroundColor = .blue
        rateLabel.backgroundColor = .blue


        viteTextField.snp.makeConstraints { (m) in
            m.width.height.equalTo(100)
            m.top.equalToSuperview()
        }

        ethTextField.snp.makeConstraints { (m) in
            m.width.height.equalTo(100)
            m.top.equalTo(viteTextField.snp.bottom).offset(20)
        }

        rateLabel.snp.makeConstraints { (m) in
            m.width.height.equalTo(100)
            m.top.equalTo(ethTextField.snp.bottom).offset(20)
        }

        exchangeButton.snp.makeConstraints { (m) in
            m.width.height.equalTo(100)
            m.top.equalTo(rateLabel.snp.bottom).offset(20)
        }
    }

    func bind()  {
        vm.rateInfo.bind { info in
            self.rateLabel.text = String(info.rightRate)
        }.disposed(by: rx.disposeBag)

        viteTextField.rx.text.bind { text in
            guard let count = Double(text ?? "") else { return }
             let rightRate = self.vm.rateInfo.value.rightRate

            let a = count * rightRate

            self.ethTextField.text = a.description

        }.disposed(by: rx.disposeBag)

        ethTextField.rx.text.bind { text in
            guard let count = Double(text ?? "") else { return }
            let rightRate = self.vm.rateInfo.value.rightRate

            let a = count / rightRate

            self.viteTextField.text = a.description

        }.disposed(by: rx.disposeBag)

        exchangeButton.rx.tap.bind{

            guard let viteAmount = Double(self.viteTextField.text ?? "")  else  {return}
            guard viteAmount > self.vm.rateInfo.value.quota.unitQuotaMin  else  {return}
            guard viteAmount < self.vm.rateInfo.value.quota.unitQuotaMax  else  {return}

            let address = self.vm.rateInfo.value.storeAddress

            guard let amountString = self.ethTextField.text,
                !amountString.isEmpty,
                let amount = amountString.toAmount(decimals: TokenInfo.eth000.decimals) else {
                    Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                    return
            }


            Workflow.sendTransactionWithConfirm(account: HDWalletManager.instance.account!, toAddress: address, tokenInfo: TokenInfo.eth000, amount:amount, data: nil) { (block) in
                switch block {
                case .success(let b):
                    self.vm.action.onNext(.report(hash:b.hash ?? ""))
                case .failure(let e):
                    Toast.show(e.localizedDescription)
                }
            }


        }.disposed(by: rx.disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
