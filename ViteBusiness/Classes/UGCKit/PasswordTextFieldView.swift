//
//  PasswordTextFieldView.swift
//  ViteBusiness
//
//  Created by Water on 2019/3/6.
//

import UIKit
import SnapKit

class PasswordTextFieldView: UITextField {
    lazy var rightButton = UIButton(type: .custom).then {
        $0.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        $0.setImage(R.image.icon_hide_pwd(), for: .normal)
        $0.addTarget(self, action: #selector(secureTextEntryAction), for: .touchUpInside)
    }

    init() {
        super.init(frame: CGRect.zero)

        self.returnKeyType = .done
        self.isSecureTextEntry = true
        self.keyboardType = .asciiCapable
        self.textColor = Colors.descGray
        self.font = AppStyle.formHeader.font

        self.rightViewMode = .always
        self.rightView = self.rightButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func secureTextEntryAction() {
        self.isSecureTextEntry = !self.isSecureTextEntry
        
        if self.isSecureTextEntry {
            rightButton.setImage(R.image.icon_hide_pwd(), for: .normal)
        }else {
            rightButton.setImage(R.image.icon_show_pwd(), for: .normal)
        }
    }
}


