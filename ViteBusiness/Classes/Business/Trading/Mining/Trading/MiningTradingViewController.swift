//
//  MiningTradingViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/1.
//

import Foundation

class MiningTradingViewController: BaseTableViewController {

    var viewModle: MiningTradingListViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()

    }

    func setupView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = makeHeaderView()
    }

    let totalView = MiningColorfulView(leftText: R.string.localizable.miningTradingPageHeaderTotalEarnings(), leftClicked: {
        Alert.show(title: R.string.localizable.miningTradingPageHeaderTotalEarningsAlertTitle(), message: R.string.localizable.miningTradingPageHeaderTotalEarningsAlertMessage(), actions: [
        (.default(title: R.string.localizable.confirm()), nil)
        ])
    }, rightText: R.string.localizable.miningPageHeaderTotalRealTime()) {
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
                let vm = MiningTradingListViewModel(tableView: self.tableView, address: address)
                vm.totalViewModelBehaviorRelay.bind { [weak self] in
                    guard let `self` = self else { return }
                    self.totalView.valueLabel.text = $0 ?? "--.--"
                }.disposed(by: vm.rx.disposeBag)
                vm.miningTradingViewModelBehaviorRelay.bind { [weak self] in
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

extension MiningTradingViewController {

    class DetailView: UIView {

        static let height: CGFloat = 276

//        let titleLabel = UILabel().then {
//            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
//            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//            $0.text = R.string.localizable.miningTradingPageHeaderTitle()
//        }
//
//        let lineImg = UIImageView(image: R.image.dotted_line()?.tintColor(UIColor(netHex: 0x3E4A59, alpha: 0.3)).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

        let viteView = ItemView(type: .VITE)
        let btcView = ItemView(type: .BTC)
        let ethView = ItemView(type: .ETH)
        let usdtView = ItemView(type: .USDT)

        override init(frame: CGRect) {
            super.init(frame: frame)

//            layer.masksToBounds = true
//            layer.cornerRadius = 2
//            backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: CGRect(x: 0, y: 0, width: kScreenW - 24, height: type(of: self).height), colors: [
//                UIColor(netHex: 0xE3F0FF),
//                UIColor(netHex: 0xF2F8FF),
//            ])

//            addSubview(titleLabel)
//            addSubview(lineImg)
            addSubview(viteView)
            addSubview(btcView)
            addSubview(ethView)
            addSubview(usdtView)

//            titleLabel.snp.makeConstraints { (m) in
//                m.top.left.equalToSuperview().offset(12)
//            }
//
//            lineImg.snp.makeConstraints { (m) in
//                m.top.equalToSuperview().offset(40)
//                m.left.right.equalToSuperview().inset(12)
//            }

            snp.makeConstraints { (m) in
                m.height.equalTo(type(of: self).height)
            }

            viteView.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(0)
                m.left.right.equalToSuperview()
            }

            btcView.snp.makeConstraints { (m) in
                m.top.equalTo(viteView.snp.bottom).offset(12)
                m.left.right.equalToSuperview()
            }

            ethView.snp.makeConstraints { (m) in
                m.top.equalTo(btcView.snp.bottom).offset(12)
                m.left.right.equalToSuperview()
            }

            usdtView.snp.makeConstraints { (m) in
                m.top.equalTo(ethView.snp.bottom).offset(12)
                m.left.right.equalToSuperview()
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func bind(vm: MiningTradingViewModel?) {
            if let vm = vm {
                viteView.feeLabel.text = "\(vm.viteFee) VITE"
                viteView.earningsLabel.text = "\(vm.viteEarnings) VX"

                btcView.feeLabel.text = "\(vm.btcFee) VITE"
                btcView.earningsLabel.text = "\(vm.btcEarnings) VX"

                ethView.feeLabel.text = "\(vm.ethFee) VITE"
                ethView.earningsLabel.text = "\(vm.ethEarnings) VX"

                usdtView.feeLabel.text = "\(vm.usdtFee) VITE"
                usdtView.earningsLabel.text = "\(vm.usdtEarnings) VX"
            } else {
                viteView.feeLabel.text = "--.-- VITE"
                viteView.earningsLabel.text = "--.-- VX"

                btcView.feeLabel.text = "--.-- VITE"
                btcView.earningsLabel.text = "--.-- VX"

                ethView.feeLabel.text = "--.-- VITE"
                ethView.earningsLabel.text = "--.-- VX"

                usdtView.feeLabel.text = "--.-- VITE"
                usdtView.earningsLabel.text = "--.-- VX"
            }

        }

        class ItemView: UIView {

            enum ItemType: String {
                case VITE
                case BTC
                case ETH
                case USDT

                var image: UIImage? {
                    switch self {
                    case .VITE:
                        return R.image.icon_mining_trading_vite()
                    case .BTC:
                        return R.image.icon_mining_trading_btc()
                    case .ETH:
                        return R.image.icon_mining_trading_eth()
                    case .USDT:
                        return R.image.icon_mining_trading_usdt()
                    }
                }

                var symbol: String { self.rawValue }
            }

            let iconImageView = UIImageView()

            let feeTitleLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                $0.text = R.string.localizable.miningTradingPageHeaderFee()
            }

            let feeLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                $0.text = "--.--"
            }

            let earningsTitleLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                $0.text = R.string.localizable.miningTradingPageHeaderExpect()
            }

            let earningsLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 1)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                $0.text = "--.-- VX"
            }


            init(type: ItemType) {
                super.init(frame: .zero)

                iconImageView.image = type.image

                addSubview(iconImageView)
                addSubview(feeTitleLabel)
                addSubview(feeLabel)
                addSubview(earningsTitleLabel)
                addSubview(earningsLabel)
                
                backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: CGRect(x: 0, y: 0, width: kScreenW - 24, height: 60), colors: [
                    UIColor(netHex: 0xE3F0FF),
                    UIColor(netHex: 0xF2F8FF),
                ])

                iconImageView.snp.makeConstraints { (m) in
                    m.centerY.equalToSuperview()
                    m.left.equalToSuperview().offset(12)
                    m.size.equalTo(CGSize(width: 24, height: 24))
                }

                feeTitleLabel.snp.makeConstraints { (m) in
                    m.top.equalToSuperview().offset(12)
                    m.left.equalTo(iconImageView.snp.right).offset(12)
                }
                
                feeLabel.snp.makeConstraints { (m) in
                    m.centerY.equalTo(feeTitleLabel)
                    m.left.equalTo(feeTitleLabel.snp.right).offset(5)
                }

                earningsTitleLabel.snp.makeConstraints { (m) in
                    m.bottom.equalToSuperview().offset(-12)
                    m.left.equalTo(iconImageView.snp.right).offset(12)
                }

                earningsLabel.snp.makeConstraints { (m) in
                    m.centerY.equalTo(earningsTitleLabel)
                    m.left.equalTo(earningsTitleLabel.snp.right).offset(5)
                }

                self.snp.makeConstraints { (m) in
                    m.height.equalTo(60)
                }
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }

    class ListHeaderView: UIView {

        static let height: CGFloat = 38

        let titleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.text = R.string.localizable.miningPageListTitle()
        }

        override init(frame: CGRect) {
            super.init(frame: .zero)

            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(14)
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
