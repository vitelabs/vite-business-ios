//
//  CreateWalletAccountViewController.swift
//  Vite
//
//  Created by Water on 2018/9/6.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import NSObject_Rx
import Vite_HDWalletKit
import ActiveLabel
import ViteWallet

extension CreateWalletAccountViewController {

    private func _bindViewModel() {
        self.createNameAndPwdVM = CreateNameAndPwdVM(input: (self.createNameAndPwdView.walletNameTF.textField, self.createNameAndPwdView.passwordTF.textField, self.createNameAndPwdView.passwordRepeateTF.textField))

        self.submitBtn.rx.tap.bind {[unowned self]  in
          self.createNameAndPwdVM?.submitAction.execute((self.createNameAndPwdView.walletNameTF.textField.text ?? "", self.createNameAndPwdView.passwordTF.textField.text ?? "", self.createNameAndPwdView.passwordRepeateTF.textField.text ?? "")).subscribe(onNext: { [unowned self](result) in
                switch result {
                case .ok:
                    self.goNextVC()
                case .empty, .failed:
                    self.view.showToast(str: result.description)
                }
            }).disposed(by: self.disposeBag)
        }.disposed(by: rx.disposeBag)

        Driver.combineLatest(
            self.createNameAndPwdVM!.submitBtnEnable,
            checkButton.checkButton.rx.observe(Bool.self, #keyPath(UIButton.isSelected)).asDriver(onErrorJustReturn: false))
            .map({ (r1, r2) -> Bool in
                if let r2 = r2 {
                    return r1 && r2
                } else {
                    return false
                }
            })
            .drive(onNext: { [unowned self] (r) in
                self.submitBtn.isEnabled = r
            }).disposed(by: rx.disposeBag)
    }
}

class CreateWalletAccountViewController: BaseViewController {
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
        self.createNameAndPwdView.walletNameTF.textField.text = "Debug"
        self.createNameAndPwdView.passwordTF.textField.text = "qqqqqqqq"
        self.createNameAndPwdView.passwordRepeateTF.textField.text = "qqqqqqqq"
        self.checkButton.checkButton.isSelected = true
        #endif
        self._bindViewModel()
        self.createNameAndPwdView.inviteCodeTF.textField.text = CreateWalletService.sharedInstance.vitexInviteCode
    }

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 24, right: 24)).then {
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    lazy var createNameAndPwdView: CreateNameAndPwdView = {
        let createNameAndPwdView = CreateNameAndPwdView()
        return createNameAndPwdView
    }()

    let checkButton = BackupMnemonicViewController.ConfirmView().then { view in
        view.label.text = R.string.localizable.mnemonicBackupPageCheckButton3Title() + R.string.localizable.mnemonicBackupPageClauseButtonTitle()
        let customType = ActiveType.custom(pattern: R.string.localizable.mnemonicBackupPageCheckButton3Title())
        let termType = ActiveType.custom(pattern: R.string.localizable.mnemonicBackupPageClauseButtonTitle())
        view.label.enabledTypes = [termType, customType]
        view.label.customize { [weak view] label in
            label.customColor[customType] = view?.label.textColor
            label.customSelectedColor[customType] = view?.label.textColor
            label.handleCustomTap(for: customType) { [weak view] element in
                view?.checkButton.isSelected = !(view?.checkButton.isSelected ?? true)
            }
        }

        view.label.customize { label in
            label.customColor[termType] = UIColor(netHex: 0x007AFF)
            label.customSelectedColor[termType] = UIColor(netHex: 0x007AFF).highlighted
            label.handleCustomTap(for: termType) { element in
                guard let url = URL(string: "https://growth.vite.net/term") else { return }
                let vc = WKWebViewController.init(url: url)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    lazy var submitBtn: UIButton = {
        var submitBtn = UIButton.init(style: .blue)
    submitBtn.setTitle(R.string.localizable.createPageSubmitBtnTitle(), for: .normal)
        submitBtn.titleLabel?.adjustsFontSizeToFitWidth  = true
        submitBtn.setBackgroundImage(UIImage.color(Colors.btnDisableGray), for: .disabled)
        return submitBtn
    }()
}

extension CreateWalletAccountViewController {

    private func _setupView() {
        self.view.backgroundColor = .white
        navigationTitleView = NavigationTitleView(title: R.string.localizable.createPageTitle())

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
        scrollView.stackView.addArrangedSubview(createNameAndPwdView)
        scrollView.stackView.addPlaceholder(height: 15)
        scrollView.stackView.addArrangedSubview(checkButton)

        view.addSubview(self.submitBtn)
        self.submitBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(scrollView.snp.bottom)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }
    }

    func goNextVC() {

        func go() {
            let name = self.createNameAndPwdView.walletNameTF.textField.text!.trimmingCharacters(in: .whitespaces)
            let password = self.createNameAndPwdView.passwordRepeateTF.textField.text!
            CreateWalletService.sharedInstance.set(name: name, password: password)
            let vc = CreateWalletTipViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }

        if let text = self.createNameAndPwdView.inviteCodeTF.textField.text, !text.isEmpty {
            HUD.show()
            WalletManager.instance.checkVitexInviteCode(vitexInviteCode: text).always {
                HUD.hide()
            }.done { (ret) in
                if ret {
                    CreateWalletService.sharedInstance.vitexInviteCode = text
                    Statistics.logWithUUIDAndAddress(eventId: Statistics.Page.CreateWallet.createWithInviteCode.rawValue)
                    go()
                } else {
                    Toast.show(R.string.localizable.createPageToastErrorInviteCode())
                }
            }.catch { (error) in
                Toast.show(ViteError.conversion(from: error).viteErrorMessage)
            }
        } else {
            go()
        }

    }
}
