//
//  ConfirmContentView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

class ConfirmContentView: UIView {

    var type: ConfirmViewController.ConfirmTransactionType = .password {
        didSet {
            switch type {
            case .password:
                biometryConfirmButton.isHidden = true
                passwordInputView.isHidden = false
                enterPasswordButton.isHidden = true
                passwordInputView.textField.becomeFirstResponder()
            case .biometry:
                biometryConfirmButton.isHidden = false
                passwordInputView.isHidden = true
            }
        }
    }

    let closeButton = UIButton().then {
        $0.setImage(R.image.icon_nav_close_black(), for: .normal)
    }

    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 17)
    }

    let enterPasswordButton = UIButton().then {
        $0.setTitleColor(UIColor.init(netHex: 0x007AFF), for: .normal)
        $0.setTitle(R.string.localizable.confirmTransactionPageUsePassword(), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    let infoView: UIView

    let biometryConfirmButton = UIButton(style: .blue)
    let passwordInputView = TitlePasswordInputView(title: R.string.localizable.confirmTransactionPagePwTitle())



    init(infoView: UIView) {
        self.infoView = infoView
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.white
        addSubview(closeButton)
        addSubview(titleLabel)
        addSubview(enterPasswordButton)
        addSubview(infoView)
        addSubview(biometryConfirmButton)
        addSubview(passwordInputView)

        closeButton.snp.makeConstraints { (m) in
            m.width.height.equalTo(30)
            m.top.equalTo(self).offset(16)
            m.leading.equalTo(self).offset(20)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self).offset(19)
            m.centerX.equalTo(self)
        }

        enterPasswordButton.snp.makeConstraints { (m) in
            m.height.equalTo(30)
            m.top.equalTo(self).offset(16)
            m.trailing.equalTo(self).offset(-20)
        }

        infoView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(60)
            if #available(iOS 11.0, *) {
                let i = -98 - (UIViewController.current?.view.safeAreaInsets.bottom ?? 0)
                m.bottom.equalToSuperview().offset(i)
            } else {
                m.bottom.equalToSuperview().offset(-98)
            }
            m.leading.trailing.equalToSuperview()
        }

        biometryConfirmButton.snp.makeConstraints { (m) in
            m.top.equalTo(infoView.snp.bottom).offset(24)
            m.leading.equalToSuperview().offset(24)
            m.trailing.equalToSuperview().offset(-24)
        }

        passwordInputView.snp.makeConstraints { (m) in
            m.top.equalTo(infoView.snp.bottom).offset(24)
            m.leading.equalToSuperview().offset(24)
            m.trailing.equalToSuperview().offset(-24)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
