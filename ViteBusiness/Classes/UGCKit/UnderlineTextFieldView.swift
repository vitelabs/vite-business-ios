//
//  UnderlineTextFieldView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/2.
//

import Foundation

class UnderlineTextFieldView: UIView {

    let textField = UITextField().then {
        $0.font = AppStyle.descWord.font
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let separatorLine = UIView().then {
            $0.backgroundColor = Colors.lineGray
        }

        addSubview(textField)
        addSubview(separatorLine)

        textField.snp.makeConstraints { (m) in
            m.left.right.top.equalToSuperview()
            m.bottom.equalToSuperview().offset(-10)
        }

        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.right.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
