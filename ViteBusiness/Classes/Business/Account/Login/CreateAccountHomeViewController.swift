//
//  LoginViewController.swift
//  Vite
//
//  Created by Water on 2018/9/5.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class CreateAccountHomeViewController: BaseViewController {
    fileprivate var viewModel: CreateAccountHomeVM

    init() {
        self.viewModel = CreateAccountHomeVM()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self._setupView()
        self._bindViewModel()
    }

    private func _bindViewModel() {
        self.viewModel.createAccountBtnStr.asObservable().bind(to: self.createAccountBtn.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        self.viewModel.recoverAccountBtnStr.asObservable().bind(to: self.importAccountBtn.rx.title(for: .normal)).disposed(by: rx.disposeBag)
        self.viewModel.changeLanguageBtnStr.asObservable().bind {[weak self] (text) in
            guard let `self` = self else { return }
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: text, style: .plain, target: self, action: #selector(self.changeLanguageBtnAction))
        }.disposed(by: rx.disposeBag)
    }

    lazy var createAccountBtn: UIButton = {
        let createAccountBtn = UIButton.init(style: .blue)
        createAccountBtn.setTitle(R.string.localizable.createAccount(), for: .normal)
        createAccountBtn.titleLabel?.adjustsFontSizeToFitWidth  = true
        createAccountBtn.addTarget(self, action: #selector(createAccountBtnAction), for: .touchUpInside)
        return createAccountBtn
    }()

    lazy var importAccountBtn: UIButton = {
        let importAccountBtn = UIButton.init(style: .whiteWithShadow)
        importAccountBtn.setTitle(R.string.localizable.importAccount(), for: .normal)
        importAccountBtn.titleLabel?.adjustsFontSizeToFitWidth  = true
        importAccountBtn.addTarget(self, action: #selector(importAccountBtnAction), for: .touchUpInside)
        return importAccountBtn
    }()
}

extension CreateAccountHomeViewController {
    private func _setupView() {
        self.view.backgroundColor = .clear
        navigationBarStyle = .clear
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_nav_scan_black(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(scan))
        self._addViewConstraint()
    }

    @objc private func scan() {
        let scanViewController = ScanViewController()
        _ = scanViewController.rx.result.bind { [weak scanViewController, self] result in
            if let url = URL(string: result), ViteAppSchemeHandler.instance.handleViteScheme(url, allowActions: [.backupWallet]) {
                self.navigationController?.popViewController(animated: true)
            } else {
                scanViewController?.showAlertMessage(result)
            }
        }
        self.navigationController?.pushViewController(scanViewController, animated: true)
    }

    private func _addViewConstraint() {
        let bgImgView = UIImageView.init(image: R.image.login_bg())
        self.view.addSubview(bgImgView)
        bgImgView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }

        let logoImgView = UIImageView.init(image: R.image.icon_vite_logo())
        let sloganImgView = UIImageView.init(image: R.image.splash_slogen())
        sloganImgView.contentMode = UIView.ContentMode.scaleAspectFit
        self.view.addSubview(logoImgView)
        logoImgView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(30)
            make.top.equalTo(self.view).offset(100)
        }
        self.view.addSubview(sloganImgView)
        sloganImgView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(30)
            make.right.equalTo(self.view).offset(-60)
            make.top.equalTo(logoImgView.snp.bottom).offset(50)
        }

        self.view.addSubview(self.importAccountBtn)
        self.importAccountBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(24)
            make.right.equalTo(self.view).offset(-24)
            make.height.equalTo(50)
            make.bottom.equalTo(self.view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }

        self.view.addSubview(self.createAccountBtn)
        self.createAccountBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(24)
            make.right.equalTo(self.view).offset(-24)
            make.height.equalTo(50)
            make.bottom.equalTo(self.importAccountBtn.snp.top).offset(-24)
        }
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    @objc func createAccountBtnAction() {
        let vc = CreateWalletAccountViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func importAccountBtnAction() {
        let vc = ImportAccountViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func changeLanguageBtnAction() {
        self.showChangeLanguageList()
    }
}
