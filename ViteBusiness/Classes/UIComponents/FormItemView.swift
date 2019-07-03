//
//  FormItemView.swift
//  Action
//
//  Created by haoshenyang on 2019/6/17.
//

import UIKit

class TitleTipContentSymbleItemView: UIView {

    let titleLabel = UILabel().then {
        $0.textColor = Colors.titleGray
        $0.font = AppStyle.formHeader.font
    }

    let tipButton = UIButton().then {
        $0.setImage(R.image.icon_button_infor(), for: .normal)
    }

    let contentLabel = UILabel().then {
        $0.textColor = Colors.titleGray
        $0.font = AppStyle.formHeader.font
    }
    let symbolLabel = UILabel().then {
        $0.textColor = Colors.titleGray
        $0.font = AppStyle.descWord.font
    }

    let separatorLine = UIView().then {
        $0.backgroundColor = Colors.lineGray
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(tipButton)
        addSubview(contentLabel)
        addSubview(symbolLabel)
        addSubview(separatorLine)

        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.equalTo(self)
            m.right.equalTo(self)
            m.bottom.equalTo(self)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(self).offset(-21)
            m.left.equalTo(self)
        }

        tipButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(titleLabel)
            m.left.equalTo(titleLabel.snp.right).offset(6)
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.right.equalTo(self)
            m.centerY.equalTo(contentLabel)
        }

        contentLabel.textColor = Colors.cellTitleGray
        contentLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(titleLabel)
            m.right.equalTo(symbolLabel.snp.left).offset(-5)

        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

