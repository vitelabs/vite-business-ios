//
//  ImportAccountViewController.swift
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

extension ImportAccountViewController {
    private func _bindViewModel() {
        self.importAccountVM = ImportAccountVM.init(input: (self.contentTextView.contentTextView, self.createNameAndPwdView.walletNameTF.textField, self.createNameAndPwdView.passwordTF.textField, self.createNameAndPwdView.passwordRepeateTF.textField))


        Driver.combineLatest(
        self.importAccountVM!.submitBtnEnable,
        checkButton.checkButton.rx.observe(Bool.self, #keyPath(UIButton.isSelected)).asDriver(onErrorJustReturn: false))
        .map({ (r1, r2) -> Bool in
            if let r2 = r2 {
                return r1 && r2
            } else {
                return false
            }
        })
        .drive(onNext: { [unowned self] (r) in
            self.confirmBtn.isEnabled = r
        }).disposed(by: rx.disposeBag)

        self.confirmBtn.rx.tap.bind {[unowned self] in
            self.importAccountVM?.submitAction.execute((self.contentTextView.text, self.createNameAndPwdView.walletNameTF.textField.text ?? "", self.createNameAndPwdView.passwordTF.textField.text ?? "", self.createNameAndPwdView.passwordRepeateTF.textField.text ?? "")).subscribe(onNext: {[unowned self] (result) in
                switch result {
                case .ok:
                    self.goNextVC()
                case .empty, .failed:
                    self.view.showToast(str: result.description)
                }
            }).disposed(by: self.disposeBag)
        }.disposed(by: rx.disposeBag)
    }
}

class ImportAccountViewController: BaseViewController {
    fileprivate var importAccountVM: ImportAccountVM?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self._setupView()
        self._bindViewModel()

        self.createNameAndPwdView.inviteCodeTF.textField.text = CreateWalletService.sharedInstance.vitexInviteCode
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
    }

    lazy var contentTextView: MnemonicTextView = {
        let contentTextView =  MnemonicTextView(isEditable: true)
        return contentTextView
    }()

    lazy var createNameAndPwdView: CreateNameAndPwdView = {
        let createNameAndPwdView = CreateNameAndPwdView()
        return createNameAndPwdView
    }()

    lazy var confirmBtn: UIButton = {
        let confirmBtn = UIButton.init(style: .blue)
        confirmBtn.setTitle(R.string.localizable.importPageSubmitBtn(), for: .normal)
        confirmBtn.titleLabel?.adjustsFontSizeToFitWidth  = true
        confirmBtn.setBackgroundImage(UIImage.color(Colors.btnDisableGray), for: .disabled)
        return confirmBtn
    }()

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 24, right: 24)).then {
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

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
}

extension ImportAccountViewController {

    @objc func onScan() {
        let scanViewController = ScanViewController()
        _ = scanViewController.rx.result.bind { [weak scanViewController, self] result in
               if let url = URL(string: result), url.scheme == "viteapp", url.host == "backup-wallet",
                   let name = url.queryParameters["name"]?.removingPercentEncoding,
               let entropy = url.queryParameters["entropy"]?.removingPercentEncoding,
               let language = url.queryParameters["language"]?.removingPercentEncoding,
               let password = url.queryParameters["password"]?.removingPercentEncoding,
               let uri = CreateWalletService.BackupWalletURI(name: name, entropy: entropy, languageString: language, password: password) {
                self.contentTextView.contentTextView.text = uri.mnemonic
                self.navigationController?.popViewController(animated: true)
               } else {
                scanViewController?.showAlertMessage(result)
            }
        }
        self.navigationController?.pushViewController(scanViewController, animated: true)
    }

    private func _setupView() {
        self.view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_button_scan_gray(), style: .plain, target: self, action: #selector(onScan))
        navigationTitleView = NavigationTitleView(title: R.string.localizable.importPageTitle())

        self._addViewConstraint()
    }

    private func _addViewConstraint() {
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)
        }

        scrollView.stackView.addArrangedSubview(contentTextView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(createNameAndPwdView)
        self.contentTextView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(142)
        }

        scrollView.stackView.addPlaceholder(height: 15)
        scrollView.stackView.addArrangedSubview(checkButton)

        view.addSubview(self.confirmBtn)
        self.confirmBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(scrollView.snp.bottom)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }
    }

    func goNextVC() {

        func go() {
            guard let language = self.importAccountVM?.language else { return }
            let name  = self.createNameAndPwdView.walletNameTF.textField.text!.trimmingCharacters(in: .whitespaces)
            let password = self.createNameAndPwdView.passwordRepeateTF.textField.text ?? ""
            let mnemonic = ViteInputValidator.handleMnemonicStrSpacing(self.contentTextView.text)
            HDWalletManager.instance.importAndLoginWallet(name: name, mnemonic: mnemonic, language: language, password: password, completion: { _ in })
        }

        if let text = self.createNameAndPwdView.inviteCodeTF.textField.text, !text.isEmpty {
            HUD.show()
            WalletManager.instance.checkVitexInviteCode(vitexInviteCode: text).always {
                HUD.hide()
            }.done { (ret) in
                if ret {
                    CreateWalletService.sharedInstance.vitexInviteCode = text
                    Statistics.logWithUUIDAndAddress(eventId: Statistics.Page.CreateWallet.importWithInviteCode.rawValue)
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
