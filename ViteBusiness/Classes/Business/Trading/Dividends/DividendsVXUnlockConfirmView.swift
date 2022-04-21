//
//  DividendsVXUnlockConfirmView.swift
//  ViteBusiness
//
//  Created by stone on 2022/2/22.
//

import UIKit
import ViteWallet
import ActiveLabel
import enum Alamofire.Result

public class DividendsVXUnlockConfirmView: BottomPopView {

    var balance = Amount(0)
    
    public init() {
        let confirmButton = UIButton(style: .blue, title: R.string.localizable.dividendsPageUnlockConfirmButtonTitle())
        let totalView = ConfirmAmountView(type: .amount)
        let amountView = SendAmountView(amount: "", token: TokenInfo.BuildIn.vx.value)
        
        super.init(title: R.string.localizable.dividendsPageUnlockConfirmTitle(), buttons: [confirmButton], superview: UIApplication.shared.keyWindow!)

        confirmButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            guard let amountString = amountView.textField.text,
                !amountString.isEmpty,
                let amount = amountString.toAmount(decimals: TokenInfo.BuildIn.vx.value.decimals) else {
                Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                return
            }

            guard amount <= self.balance else {
                Toast.show(R.string.localizable.sendPageToastAmountError())
                return
            }

            guard amount >= "1".toAmount(decimals: TokenInfo.BuildIn.vx.value.decimals)! else {
                Toast.show(R.string.localizable.dividendsPageUnlockConfirmError())
                return
            }
            
            self.hide()
            
            
            Workflow.dexUnlockVxForDividendWithConfirm(account: HDWalletManager.instance.account!, amount: amount) { _ in }
            
            }.disposed(by: rx.disposeBag)

        
        totalView.titleLabel.text = R.string.localizable.dividendsPageUnlockConfirmAmountTotal()
        
        amountView.titleLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
        amountView.textField.keyboardType = .decimalPad
        amountView.titleLabel.text = R.string.localizable.dividendsPageUnlockConfirmAmount()
        amountView.textField.placeholder = R.string.localizable.dividendsPageUnlockConfirmPlaceholder()
        
        let tipLabel = UILabel().then {
            $0.text = R.string.localizable.dividendsPageUnlockConfirmTip()
            $0.numberOfLines = 0
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        }

        let circleView = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0x007AFF)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 3
        }

        containerView.addSubview(totalView)
        containerView.addSubview(amountView)
        containerView.addSubview(tipLabel)
        containerView.addSubview(circleView)

        totalView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(-24)
            m.right.equalToSuperview().offset(24)
        }
        
        amountView.snp.makeConstraints { m in
            m.top.equalTo(totalView.snp.bottom).offset(0)
            m.left.right.equalToSuperview()
        }

        circleView.snp.makeConstraints { (m) in
            m.top.equalTo(amountView.snp.bottom).offset(20)
            m.left.equalToSuperview()
            m.size.equalTo(CGSize(width: 6, height: 6))
        }

        tipLabel.snp.makeConstraints { (m) in
            m.top.equalTo(circleView).offset(-5)
            m.left.equalTo(circleView.snp.right).offset(6)
            m.right.bottom.equalToSuperview()
        }
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: {[weak self] (notification) in
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
                var height = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
                UIView.animate(withDuration: duration, animations: {
                    self?.contentView.transform = CGAffineTransform(translationX: 0, y: -height)
                })
            }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: {[weak self] (notification) in
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
                UIView.animate(withDuration: duration, animations: {
                    self?.contentView.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }).disposed(by: rx.disposeBag)
        
        
        ViteBalanceInfoManager.instance.dexBalanceInfosDriver
            .drive(onNext: { [weak self] (map) in
                guard let `self` = self else { return }
                self.balance =  map[TokenInfo.BuildIn.vx.value.viteTokenId]?.vxLocked ?? Amount(0)
                totalView.set(text: self.balance.amountFullWithGroupSeparator(decimals: TokenInfo.BuildIn.vx.value.decimals) +  " " + TokenInfo.BuildIn.vx.value.symbol)
            }).disposed(by: rx.disposeBag)
        
        amountView.allButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            amountView.textField.text = self.balance.amountFull(decimals: TokenInfo.BuildIn.vx.value.decimals)
            amountView.calcPrice()
        }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
