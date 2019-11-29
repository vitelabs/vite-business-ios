//
//  DeFiHomeViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/28.
//

import Foundation

class DeFiHomeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    let borrowButton = UIButton.topImage(R.image.icon_button_defi_borrow(), bottomTitle: R.string.localizable.defiHomePageBorrowButtonTitle())

    let myDefiButton = UIButton.topImage(R.image.icon_button_my_defi(), bottomTitle: R.string.localizable.defiHomePageMyDefiButtonTitle())

    let filtrateButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setImage(R.image.icon_defi_home_down_button(), for: .normal)
        $0.setImage(R.image.icon_defi_home_down_button()?.highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: -1)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 7)
        $0.backgroundColor = UIColor(netHex: 0x007AFF, alpha: 0.06)
        $0.setTitle("fdsfds", for: .normal)
    }

    let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
    }

    lazy var buttonsView = UIView().then {
        $0.addSubview(self.borrowButton)
        $0.addSubview(self.myDefiButton)

        self.borrowButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(10)
            m.left.equalToSuperview().offset(24)
            m.height.equalTo(77)
            m.bottom.equalToSuperview().offset(-16)
        }

        self.myDefiButton.snp.makeConstraints { (m) in
            m.top.bottom.width.equalTo(self.borrowButton)
            m.left.equalTo(self.borrowButton.snp.right).offset(15)
            m.right.equalToSuperview().offset(-24)
        }
    }



    lazy var filtrateView = UIView().then {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(netHex: 0x3E4A59)
        label.text = R.string.localizable.defiHomePageAllProduct()

        $0.addSubview(label)
        label.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.top.bottom.equalToSuperview()
        }

        $0.addSubview(self.filtrateButton)
        self.filtrateButton.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.height.equalTo(28)
            m.right.equalToSuperview().offset(-24)
        }
    }

    lazy var listViewModel = DeFiListViewModel(tableView: self.tableView)

    private func setupView() {

        _ = listViewModel
        self.view.backgroundColor = .white
        navigationTitleView = NavigationTitleView(title: R.string.localizable.defiHomePageTitle())

        view.addSubview(buttonsView)
        view.addSubview(filtrateView)
        buttonsView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalToSuperview()
        }

        filtrateView.snp.makeConstraints { (m) in
            m.top.equalTo(buttonsView.snp.bottom)
            m.left.right.equalToSuperview()
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.top.equalTo(filtrateView.snp.bottom)
            m.left.right.bottom.equalToSuperview()
        }
    }

    private func bind() {

    }
}
