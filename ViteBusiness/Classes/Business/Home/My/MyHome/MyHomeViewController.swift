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
            return [SectionModel(model: "item", items: configViewModel.items)]
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
        let vc = TransactionListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    func mnemonicBtnAction() {
        let vc = ManageWalletViewController()
        navigationController?.pushViewController(vc, animated: true)
    }


    
}


extension MyHomeViewController {
    func changeWalletName(name: String?) {

        let name = name ?? ""
        var changed = false

        defer {
            if !changed {
//                self.nameTextField?.text = HDWalletManager.instance.wallet?.name
            }
        }

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

        self.titleBtn.rx.tap.bind { [weak self] in
            self?.changeWalletName(name:HDWalletManager.instance.wallet?.name )
            }.disposed(by: rx.disposeBag)
        return view
    }
}


extension MyHomeViewController {
    @objc func logoutBtnAction() {
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
}
