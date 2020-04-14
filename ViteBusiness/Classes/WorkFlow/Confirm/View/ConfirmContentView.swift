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
            layoutConfirmButtonAndPasswordInputView()
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
    let bottomTip: String?

    let biometryConfirmButton = UIButton(style: .blue)
    let passwordInputView = TitlePasswordInputView(title: R.string.localizable.confirmTransactionPagePwTitle())
    lazy var bottomTipView = TipTextView(text: self.bottomTip ?? "", hasPoint: true)

    init(infoView: UIView, bottomTip: String?) {
        self.infoView = infoView
        self.bottomTip = bottomTip
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.white
        addSubview(closeButton)
        addSubview(titleLabel)
        addSubview(enterPasswordButton)
        addSubview(infoView)


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
//            if #available(iOS 11.0, *) {
//                let i = -98 - (UIViewController.current?.view.safeAreaInsets.bottom ?? 0)
//                m.bottom.equalToSuperview().offset(i)
//            } else {
//                m.bottom.equalToSuperview().offset(-98)
//            }
            m.leading.trailing.equalToSuperview()
        }

        if self.bottomTip != nil {
            addSubview(bottomTipView)
        }

        layoutConfirmButtonAndPasswordInputView()
    }

    func layoutConfirmButtonAndPasswordInputView() {
        if self.bottomTip != nil {
            switch type {
            case .password:
                addSubview(passwordInputView)
                biometryConfirmButton.removeFromSuperview()
                passwordInputView.snp.remakeConstraints { (m) in
                    m.top.equalTo(infoView.snp.bottom).offset(24)
                    m.leading.equalToSuperview().offset(24)
                    m.trailing.equalToSuperview().offset(-24)
                }

                bottomTipView.snp.remakeConstraints { (m) in
                    m.top.equalTo(passwordInputView.snp.bottom).offset(12)
                    m.leading.equalToSuperview().offset(24)
                    m.trailing.equalToSuperview().offset(-24)
                    m.bottom.equalTo(self.safeAreaLayoutGuideSnpBottom).offset(-24)
                }

                enterPasswordButton.isHidden = true
                passwordInputView.textField.becomeFirstResponder()
            case .biometry:
                addSubview(biometryConfirmButton)
                passwordInputView.removeFromSuperview()

                bottomTipView.snp.remakeConstraints { (m) in
                    m.top.equalTo(infoView.snp.bottom).offset(12)
                    m.leading.equalToSuperview().offset(24)
                    m.trailing.equalToSuperview().offset(-24)
                }

                biometryConfirmButton.snp.remakeConstraints { (m) in
                    m.top.equalTo(bottomTipView.snp.bottom).offset(19)
                    m.height.equalTo(50)
                    m.leading.equalToSuperview().offset(24)
                    m.trailing.equalToSuperview().offset(-24)
                    m.bottom.equalTo(self.safeAreaLayoutGuideSnpBottom).offset(-24)
                }

                enterPasswordButton.isHidden = false
            }
        } else {

            switch type {
            case .password:
                addSubview(passwordInputView)
                biometryConfirmButton.removeFromSuperview()
                passwordInputView.snp.remakeConstraints { (m) in
                    m.top.equalTo(infoView.snp.bottom).offset(24)
                    m.leading.equalToSuperview().offset(24)
                    m.trailing.equalToSuperview().offset(-24)
                    m.bottom.equalTo(self.safeAreaLayoutGuideSnpBottom).offset(-24)
                }

                enterPasswordButton.isHidden = true
                passwordInputView.textField.becomeFirstResponder()
            case .biometry:
                addSubview(biometryConfirmButton)
                passwordInputView.removeFromSuperview()
                biometryConfirmButton.snp.remakeConstraints { (m) in
                    m.top.equalTo(infoView.snp.bottom).offset(24)
                    m.height.equalTo(50)
                    m.leading.equalToSuperview().offset(24)
                    m.trailing.equalToSuperview().offset(-24)
                    m.bottom.equalTo(self.safeAreaLayoutGuideSnpBottom).offset(-24)
                }

                enterPasswordButton.isHidden = false
            }




        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


