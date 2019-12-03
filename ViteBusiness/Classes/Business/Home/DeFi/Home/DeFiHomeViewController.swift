//
//  DeFiHomeViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/28.
//

import Foundation
import ActionSheetPicker_3_0
import RxSwift
import RxCocoa

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
    }

    let tableView = UITableView(frame: .zero, style: .plain)

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

    var sortTypeBehaviorRelay: BehaviorRelay<DeFiAPI.ProductSortType> = BehaviorRelay(value: .PUB_TIME_DESC)
    lazy var listViewModel = DeFiListViewModel(tableView: self.tableView, sortType: self.sortTypeBehaviorRelay.value)

    private func setupView() {
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
            m.left.right.equalToSuperview()
            m.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
    }

    private func bind() {

        filtrateButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let types = DeFiAPI.ProductSortType.allCases
            var index = 0
            for (i, type) in types.enumerated() where self.listViewModel.sortType == type {
                index = i
            }
            _ =  ActionSheetStringPicker.show(withTitle: R.string.localizable.defiHomePageSortTitle(), rows: types.map({ $0.name }), initialSelection: index, doneBlock: {[weak self] _, index, _ in
                self?.sortTypeBehaviorRelay.accept(types[index])
            }, cancel: { _ in return }, origin: self.view)
        }.disposed(by: rx.disposeBag)

        sortTypeBehaviorRelay.distinctUntilChanged().bind {[weak self] (sortType) in
            guard let `self` = self else { return }
            self.filtrateButton.setTitle(sortType.name, for: .normal)
            self.listViewModel = DeFiListViewModel(tableView: self.tableView, sortType: sortType)
        }.disposed(by: rx.disposeBag)

        myDefiButton.rx.tap.bind { [weak self] in
            let vc = MyDeFiViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

    }
}

extension DeFiAPI.ProductSortType {
    var name: String {
        switch self {
        case .PUB_TIME_DESC:
            return R.string.localizable.defiHomePageSortPublishTime()
        case .SUB_TIME_REMAINING_ASC:
            return R.string.localizable.defiHomePageSortRemainTime()
        case .YEAR_RATE_DESC:
            return R.string.localizable.defiHomePageSortEarnings()
        case .LOAN_DURATION_ASC:
            return R.string.localizable.defiHomePageSortBorrowTime()
        case .LOAN_COMPLETENESS_DESC:
            return R.string.localizable.defiHomePageSortProgress()
        }
    }
}
