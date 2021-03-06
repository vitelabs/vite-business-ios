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

    lazy var passwordTF: TitlePasswordInputView = {
        let passwordTF = TitlePasswordInputView(title: R.string.localizable.createPagePwTitle())
        passwordTF.textField.returnKeyType = .next
        passwordTF.textField.delegate = self
        passwordTF.titleLabel.textColor = Colors.titleGray
        passwordTF.titleLabel.font = AppStyle.formHeader.font
        passwordTF.textField.textColor = Colors.descGray
        passwordTF.textField.font = AppStyle.formHeader.font
        return passwordTF
    }()

    lazy var passwordRepeateTF: TitlePasswordInputView = {
        let passwordTF = TitlePasswordInputView(title: R.string.localizable.createPagePwRepeateTitle())
        passwordTF.textField.returnKeyType = .done
        passwordTF.textField.delegate = self
        passwordTF.titleLabel.textColor = Colors.titleGray
        passwordTF.titleLabel.font = AppStyle.formHeader.font
        passwordTF.textField.textColor = Colors.descGray
        passwordTF.textField.font = AppStyle.formHeader.font
        return passwordTF
    }()

    lazy var inviteCodeTF: TitleTextFieldView = {
        let walletNameTF = TitleTextFieldView(title: R.string.localizable.createPageInviteCodeTitle(), placeholder: R.string.localizable.createPageInviteCodePlaceholder(), text: "")
        walletNameTF.titleLabel.textColor = Colors.titleGray
        walletNameTF.textField.font = AppStyle.inputDescWord.font
        walletNameTF.textField.textColor = Colors.descGray
        walletNameTF.titleLabel.font = AppStyle.formHeader.font
        walletNameTF.textField.rightView = self.scanButton
        walletNameTF.textField.rightViewMode = .always
        walletNameTF.textField.keyboardType = .numberPad
        return walletNameTF
    }()

    let scanButton = UIButton().then {
        $0.setImage(R.image.icon_button_scan_gray(), for: .normal)
        $0.setImage(R.image.icon_button_scan_gray()?.highlighted, for: .highlighted)
        $0.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    }

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
        }

        self.addSubview(self.inviteCodeTF)
        self.inviteCodeTF.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.passwordRepeateTF.snp.bottom).offset(30)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self)
        }

        self.scanButton.rx.tap.bind { [weak self] in
            let scanViewController = ScanViewController()
            _ = scanViewController.rx.result.bind { [weak scanViewController, self] result in
                if let url = URL(string: result),
                    let code = url.queryParameters["vitex_invite_code"],
                    !code.isEmpty {
                    self?.inviteCodeTF.textField.text = code
                    UIViewController.current?.navigationController?.popViewController(animated: true)
                } else {
                    scanViewController?.showAlertMessage(result)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(scanViewController, animated: true)
        }.disposed(by: rx.disposeBag)
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
