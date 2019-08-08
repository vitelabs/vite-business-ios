//
//  BalanceInfoViteGatewayOperationView.swift
//  Action
//
//  Created by haoshenyang on 2019/6/11.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx


struct BalanceInfoOperation {
    let icon: UIImage?
    let title: String
    let action: (()->())?
}

class BalanceInfoViteGatewayOperationView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 44)
    }

    let leftButton: OperationButton
    let rightButton: OperationButton

    init(firstOperation: BalanceInfoOperation, secondOperation: BalanceInfoOperation) {

        leftButton = OperationButton(icon: firstOperation.icon, title: firstOperation.title)
        rightButton = OperationButton(icon: secondOperation.icon, title: secondOperation.title)

        super.init(frame: CGRect.zero)

        clipsToBounds = false

        addSubview(leftButton)
        addSubview(rightButton)

        leftButton.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalToSuperview()
        }

        rightButton.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalTo(leftButton.snp.right).offset(15)
            m.right.equalToSuperview()
            m.width.equalTo(leftButton)
        }

        leftButton.button.rx.tap.bind {
            let sendViewController = VoteHomeViewController()
                firstOperation.action?()
            }.disposed(by: rx.disposeBag)

        rightButton.button.rx.tap.bind {
            let sendViewController = QuotaManageViewController()
            secondOperation.action?()
            }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
