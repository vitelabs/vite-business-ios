//
//  MyHomeViewController.swift
//  Vite
//
//  Created by Stone on 2018/9/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources

class MyHomeViewController: BaseTableViewController {

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, MyHomeListCellViewModel>>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    private lazy var titleBtn: UIButton = {
        let titleBtn = UIButton(type: .custom)
        titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        titleBtn.setTitleColor(UIColor(netHex: 0x24272B), for: .normal)
        titleBtn.setTitleColor(UIColor(netHex: 0x24272B), for: .highlighted)
        return titleBtn
    }()

    lazy var logoutBtn: UIButton = {
        let logoutBtn = UIButton(style: .lightBlue)
        logoutBtn.setTitle(R.string.localizable.systemPageCellLogoutTitle(), for: .normal)
        logoutBtn.addTarget(self, action: #selector(logoutBtnAction), for: .touchUpInside)
        return logoutBtn
    }()

    fileprivate func setupView() {
        statisticsPageName = Statistics.Page.MyHome.name
        navigationTitleView = createNavigationTitleView()
        self.titleBtn.setTitle(HDWalletManager.instance.wallet?.name, for: .normal)
        self.titleBtn.setTitle(HDWalletManager.instance.wallet?.name, for: .highlighted)
        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)
            m.bottom.equalTo(view).offset(-74)
        }

        let headerView = MyHomeListHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 116))
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        tableView.alwaysBounceVertical = false

        self.view.addSubview(self.logoutBtn)
        self.logoutBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(24)
            make.right.equalTo(self.view).offset(-24)
            make.height.equalTo(50)
            make.bottom.equalTo(self.view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }
    }

    fileprivate let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: MyHomeListCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item)
        return cell
    })

    fileprivate func bind() {
        AppConfigService.instance.configDriver.asObservable().map { config -> [SectionModel<String, MyHomeListCellViewModel>] in
            let configViewModel = MyHomeConfigViewModel(JSON: config.myPage)!
            #if DAPP
            let items = configViewModel.items.filter({ $0.isValid && $0.type != .custom })
            #else
            let items = configViewModel.items.filter({ $0.isValid }).filter({ item in
                if AppConfigService.instance.isOnlineVersion {
                    return true
                } else {
                    if item.url.hasPrefix("https://growth.vite.net/invite") {
                        return false
                    } else {
                        return true
                    }
                }
            })
            #endif
            return [SectionModel(model: "item", items: items)]
        }.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        tableView.separatorStyle = .none
        tableView.rowHeight = MyHomeListCell.cellHeight
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                if let viewModel = (try? self.dataSource.model(at: indexPath)) as? MyHomeListCellViewModel {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    viewModel.clicked(viewController: self)
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

extension MyHomeViewController: MyHomeListHeaderViewDelegate {
    func contactsBtnAction() {
        Statistics.log(eventId: Statistics.Page.MyHome.contactClicked.rawValue)
        let vc = ContactsHomeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    func mnemonicBtnAction() {
        Statistics.log(eventId: Statistics.Page.MyHome.mnemonicClicked.rawValue)
        self.verifyWalletPassword(callback: { password in

            if !HDWalletManager.instance.isBackedUp {
                let vc = BackupMnemonicViewController(password: password)
                let nav = BaseNavigationController(rootViewController: vc)
                UIViewController.current?.present(nav, animated: true, completion: nil)
            } else {
                let vc = ExportMnemonicViewController()
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }

    @objc func titleBtnAction() {
        DispatchQueue.main.async {
            self.showInputDialog(title: R.string.localizable.myPageChangeWalletNameAlterTitle(),
                                 actionTitle: R.string.localizable.confirm(),
                                 cancelTitle: R.string.localizable.cancel(),
                                 inputPlaceholder: HDWalletManager.instance.wallet?.name)
            {[weak self]   (input:String?) in
                self?.changeWalletName(name:input)
            }
        }
    }
}


extension MyHomeViewController {
    func changeWalletName(name: String?) {
        let name = name ?? ""
        var changed = false

        if name.isEmpty {
            self.view.showToast(str: R.string.localizable.manageWalletPageErrorTypeName())
            return
        }
        if !ViteInputValidator.isValidWalletName(str: name ) {
            self.view.showToast(str: R.string.localizable.mnemonicBackupPageErrorTypeNameValid())
            return
        }
        if !ViteInputValidator.isValidWalletNameCount(str: name  ) {
            self.view.showToast(str: R.string.localizable.mnemonicBackupPageErrorTypeValidWalletNameCount())
            return
        }
        changed = true
        self.view.displayLoading(text: R.string.localizable.manageWalletPageChangeNameLoading(), animated: true)
        DispatchQueue.global().async {
            HDWalletManager.instance.updateName(name: name)
            DispatchQueue.main.async {
                self.view.hideLoading()
                self.titleBtn.setTitle(HDWalletManager.instance.wallet?.name, for: .normal)
                self.titleBtn.setTitle(HDWalletManager.instance.wallet?.name, for: .highlighted)
            }
        }
    }
}

extension MyHomeViewController {
    func createNavigationTitleView() -> UIView {
        let view = UIView().then {
            $0.backgroundColor = UIColor.white
        }

        view.addSubview(self.titleBtn)
        self.titleBtn.snp.makeConstraints { (m) in
            m.top.equalTo(view).offset(6)
            m.left.equalTo(view).offset(24)
            m.bottom.equalTo(view).offset(-20)
            m.height.equalTo(29)
        }
        self.titleBtn.addTarget(self, action: #selector(titleBtnAction), for: .touchUpInside)

        let iconBtn = UIButton()
        iconBtn.setImage(R.image.icon_edit_name(), for: .normal)
        iconBtn.setImage(R.image.icon_edit_name(), for: .highlighted)
        view.addSubview(iconBtn)
        iconBtn.snp.makeConstraints { (m) in
            m.centerY.equalTo(self.titleBtn)
            m.left.equalTo(self.titleBtn.snp.right).offset(4)
        }
        iconBtn.addTarget(self, action: #selector(titleBtnAction), for: .touchUpInside)

        return view
    }
}

extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "",
                         cancelTitle:String? = "",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.text = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: {[weak alert] (action:UIAlertAction) in
            guard let textField =  alert?.textFields?.first else {
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MyHomeViewController {
    @objc func logoutBtnAction() {
        Statistics.log(eventId: Statistics.Page.MyHome.logoutClicked.rawValue)

        func logout() {
            self.view.displayLoading(text: R.string.localizable.systemPageLogoutLoading(), animated: true)
            DispatchQueue.global().async {
                HDWalletManager.instance.logout()
                KeychainService.instance.clearCurrentWallet()
                DispatchQueue.main.async {
                    self.view.hideLoading()
                    NotificationCenter.default.post(name: .logoutDidFinish, object: nil)
                }
            }
        }

        if !HDWalletManager.instance.isBackedUp {
            CreateWalletService.sharedInstance.setNeedBackup()
            CreateWalletService.sharedInstance.showBackUpTipAlert(cancel: { })
        } else {
            logout()
        }
    }
}
