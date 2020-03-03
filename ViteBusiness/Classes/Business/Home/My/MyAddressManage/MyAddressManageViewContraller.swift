//
//  MyAddressManageViewContraller.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/24.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources

class MyAddressManageViewController: BaseTableViewController {

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, MyAddressManageAddressViewModelType>>


    let tableViewModel: MyAddressManagerTableViewModelType
    let currentAddress = HDWalletManager.instance.account?.address

    var defaultIndex = -1

    init(tableViewModel: MyAddressManagerTableViewModelType) {
        self.tableViewModel = tableViewModel
        super.init(.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if currentAddress != HDWalletManager.instance.account?.address {
            tableViewModel.addressDidChangeWhenViewDidDisappear()
        }
    }

    lazy var headerView = MyAddressManageHeaderView(showAddressesTips: self.tableViewModel.showAddressesTips)
    let generateButton = UIButton().then {
        $0.setTitle(R.string.localizable.addressManageAddressGenerateButtonTitle(), for: .normal)
        $0.setImage(R.image.icon_button_add(), for: .normal)
        $0.setImage(R.image.icon_button_add(), for: .highlighted)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        $0.setBackgroundImage(R.image.background_add_button_white()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.background_add_button_white()?.tintColor(UIColor(netHex: 0xefefef)).resizable, for: .highlighted)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25 + 10)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowRadius = 3
        $0.layer.shadowOffset = CGSize(width: 0, height: 0)
    }

    fileprivate func setupView() {
        navigationTitleView = NavigationTitleView(title: R.string.localizable.addressManagePageTitle(tableViewModel.coinType.rawValue))
        customHeaderView = headerView

        tableView.rowHeight = MyAddressManageAddressCell.cellHeight()
        tableView.estimatedRowHeight = MyAddressManageAddressCell.cellHeight()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        view.addSubview(generateButton)
        generateButton.snp.makeConstraints { (m) in
            m.centerX.equalTo(view)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
            m.height.equalTo(50)
        }
    }

    fileprivate let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: MyAddressManageAddressCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item)
        return cell
    })

    fileprivate func bind() {



        tableViewModel.addressesDriver.asObservable()
            .map { [SectionModel(model: "addresses", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)

        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableViewModel.setDefaultAddressIndex(indexPath.row)
            }
            .disposed(by: rx.disposeBag)

        tableViewModel.defaultAddressNameDriver.drive(headerView.nameLabel.rx.text).disposed(by: rx.disposeBag)
        tableViewModel.defaultAddressDriver.drive(onNext: { [weak self] (index,address) in
            guard let `self` = self else { return }
            self.headerView.numberButton.setTitle("#\(index)", for: .normal)
            let style = NSMutableParagraphStyle()
            style.firstLineHeadIndent = 30
            let attributes = [NSAttributedString.Key.paragraphStyle: style]
            self.headerView.addressLabel.attributedText = NSAttributedString(string: address, attributes: attributes)

        }).disposed(by: rx.disposeBag)

        generateButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.tableViewModel.generateAddress { [weak self] (ret) in
                guard let `self` = self else { return }
                if ret {
                    self.tableView.scrollToRow(at: IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }.disposed(by: rx.disposeBag)

        headerView.tipButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            Alert.show(into: self, title: R.string.localizable.hint(),
                       message: R.string.localizable.addressManageTipAlertMessage(),
                       actions: [(Alert.UIAlertControllerAletrActionTitle.default(title: R.string.localizable.addressManageTipAlertOk()), nil)])
        }.disposed(by: rx.disposeBag)
    }
}
