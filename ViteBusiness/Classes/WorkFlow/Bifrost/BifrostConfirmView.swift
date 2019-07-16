//
//  BifrostConfirmView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

class BifrostConfirmView: UIView {

    enum ConfirmTransactionType {
        case password
        case biometry
    }

    enum ConfirmTransactionResult {
        case cancelled
        case success
        case biometryAuthFailed
        case passwordAuthFailed
    }

    let completion: (ConfirmTransactionResult) -> Void

    let type: ConfirmTransactionType

    let backView = UIView().then {
        $0.backgroundColor = UIColor.init(netHex: 0x000000, alpha: 0.4)
        $0.alpha = 0
    }

    let contentView = UIView().then {
        $0.backgroundColor = UIColor.white
    }

    let closeButton = UIButton().then {
        $0.setImage(R.image.icon_nav_close_black()?.tintColor(UIColor(netHex: 0x3E4A59, alpha: 0.45)), for: .normal)
        $0.setImage(R.image.icon_nav_close_black()?.tintColor(UIColor(netHex: 0x3E4A59, alpha: 0.45)).highlighted, for: .highlighted)
    }

    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 17)
    }

    let passwordInputView = TitlePasswordInputView(title: R.string.localizable.confirmTransactionPagePwTitle())

    init(title: String, completion: @escaping ((ConfirmTransactionResult) -> Void)) {
        self.titleLabel.text = title
        self.completion = completion
        self.type = HDWalletManager.instance.isTransferByBiometry ? .biometry : .password
        super.init(frame: CGRect.zero)
        setupUI()
        bind()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {

        guard let view = UIApplication.shared.keyWindow else { return }
        view.addSubview(self)

        self.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        self.isHidden = true

        addSubview(backView)
        addSubview(contentView)
        contentView.addSubview(closeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(passwordInputView)

        backView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.height.equalTo(136)
        }

        closeButton.snp.makeConstraints { (m) in
            m.width.height.equalTo(30)
            m.top.equalToSuperview().offset(16)
            m.leading.equalToSuperview().offset(20)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(19)
            m.centerX.equalToSuperview()
        }

        passwordInputView.snp.makeConstraints { (m) in
            m.top.equalTo(closeButton.snp.bottom).offset(16)
            m.leading.equalToSuperview().offset(24)
            m.trailing.equalToSuperview().offset(-24)
        }
    }

    func bind() {
        closeButton.rx.tap
            .bind { [weak self] in
                self?.procese(.cancelled)
            }.disposed(by: rx.disposeBag)

        passwordInputView.textField.kas_setReturnAction(.done(block: { [weak self] (textField) in
            guard let `self` = self else { return }
            let result = HDWalletManager.instance.verifyPassword(textField.text ?? "")
            self.procese(result ? .success : .passwordAuthFailed)
        }))

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .filter { [weak self] _  in
                return self?.type == .password
            }
            .subscribe(onNext: {[weak self] (notification) in
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
                var height = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
                UIView.animate(withDuration: duration, animations: {
                    self?.contentView.transform = CGAffineTransform(translationX: 0, y: -height)
                })
            }).disposed(by: rx.disposeBag)
    }



    func procese(_ result: ConfirmTransactionResult) {
        switch type {
        case .biometry:
            self.removeFromSuperview()
            self.completion(result)
        case .password:
            passwordInputView.textField.resignFirstResponder()

            UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
                self.alpha = 0
                self.contentView.transform = CGAffineTransform(translationX: 0, y: 0)
            }) { (_) in
                self.removeFromSuperview()
                self.completion(result)
            }
        }
    }

    func show() {

        self.isHidden = false

        switch type {
        case .biometry:
            backView.isHidden = true
            contentView.isHidden = true

            BiometryAuthenticationManager.shared.authenticate(reason: R.string.localizable.confirmTransactionPageBiometryConfirmReason(), completion: { (success, error) in
                if let error = error {
                    if let e = error as? NSError, e.domain == "com.apple.LocalAuthentication", e.code == -2 {
                        self.procese(.cancelled)
                    } else {
                        Toast.show(error.localizedDescription)
                        self.procese(.biometryAuthFailed)
                    }
                } else if success {
                    self.procese(.success)
                }
            })

        case .password:

            backView.alpha = 0
            UIView.animate(withDuration: 0.25) {
                self.backView.alpha = 1
            }

            backView.isHidden = false
            contentView.isHidden = false
            passwordInputView.textField.becomeFirstResponder()
        }
    }
}
