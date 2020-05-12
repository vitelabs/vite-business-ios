//
//  ConfirmViewController.swift
//  Vite
//
//  Created by haoshenyang on 2018/9/14.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

class ConfirmViewController: UIViewController {

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

    let viewModel: ConfirmViewModelType
    let completion: (ConfirmTransactionResult) -> Void
    let contentView: ConfirmContentView

    init(viewModel: ConfirmViewModelType, isForceUsePassword: Bool = false, completion:@escaping ((ConfirmTransactionResult) -> Void)) {
        self.viewModel = viewModel
        self.completion = completion
        self.contentView = ConfirmContentView(infoView: viewModel.createInfoView(), bottomTip: viewModel.bottomTipString)
        if isForceUsePassword {
            self.contentView.type = .password
        } else {
            self.contentView.type = HDWalletManager.instance.isTransferByBiometry ? .biometry : .password
        }
        self.contentView.titleLabel.text = viewModel.confirmTitle
        self.contentView.biometryConfirmButton.setTitle(viewModel.biometryConfirmButtonTitle, for: .normal)
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func setupUI() {
        view.backgroundColor = UIColor.init(netHex: 0x000000, alpha: 0.4)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (m) in
            m.leading.trailing.bottom.equalToSuperview()
        }
    }

    func bind() {
        contentView.closeButton.rx.tap
            .bind { [weak self] in
                self?.procese(.cancelled)
            }.disposed(by: rx.disposeBag)

        contentView.biometryConfirmButton.rx.tap
            .bind { [weak self] in
                BiometryAuthenticationManager.shared.authenticate(reason: R.string.localizable.confirmTransactionPageBiometryConfirmReason(), completion: { (success, error) in
                    if let error =  error {
                        Toast.show(error.localizedDescription)
                    } else if success {
                        self?.procese(.success)
                    }
                })
            }.disposed(by: rx.disposeBag)

        contentView.enterPasswordButton.rx.tap
            .bind { [unowned self] in
                self.contentView.type = .password
            }.disposed(by: rx.disposeBag)

        contentView.passwordInputView.textField.kas_setReturnAction(.done(block: { [weak self] (textField) in
            guard let `self` = self else { return }
            let result = HDWalletManager.instance.verifyPassword(textField.text ?? "")
            self.procese(result ? .success : .passwordAuthFailed)
        }), delegate: self)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .filter { [weak self] _  in
                return self?.contentView.type == .password
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
        self.dismiss(animated: false, completion: { [weak self] in
            self?.completion(result)
        })
    }
}

extension ConfirmViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.dismiss(animated: false, completion: nil)
    }
}
