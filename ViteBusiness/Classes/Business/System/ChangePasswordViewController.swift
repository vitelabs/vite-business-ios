//
//  ChangePasswordViewController.swift
//  ViteBusiness
//
//  Created by stone on 2021/9/15.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import NSObject_Rx
import Vite_HDWalletKit
import ActiveLabel
import ViteWallet

extension ChangePasswordViewController {

    private func _bindViewModel() {
        self.submitBtn.rx.tap.bind {[unowned self]  in
            
            guard self.passwordTF.textField.text == self.passwordRepeateTF.textField.text else {
                Toast.show(R.string.localizable.changePasswordPageNewErrorToast())
                return
            }
            
            let old = self.oldPasswordTF.textField.text ?? ""
            let new = self.passwordTF.textField.text ?? ""
            
            guard !ViteInputValidator.isValidWalletPassword(str: new) else {
                Toast.show(R.string.localizable.mnemonicBackupPageErrorTypePwdIllegal())
                return
            }
            
            HDWalletManager.instance.changePassword(old: old, new: new) { [unowned self] ret in
                if ret {
                    Toast.show(R.string.localizable.changePasswordPageSuccessToast())
                    self.dismiss()
                } else {
                    Toast.show(R.string.localizable.changePasswordPageOldErrorToast())
                }
            }
            
        }.disposed(by: rx.disposeBag)
    }
}

class ChangePasswordViewController: BaseViewController {
    fileprivate var createNameAndPwdVM: CreateNameAndPwdVM?

    var disposeBag = DisposeBag()
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self._setupView()
        #if DEBUG
        self.oldPasswordTF.textField.text = "qqqqqqqq"
        self.passwordTF.textField.text = "qqqqqqqq"
        self.passwordRepeateTF.textField.text = "qqqqqqqq"
        #endif
        self._bindViewModel()
    }

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 24, right: 24)).then {
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    lazy var oldPasswordTF: TitlePasswordInputView = {
        let passwordTF = TitlePasswordInputView(title: R.string.localizable.changePasswordPageOldTitle())
        passwordTF.textField.returnKeyType = .next
        passwordTF.textField.delegate = self
        passwordTF.titleLabel.textColor = Colors.titleGray
        passwordTF.titleLabel.font = AppStyle.formHeader.font
        passwordTF.textField.textColor = Colors.descGray
        passwordTF.textField.font = AppStyle.formHeader.font
        return passwordTF
    }()
    
    lazy var passwordTF: TitlePasswordInputView = {
        let passwordTF = TitlePasswordInputView(title: R.string.localizable.changePasswordPageNew1Title())
        passwordTF.textField.returnKeyType = .next
        passwordTF.textField.delegate = self
        passwordTF.titleLabel.textColor = Colors.titleGray
        passwordTF.titleLabel.font = AppStyle.formHeader.font
        passwordTF.textField.textColor = Colors.descGray
        passwordTF.textField.font = AppStyle.formHeader.font
        return passwordTF
    }()

    lazy var passwordRepeateTF: TitlePasswordInputView = {
        let passwordTF = TitlePasswordInputView(title: R.string.localizable.changePasswordPageNew2Title())
        passwordTF.textField.returnKeyType = .done
        passwordTF.textField.delegate = self
        passwordTF.titleLabel.textColor = Colors.titleGray
        passwordTF.titleLabel.font = AppStyle.formHeader.font
        passwordTF.textField.textColor = Colors.descGray
        passwordTF.textField.font = AppStyle.formHeader.font
        return passwordTF
    }()

    lazy var submitBtn: UIButton = {
        var submitBtn = UIButton.init(style: .blue)
        submitBtn.setTitle(R.string.localizable.changePasswordPageButtonTitle(), for: .normal)
        submitBtn.titleLabel?.adjustsFontSizeToFitWidth  = true
        submitBtn.setBackgroundImage(UIImage.color(Colors.btnDisableGray), for: .disabled)
        return submitBtn
    }()
}

extension ChangePasswordViewController {

    private func _setupView() {
        self.view.backgroundColor = .white
        navigationTitleView = NavigationTitleView(title: R.string.localizable.changePasswordPageTitle())

        self._addViewConstraint()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
    }

    private func _addViewConstraint() {
        view.insertSubview(scrollView, at: 0)
        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)
        }
        
        self.oldPasswordTF.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(60)
        }
        
        self.passwordTF.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(60)
        }

        self.passwordRepeateTF.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(60)
        }
        
        
        scrollView.stackView.addArrangedSubview(oldPasswordTF)
        scrollView.stackView.addPlaceholder(height: 30)
        scrollView.stackView.addArrangedSubview(passwordTF)
        scrollView.stackView.addPlaceholder(height: 30)
        scrollView.stackView.addArrangedSubview(passwordRepeateTF)
        scrollView.stackView.addPlaceholder(height: 30)

        view.addSubview(self.submitBtn)
        self.submitBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(scrollView.snp.bottom)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.oldPasswordTF.textField {
            _ = self.passwordTF.textField.becomeFirstResponder()
        } else if textField == self.passwordTF.textField {
            _ = self.passwordRepeateTF.textField.becomeFirstResponder()
        } else if textField == self.passwordRepeateTF.textField {
            _ = self.passwordRepeateTF.textField.resignFirstResponder()
        }
        return true
    }
}
