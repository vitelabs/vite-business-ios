//
//  CreateNameAndPwdView.swift
//  Vite
//
//  Created by Water on 2018/9/18.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

class CreateNameAndPwdView: UIView {
    lazy var walletNameTF: TitleTextFieldView = {
        let walletNameTF = TitleTextFieldView(title: R.string.localizable.createPageTfTitle(), placeholder: "", text: "")
        walletNameTF.titleLabel.textColor = Colors.titleGray
        walletNameTF.textField.font = AppStyle.inputDescWord.font
        walletNameTF.textField.textColor = Colors.descGray
        walletNameTF.titleLabel.font = AppStyle.formHeader.font
        return walletNameTF
    }()

    lazy var passwordTF: TitleTextFieldView = {
        let passwordTF = TitleTextFieldView(title: R.string.localizable.createPagePwTitle())

        passwordTF.textField.delegate = self
        passwordTF.titleLabel.textColor = Colors.titleGray
        passwordTF.titleLabel.font = AppStyle.formHeader.font
        passwordTF.textField.textColor = Colors.descGray
        passwordTF.titleLabel.font = AppStyle.formHeader.font
        return passwordTF
    }()

    lazy var passwordRepeateTF: TitleTextFieldView = {
        let passwordTF = TitleTextFieldView(title: R.string.localizable.createPagePwRepeateTitle())
        passwordTF.textField.delegate = self
        passwordTF.titleLabel.textColor = Colors.titleGray
        passwordTF.titleLabel.font = AppStyle.formHeader.font
        passwordTF.textField.textColor = Colors.descGray
        passwordTF.titleLabel.font = AppStyle.formHeader.font
        return passwordTF
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white

        self._addViewConstraint()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func _addViewConstraint() {
        self.addSubview(walletNameTF)
        walletNameTF.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self)
            make.left.right.equalTo(self)
            make.height.equalTo(60)
        }

        self.addSubview(self.passwordTF)
        self.passwordTF.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.walletNameTF.snp.bottom).offset(30)
            make.left.right.equalTo(self)
            make.height.equalTo(60)
        }

        self.addSubview(self.passwordRepeateTF)
        self.passwordRepeateTF.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.passwordTF.snp.bottom).offset(30)
            make.left.right.equalTo(self)
            make.height.equalTo(60)
            make.bottom.equalTo(self)
        }
    }
}

extension CreateNameAndPwdView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField ==  self.passwordTF.textField {
            _ = self.passwordTF.textField.resignFirstResponder()
            _ = self.passwordRepeateTF.textField.becomeFirstResponder()
        }
        if textField ==  self.passwordRepeateTF.textField {
            _ = self.passwordTF.textField.resignFirstResponder()
            _ = self.passwordRepeateTF.textField.resignFirstResponder()
        }
        return true
    }
}
