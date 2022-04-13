//
//  MiningStakingViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/1.
//

import Foundation
import ViteWallet

class MiningStakingViewController: BaseTableViewController {

    var viewModle: MiningStakingListViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()

    }

    func setupView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = makeHeaderView()
    }

    let totalView = MiningColorfulView(leftText: R.string.localizable.miningStakingPageHeaderTotalEarnings(), leftClicked: nil, rightText: R.string.localizable.miningPageHeaderTotalRealTime()) {
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

        return view
    }

    func bind() {
        HDWalletManager.instance.accountDriver.drive(onNext: {[weak self] (account) in
            guard let `self` = self else { return }
            if let address = account?.address {
                let vm = MiningStakingListViewModel(tableView: self.tableView, address: address)
                vm.totalViewModelBehaviorRelay.bind { [weak self] in
                    guard let `self` = self else { return }
                    self.totalView.valueLabel.text = $0 ?? "--.--"
                }.disposed(by: vm.rx.disposeBag)
                vm.miningStakeInfoViewModelBehaviorRelay.bind { [weak self] in
                    guard let `self` = self else { return }
                    self.detailView.bind(vm: $0)
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

extension MiningStakingViewController.DetailView {
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

extension MiningStakingViewController {

    class DetailView: UIView {

        static let height: CGFloat = 150

        let amountItemView = ItemView(title: R.string.localizable.miningStakingPageDetailAmountTitle())
        let unlockingItemView = ItemView(title: R.string.localizable.miningStakingPageDetailUnlockingTitle())

        let addButton = UIButton().then {
            $0.setBackgroundImage(R.image.icon_mining_staking_add_bg()?.resizable, for: .normal)
            $0.setBackgroundImage(R.image.icon_mining_staking_add_bg()?.highlighted.resizable, for: .highlighted)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.setTitle(R.string.localizable.miningStakingPageDetailAddButtonTitle(), for: .normal)
        }

        let listButton = UIButton().then {
            $0.setBackgroundImage(R.image.icon_mining_staking_list_bg()?.resizable, for: .normal)
            $0.setBackgroundImage(R.image.icon_mining_staking_list_bg()?.highlighted.resizable, for: .highlighted)
            $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.setTitle(R.string.localizable.miningStakingPageDetailListButtonTitle(), for: .normal)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.masksToBounds = true
            layer.cornerRadius = 2
            backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: CGRect(x: 0, y: 0, width: kScreenW - 24, height: type(of: self).height), colors: [
                UIColor(netHex: 0xE3F0FF),
                UIColor(netHex: 0xF2F8FF),
            ])

            addSubview(amountItemView)
            addSubview(unlockingItemView)
            addSubview(addButton)
            addSubview(listButton)

            amountItemView.snp.makeConstraints { (m) in
                m.top.left.right.equalToSuperview().inset(12)
            }

            unlockingItemView.snp.makeConstraints { (m) in
                m.top.equalTo(amountItemView.snp.bottom).offset(12)
                m.left.right.equalToSuperview().inset(12)
            }

            snp.makeConstraints { (m) in
                m.height.equalTo(type(of: self).height)
            }

            addButton.snp.makeConstraints { (m) in
                m.left.equalToSuperview().offset(12)
                m.bottom.equalToSuperview().offset(-12)
                m.height.equalTo(26)
            }

            listButton.snp.makeConstraints { (m) in
                m.left.equalTo(addButton.snp.right).offset(13)
                m.width.equalTo(addButton)
                m.bottom.equalToSuperview().offset(-12)
                m.size.equalTo(addButton)
                m.right.equalToSuperview().offset(-12)
            }

            addButton.rx.tap.bind {
                MiningStakingConfirmView().show()
            }.disposed(by: rx.disposeBag)
            
            listButton.rx.tap.bind {
                let vc = MiningStakingWithdrawalListViewController()
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)
            
            
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func bind(vm: (DexMiningStakeInfo, DexMiningStakeInfo)?) {
            if let info = vm {
                amountItemView.valueLabel.text = info.0.totalStakeAmount.amount(decimals: 18, count: 6, groupSeparator: true)
                unlockingItemView.valueLabel.text = info.1.totalStakeAmount.amount(decimals: 18, count: 6, groupSeparator: true)
            } else {
                amountItemView.valueLabel.text = "--.--"
                unlockingItemView.valueLabel.text = "--.--"
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

        override init(frame: CGRect) {
            super.init(frame: .zero)

            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(16)
                m.left.right.equalToSuperview()
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
