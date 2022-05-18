//
//  ExportMnemonicViewController.swift
//  Vite
//
//  Created by Water on 2018/9/12.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import Vite_HDWalletKit

extension UIViewController {
    func verifyWalletPassword(callback: @escaping (String) -> Void) {
        let controller = AlertControl(title: R.string.localizable.exportPageAlterTitle(), message: nil)
        let cancelAction = AlertAction(title: R.string.localizable.cancel(), style: .light, handler: nil)
        let okAction = AlertAction(title: R.string.localizable.confirm(), style: .light) { controller in
            Statistics.log(eventId: Statistics.Page.MyHome.mnemonicDeriveClicked.rawValue)
            let textField = (controller.textFields?.first)! as UITextField
            if HDWalletManager.instance.verifyPassword(textField.text ?? "") {
                DispatchQueue.main.async {
                    callback(textField.text ?? "")
                }
            } else {
                self.view.showToast(str: R.string.localizable.exportPageAlterPasswordError())
            }
        }
        controller.addPwdTextField { (textfield) in
            textfield.keyboardType = .asciiCapable
            textfield.isSecureTextEntry = true
            textfield.placeholder = R.string.localizable.exportPageAlterTfPlaceholder()
        }
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        controller.show()
    }
}

class ExportMnemonicViewController: BaseViewController {

    let password: String
    let forGrin: Bool
    init(password: String, forGrin: Bool = false) {
        self.password = password
        self.forGrin = forGrin
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self._setupView()

        if forGrin == false {
            updateQRImageView(name: HDWalletManager.instance.wallet!.name, mnemonic: HDWalletManager.instance.mnemonic!, language: HDWalletManager.instance.language!, password: password)
            
            if HDWalletManager.instance.language != MnemonicCodeBook.english {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.grinExportMnemonic(), style: .plain, target: self, action: #selector(onExportGrin))
            }
        }
    }

    lazy var contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()

    let qrImageView = UIImageView()

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 0, left: 24, bottom: 10, right: 24)).then {
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    lazy var mnemonicCollectionView: MnemonicCollectionView = {[unowned self]  in
        let mnemonicWordsStr = (self.forGrin ? HDWalletManager.instance.mnemonicForGrin : HDWalletManager.instance.mnemonic) ?? ""
        let array = mnemonicWordsStr.components(separatedBy: " ")
        let view = MnemonicCollectionView.init(isHasSelected: true)
        view.h_num = CGFloat(CGFloat(array.count) / 4.0)
        view.dataList = array
        view.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(kScreenH * ((array.count == 24 ? 186.0 : 110)/667.0))
        }
        
        return view
    }()

    lazy var confirmBtn: UIButton = {
        let confirmBtn = UIButton.init(style: .blue)
        confirmBtn.setTitle(R.string.localizable.confirm(), for: .normal)
        confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        return confirmBtn
    }()
    
    @objc func onExportGrin() {
        let vc = ExportMnemonicViewController(password: password, forGrin: true)
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ExportMnemonicViewController {

    private func _setupView() {
        self.view.backgroundColor = .white
        navigationTitleView = NavigationTitleView(title: R.string.localizable.exportPageTitle())

        self._addViewConstraint()
    }
    private func _addViewConstraint() {


        view.addSubview(scrollView)


        scrollView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.equalTo((self.navigationTitleView?.snp.bottom)!)
        }

        scrollView.stackView.addArrangedSubview(mnemonicCollectionView)

        if forGrin == false {
            let tip1View = UILabel().then {
                $0.textColor = UIColor(netHex: 0x24272B)
                $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                $0.text = R.string.localizable.mnemonicBackupPageTip1()
                $0.numberOfLines = 0
            }

            let tip2View = TipTextView(text: R.string.localizable.mnemonicBackupPageTip2())
            let tip3View = TipTextView(text: R.string.localizable.mnemonicBackupPageTip3())

            qrImageView.snp.makeConstraints { (m) in
                m.size.equalTo(CGSize(width: 140, height: 140))
            }

            scrollView.stackView.addPlaceholder(height: 16)
            scrollView.stackView.addArrangedSubview(tip1View)
            scrollView.stackView.addPlaceholder(height: 10)
            scrollView.stackView.addArrangedSubview(tip2View)
            scrollView.stackView.addPlaceholder(height: 4)
            scrollView.stackView.addArrangedSubview(tip3View)
            scrollView.stackView.addPlaceholder(height: 20)
            scrollView.stackView.addArrangedSubview(qrImageView.centerX())
        }

        self.view.addSubview(self.confirmBtn)
        self.confirmBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50)
            make.left.equalTo(self.view).offset(24)
            make.right.equalTo(self.view).offset(-24)
            make.top.equalTo(scrollView.snp.bottom).offset(20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }
    }

    @objc func confirmBtnAction() {
        Statistics.log(eventId: Statistics.Page.MyHome.mnemonicConfirmClicked.rawValue)
        self.navigationController?.popViewController(animated: true)
    }

    func updateQRImageView(name: String, mnemonic: String, language: MnemonicCodeBook, password: String) {
        guard let uri = CreateWalletService.BackupWalletURI(name: name,
                                                            mnemonic: mnemonic,
                                                            language: language,
                                                            password: password) else {
                                                                return

        }
        QRCodeHelper.createQRCode(string: uri.uri) { [weak self] image in
            self?.qrImageView.image = image
        }
    }
}
