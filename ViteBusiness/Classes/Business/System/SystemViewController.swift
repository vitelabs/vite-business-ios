//
//  SystemViewController.swift
//  Vite
//
//  Created by Water on 2018/9/12.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import Eureka
import Vite_HDWalletKit
import LocalAuthentication
import RxSwift
import RxCocoa
import NSObject_Rx

class SystemViewController: FormViewController {
    fileprivate var viewModel: SystemViewModel

    init() {
        self.viewModel = SystemViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var navigationBarStyle = NavigationBarStyle.default
    var navigationTitleView: NavigationTitleView? {
        didSet {
            if let old = oldValue {
                old.removeFromSuperview()
            }

            if let new = navigationTitleView {
                view.addSubview(new)
                new.snp.makeConstraints { (m) in
                    m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
                    m.left.equalTo(view)
                    m.right.equalTo(view)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NavigationBarStyle.configStyle(navigationBarStyle, viewController: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self._setupView()
    }

    lazy var deleteBtn: UIButton = {
        let deleteBtn = UIButton(style: .lightBlue)
        deleteBtn.setTitle(R.string.localizable.systemPageCellDeleteWalletTitle(), for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteBtnAction), for: .touchUpInside)
        return deleteBtn
    }()

    @objc func deleteBtnAction() {

        self.verifyWalletPassword { (_) in
            HUD.show()
            DispatchQueue.global().async {
                HDWalletManager.instance.deleteWallet()
                KeychainService.instance.clearCurrentWallet()
                DispatchQueue.main.async {
                    HUD.hide()
                    NotificationCenter.default.post(name: .logoutDidFinish, object: nil)
                }
            }
        }
    }

    private func _setupView() {
        navigationTitleView = NavigationTitleView(title: R.string.localizable.myPageSystemCellTitle())
        self.view.backgroundColor = .white
        self.automaticallyAdjustsScrollViewInsets = false

        self.setupTableView()
    }

    func setupTableView() {
        self.tableView.backgroundColor = .white
        self.tableView.separatorStyle = .none
        self.tableView.alwaysBounceVertical = false

        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)

        }

        view.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom).offset(24)
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }

        ViteSwitchRow.defaultCellSetup = { cell, row in
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins.left = 24
            cell.layoutMargins.right = 24
            cell.selectionStyle = .none
            cell.textLabel?.adjustsFontSizeToFitWidth = true
        }
        ImageRow.defaultCellSetup = { cell, row in
            cell.selectionStyle = .none
        }

        form
            +++
            Section {
                $0.header = HeaderFooterView<UIView>(.class)
                $0.header?.height = { 0.01 }
            }
            <<< ImageRow("systemPageCellChangeLanguage") {
                $0.cell.titleLab.text = R.string.localizable.systemPageCellChangeLanguage()
                $0.cell.rightImageView.image = R.image.icon_right_white()?.tintColor(Colors.titleGray).resizable
                $0.cell.bottomSeparatorLine.isHidden = false
                $0.cell.rightLab.text = LocalizationService.sharedInstance.currentLanguage.name
            }.onCellSelection({ [unowned self] _, _  in
                self.showChangeLanguageList(isSettingPage: true)
            })

            <<< ImageRow("systemPageCellChangeCurrency") {
                $0.cell.titleLab.text = R.string.localizable.systemPageCellChangeCurrency()
                $0.cell.rightImageView.image = R.image.icon_right_white()?.tintColor(Colors.titleGray).resizable
                $0.cell.bottomSeparatorLine.isHidden = false
                $0.cell.rightLab.text = AppSettingsService.instance.currency.name
                }.onCellSelection({ [unowned self] _, _  in
                    guard let cell = self.form.rowBy(tag: "systemPageCellChangeCurrency") as? ImageRow else { return }
                    let vc = CurrencyViewController()
                    vc.selectCurrency.filterNil().asObservable().bind {
                        cell.cell.rightLab.text = $0.name
                        cell.updateCell()
                        }.disposed(by: self.rx.disposeBag)
                    self.navigationController?.pushViewController(vc, animated: true)
                })

            <<< ViteSwitchRow("systemPageCellLoginPwd") {[unowned self] in
                $0.title = R.string.localizable.systemPageCellLoginPwd()
                $0.cell.height = { 60 }
                $0.cell.bottomSeparatorLine.isHidden = false
                $0.value = self.viewModel.isRequireAuthentication
            }.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = Colors.cellTitleGray
                    cell.textLabel?.font = Fonts.light16
                }) .onChange { row  in
                    guard let enabled = row.value else { return }
                    HDWalletManager.instance.setIsRequireAuthentication(enabled)
            }

            <<< ViteSwitchRow("systemPageCellLoginFaceId") {[unowned self] in
                let authType = BiometryAuthenticationType.current
                let title = authType == .faceID ? R.string.localizable.systemPageCellLoginFaceId() : R.string.localizable.systemPageCellLoginTouchId()
                $0.title = title
                $0.value = self.viewModel.isAuthenticatedByBiometry
                $0.cell.height = { 60 }
                $0.cell.bottomSeparatorLine.isHidden = false
                $0.hidden = self.viewModel.isTransferByBiometryHide ? "TRUEPREDICATE" :"$systemPageCellLoginPwd == false"
            }.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = Colors.cellTitleGray
                    cell.textLabel?.font = Fonts.light16
                }) .onChange { [unowned self] row in
                    guard let enabled = row.value else { return }
                    self.showBiometricAuth("systemPageCellLoginFaceId", value: enabled)
            }

            <<< ViteSwitchRow("systemPageCellTransferFaceId") { [unowned self] in
                let authType = BiometryAuthenticationType.current
                let title = authType == .faceID ? R.string.localizable.systemPageCellTransferFaceId() : R.string.localizable.systemPageCellTransferTouchId()
                $0.title = title
                $0.value = self.viewModel.isTransferByBiometry
                $0.cell.height = { 60 }
                $0.cell.bottomSeparatorLine.isHidden = false
            }.cellUpdate({ [unowned self] (cell, _) in
                   cell.textLabel?.textColor = Colors.cellTitleGray
                   cell.textLabel?.font = Fonts.light16
                   cell.isHidden = self.viewModel.isTransferByBiometryHide
                }) .onChange { [unowned self] row in
                    guard let enabled = row.value else { return }
                    self.showBiometricAuth("systemPageCellTransferFaceId", value: enabled)
            }
            <<< ImageRow("uploadLog") {
                $0.cell.titleLab.text = R.string.localizable.systemPageCellUploadLogTitle()
                $0.cell.rightImageView.image = R.image.icon_right_white()?.tintColor(Colors.titleGray).resizable
                $0.cell.bottomSeparatorLine.isHidden = false
            }.onCellSelection({ [unowned self] _, _  in

            })

        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo((self.navigationTitleView?.snp.bottom)!)
            make.left.right.bottom.equalTo(self.view)
        }
    }
}

extension SystemViewController {
    private func showBiometricAuth(_ tag: String, value: Bool) {
        self.touchValidation(tag, value: value)
    }

    private func touchValidation(_ tag: String, value: Bool) {
        BiometryAuthenticationManager.shared.authenticate(reason: R.string.localizable.lockPageFingerprintAlterTitle(), completion: { (success, error) in
            guard success else {
                self.changeSwitchRowValue(tag, value: false)
                if let error = error {
                    Toast.show(error.localizedDescription)
                }
                return
            }
            if tag == "systemPageCellLoginFaceId" {
                HDWalletManager.instance.setIsAuthenticatedByBiometry(value)
            } else {
                HDWalletManager.instance.setIsTransferByBiometry(value)
            }
        })
    }

    func changeSwitchRowValue (_ tag: String, value: Bool) {
        let row = self.form.rowBy(tag: tag) as! ViteSwitchRow
        row.value = value
        row.updateCell()
    }
}


