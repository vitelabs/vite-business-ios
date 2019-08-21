//
//  QuicklyGetQuotaConfirmView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit
import ViteWallet
import ActiveLabel
import enum Alamofire.Result

public class QuicklyGetQuotaConfirmView: BottomPopView {

    let canceled: (BottomPopView) -> ()

    public init(completion: @escaping (BottomPopView, Result<AccountBlock>) -> (), canceled: @escaping (BottomPopView) -> ()) {
        self.canceled = canceled
        super.init(title: R.string.localizable.workflowFastGetQuotaTitle(), confirmed: { view in
            view.hide()
            guard let account = HDWalletManager.instance.account else { return }
            let amount = "134".toAmount(decimals: ViteWalletConst.viteToken.decimals)!
            Workflow.pledgeWithConfirm(account: account, beneficialAddress: account.address, amount: amount, completion: { ret in
                completion(view, ret)
            })
        }, canceled: canceled)

        self.dismissButtonClicked = canceled

        let messageLabel = UILabel().then {
            $0.text = R.string.localizable.workflowFastGetQuotaMessage()
            $0.numberOfLines = 0
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        }

        let tipLabel = ActiveLabel().then {
            $0.text = R.string.localizable.workflowFastGetQuotaTip(R.string.localizable.workflowFastGetQuotaLink())
            $0.numberOfLines = 0
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        }

        let customType = ActiveType.custom(pattern: R.string.localizable.workflowFastGetQuotaLink())
        tipLabel.enabledTypes = [customType]
        tipLabel.customize { label in
            label.customColor[customType] = UIColor(netHex: 0x007AFF)
            label.customSelectedColor[customType] = UIColor(netHex: 0x007AFF).highlighted
            label.handleCustomTap(for: customType) { [weak self] _ in
                guard let `self` = self else { return }
                self.hide()
                self.canceled(self)
                let vc = QuotaManageViewController()
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }
        }

        let circleView = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0x007AFF)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 3
        }

        containerView.addSubview(messageLabel)
        containerView.addSubview(tipLabel)
        containerView.addSubview(circleView)

        messageLabel.snp.makeConstraints { (m) in
            m.left.right.top.equalToSuperview()
        }

        circleView.snp.makeConstraints { (m) in
            m.top.equalTo(messageLabel.snp.bottom).offset(20)
            m.left.equalToSuperview()
            m.size.equalTo(CGSize(width: 6, height: 6))
        }

        tipLabel.snp.makeConstraints { (m) in
            m.top.equalTo(circleView).offset(-5)
            m.left.equalTo(circleView.snp.right).offset(6)
            m.right.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


