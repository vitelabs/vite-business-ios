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

    private func _setupView() {
        navigationTitleView = NavigationTitleView(title: R.string.localizable.myPageSystemCellTitle())
        self.view.backgroundColor = .white
        self.automaticallyAdjustsScrollViewInsets = false

        self.setupTableView()
    }

    func setupTableView() {
        self.tableView.backgroundColor = .white
        self.tableView.separatorStyle = .none

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
            }.onCellSelection({ [unowned self] _, _  in
                self.showChangeLanguageList(isSettingPage: true)
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


