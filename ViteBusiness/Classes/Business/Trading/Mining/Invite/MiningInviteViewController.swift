//
//  MiningInviteViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/1.
//

import Foundation
import ViteWallet
import UIKit

class MiningInviteViewController: BaseTableViewController {

    var viewModle: MiningInviteListViewModel?
    var miningOrderInviteListViewModel: MiningOrderInviteListViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()

    }

    func setupView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = makeHeaderView()
    }

    let totalView = MiningColorfulView(leftText: R.string.localizable.miningInvitePageHeaderTotalEarnings(), leftClicked: nil, rightText: R.string.localizable.miningPageHeaderTotalRealTime()) {
        WebHandler.openViteXHomePage()
    }

    let detailView = DetailView()
    let listHeaderView = ListHeaderView()

    func makeHeaderView() -> UIStackView {
        let view = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }
        var height: CGFloat = 0
        height += MiningColorfulView.height
        height += DetailView.height
        height += ListHeaderView.height
        view.frame = CGRect(x: 0, y: 0, width: 0, height: height)

        view.addArrangedSubview(totalView.padding(horizontal: 12))
        view.addArrangedSubview(detailView.padding(horizontal: 12))
        view.addArrangedSubview(listHeaderView.padding(horizontal: 12))
        
        listHeaderView.titleLabel.text = R.string.localizable.miningInvitePageListTradingTitle()
        
        
        listHeaderView.moreButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            FloatButtonsView(targetView: self.listHeaderView.moreButton, delegate: self, titles:
                 [R.string.localizable.miningInvitePageListTradingTitle(),
                 R.string.localizable.miningInvitePageListMarketMakingTitle()]).show()
            }.disposed(by: rx.disposeBag)

        return view
    }

    func bind() {
        HDWalletManager.instance.accountDriver.drive(onNext: {[weak self] (account) in
            guard let `self` = self else { return }
            if let address = account?.address {
                let vm = MiningInviteListViewModel(tableView: self.tableView, address: address)
                vm.totalViewModelBehaviorRelay.bind { [weak self] in
                    guard let `self` = self else { return }
                    self.totalView.valueLabel.text = $0 ?? "--.--"
                }.disposed(by: vm.rx.disposeBag)
                vm.inviteDetailViewModelBehaviorRelay.bind { [weak self] in
                    guard let `self` = self else { return }
                    self.detailView.bind(vm: $0)
                    if let detail = $0, self.miningOrderInviteListViewModel == nil {
                        let vm = MiningOrderInviteListViewModel(tableView: self.tableView, address: address, detail: detail)
                        vm.totalViewModelBehaviorRelay.bind { [weak self] in
                            guard let `self` = self else { return }
                            self.totalView.valueLabel.text = $0 ?? "--.--"
                        }.disposed(by: vm.rx.disposeBag)
                        vm.inviteDetailViewModelBehaviorRelay.bind { [weak self] in
                            guard let `self` = self else { return }
                            self.detailView.bind(vm: $0)
                        }.disposed(by: vm.rx.disposeBag)
                        self.miningOrderInviteListViewModel = vm
                        self.viewModle?.rebindTableView()
                    }
                }.disposed(by: vm.rx.disposeBag)
                self.viewModle = vm
            } else {
                self.totalView.valueLabel.text = "--.--"
                self.detailView.bind(vm: nil)
                self.viewModle = nil
            }
        }).disposed(by: rx.disposeBag)
    }
}

extension MiningInviteViewController: FloatButtonsViewDelegate {
    func didClick(at index: Int, targetView: UIView) {
        if index == 0 {
            self.viewModle?.rebindTableView()
            self.tableView.reloadData()
            listHeaderView.titleLabel.text = R.string.localizable.miningInvitePageListTradingTitle()
        } else if index == 1 {
            self.miningOrderInviteListViewModel?.rebindTableView()
            self.tableView.reloadData()
            listHeaderView.titleLabel.text = R.string.localizable.miningInvitePageListMarketMakingTitle()
        }
    }
}

extension MiningInviteViewController.DetailView {
    class ItemView: UIView {
        
        static let height: CGFloat = 16+18+4
        
        let titleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        }

        let valueLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x24272B)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.text = "--.--"
        }
        
        init(title: String) {
            super.init(frame: .zero)
            
            addSubview(titleLabel)
            addSubview(valueLabel)
            
            titleLabel.text = title
            titleLabel.snp.makeConstraints { (m) in
                m.top.left.equalToSuperview()
                m.right.lessThanOrEqualToSuperview()
            }
            
            valueLabel.snp.makeConstraints { (m) in
                m.bottom.left.equalToSuperview()
                m.right.lessThanOrEqualToSuperview()
            }
            
            snp.makeConstraints { (m) in
                m.height.equalTo(type(of: self).height)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension MiningInviteViewController {

    class DetailView: UIView {

        static let height: CGFloat = 162

        let countItemView = ItemView(title: R.string.localizable.miningInvitePageDetailCountTitle())
        let tradingItemView = ItemView(title: R.string.localizable.miningInvitePageDetailTradingTitle())
        let marketMakingItemView = ItemView(title: R.string.localizable.miningInvitePageDetailMarketMakingTitle())

        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.masksToBounds = true
            layer.cornerRadius = 2
            backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: CGRect(x: 0, y: 0, width: kScreenW - 24, height: type(of: self).height), colors: [
                UIColor(netHex: 0xE3F0FF),
                UIColor(netHex: 0xF2F8FF),
            ])

            addSubview(countItemView)
            addSubview(tradingItemView)
            addSubview(marketMakingItemView)

            countItemView.snp.makeConstraints { (m) in
                m.top.left.right.equalToSuperview().inset(12)
            }

            tradingItemView.snp.makeConstraints { (m) in
                m.top.equalTo(countItemView.snp.bottom).offset(12)
                m.left.right.equalToSuperview().inset(12)
            }

            snp.makeConstraints { (m) in
                m.height.equalTo(type(of: self).height)
            }

            marketMakingItemView.snp.makeConstraints { (m) in
                m.top.equalTo(tradingItemView.snp.bottom).offset(12)
                m.left.right.equalToSuperview().inset(12)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func bind(vm: MiningInviteDetail?) {
            if let info = vm {
                countItemView.valueLabel.text = String(info.inviteCount)
                tradingItemView.valueLabel.text = info.trading.tryToTruncation6Digits()
                marketMakingItemView.valueLabel.text = info.marketMaking.tryToTruncation6Digits()
            } else {
                countItemView.valueLabel.text = "--.--"
                tradingItemView.valueLabel.text = "--.--"
                marketMakingItemView.valueLabel.text = "--.--"
            }
        }
    }

    class ListHeaderView: UIView {

        static let height: CGFloat = 40

        let titleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.text = R.string.localizable.miningPageListTitle()
        }
        
        let moreButton = UIButton().then {
            $0.setImage(R.image.icon_nav_more(), for: .normal)
            $0.setImage(R.image.icon_nav_more()?.highlighted, for: .highlighted)
            $0.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        }

        override init(frame: CGRect) {
            super.init(frame: .zero)

            addSubview(titleLabel)
            addSubview(moreButton)
            titleLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(16)
                m.left.equalToSuperview()
            }
            
            moreButton.snp.makeConstraints { (m) in
                m.centerY.equalTo(titleLabel)
                m.right.equalToSuperview()
            }

            snp.makeConstraints { (m) in
                m.height.equalTo(type(of: self).height)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
