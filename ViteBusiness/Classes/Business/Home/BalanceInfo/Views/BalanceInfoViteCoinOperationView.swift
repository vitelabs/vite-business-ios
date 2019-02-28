//
//  BalanceInfoViteCoinOperationView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/2/28.
//

import UIKit

class BalanceInfoViteCoinOperationView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 44)
    }

    let voteButton = OperationButton()
    let pledgeButton = OperationButton()

    override init(frame: CGRect) {
        super.init(frame: frame)


        clipsToBounds = false
        
        addSubview(voteButton)
        addSubview(pledgeButton)

        voteButton.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalToSuperview()
        }

        pledgeButton.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalTo(voteButton.snp.right).offset(15)
            m.right.equalToSuperview()
            m.width.equalTo(voteButton)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


class OperationButton: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setShadow(width: 0, height: 2, radius: 10)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
