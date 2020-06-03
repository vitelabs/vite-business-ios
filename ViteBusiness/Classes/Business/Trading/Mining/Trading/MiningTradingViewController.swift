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

    let totalView = MiningColorfulView(leftText: R.string.localizable.miningTradingPageHeaderTotalEarnings(), leftClicked: {
        Alert.show(title: R.string.localizable.miningTradingPageHeaderTotalEarningsAlertTitle(), message: R.string.localizable.miningTradingPageHeaderTotalEarningsAlertMessage(), actions: [
        (.default(title: R.string.localizable.confirm()), nil)
        ])
    }, rightText: R.string.localizable.miningTradingPageHeaderTotalRealTime()) {
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
        var height: CGFloat = 20
        height += MiningColorfulView.height
        height += 6
        height += DetailView.height
        height += ListHeaderView.height
        view.frame = CGRect(x: 0, y: 0, width: 0, height: height)

        view.addPlaceholder(height: 20)
        view.addArrangedSubview(totalView.padding(horizontal: 12))
        view.addPlaceholder(height: 6)
        view.addArrangedSubview(detailView.padding(horizontal: 12))
        view.addArrangedSubview(listHeaderView.padding(horizontal: 12))

        return view
    }

}

extension MiningTradingViewController {

    class DetailView: UIView {

        static let height: CGFloat = 256

        let titleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.text = R.string.localizable.miningTradingPageHeaderTitle()
        }

        let lineImg = UIImageView(image: R.image.dotted_line()?.tintColor(UIColor(netHex: 0x3E4A59, alpha: 0.3)).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

        let viteView = ItemView(type: .VITE)
        let btcView = ItemView(type: .BTC)
        let ethView = ItemView(type: .ETH)
        let usdtView = ItemView(type: .USDT)

        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.masksToBounds = true
            layer.cornerRadius = 2
            backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: CGRect(x: 0, y: 0, width: kScreenW - 24, height: type(of: self).height), colors: [
                UIColor(netHex: 0xE3F0FF),
                UIColor(netHex: 0xF2F8FF),
            ])

            addSubview(titleLabel)
            addSubview(lineImg)
            addSubview(viteView)
            addSubview(btcView)
            addSubview(ethView)
            addSubview(usdtView)

            titleLabel.snp.makeConstraints { (m) in
                m.top.left.equalToSuperview().offset(12)
            }

            lineImg.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(40)
                m.left.right.equalToSuperview().inset(12)
            }

            snp.makeConstraints { (m) in
                m.height.equalTo(type(of: self).height)
            }

            viteView.snp.makeConstraints { (m) in
                m.top.equalTo(lineImg.snp.bottom).offset(12)
                m.left.right.equalToSuperview().inset(12)
            }

            btcView.snp.makeConstraints { (m) in
                m.top.equalTo(viteView.snp.bottom).offset(16)
                m.left.right.equalToSuperview().inset(12)
            }

            ethView.snp.makeConstraints { (m) in
                m.top.equalTo(btcView.snp.bottom).offset(16)
                m.left.right.equalToSuperview().inset(12)
            }

            usdtView.snp.makeConstraints { (m) in
                m.top.equalTo(ethView.snp.bottom).offset(16)
                m.left.right.equalToSuperview().inset(12)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func bind(vm: MiningTradingViewModel?) {
            if let vm = vm {
                viteView.feeLabel.text = vm.viteFee
                viteView.earningsLabel.text = "\(R.string.localizable.miningTradingPageHeaderExpect()) \(vm.viteEarnings) VX"

                btcView.feeLabel.text = vm.btcFee
                btcView.earningsLabel.text = "\(R.string.localizable.miningTradingPageHeaderExpect()) \(vm.btcEarnings) VX"

                ethView.feeLabel.text = vm.ethFee
                ethView.earningsLabel.text = "\(R.string.localizable.miningTradingPageHeaderExpect()) \(vm.ethEarnings) VX"

                usdtView.feeLabel.text = vm.usdtFee
                usdtView.earningsLabel.text = "\(R.string.localizable.miningTradingPageHeaderExpect()) \(vm.usdtEarnings) VX"
            } else {
                viteView.feeLabel.text = "--.--"
                viteView.earningsLabel.text = "\(R.string.localizable.miningTradingPageHeaderExpect()) --.-- VX"

                btcView.feeLabel.text = "--.--"
                btcView.earningsLabel.text = "\(R.string.localizable.miningTradingPageHeaderExpect()) --.-- VX"

                ethView.feeLabel.text = "--.--"
                ethView.earningsLabel.text = "\(R.string.localizable.miningTradingPageHeaderExpect()) --.-- VX"

                usdtView.feeLabel.text = "--.--"
                usdtView.earningsLabel.text = "\(R.string.localizable.miningTradingPageHeaderExpect()) --.-- VX"
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
                $0.textColor = UIColor(netHex: 0x3E4A59)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                $0.text = "--.--"
            }

            let symbolLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            }

            let earningsLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                $0.text = "\(R.string.localizable.miningTradingPageHeaderExpect()) --.-- VX"
            }


            init(type: ItemType) {
                super.init(frame: .zero)

                iconImageView.image = type.image
                symbolLabel.text = type.symbol

                addSubview(iconImageView)
                addSubview(feeTitleLabel)
                addSubview(feeLabel)
                addSubview(symbolLabel)
                addSubview(earningsLabel)

                iconImageView.snp.makeConstraints { (m) in
                    m.top.left.equalToSuperview()
                    m.size.equalTo(CGSize(width: 16, height: 16))
                }

                feeTitleLabel.snp.makeConstraints { (m) in
                    m.centerY.equalTo(iconImageView)
                    m.left.equalTo(iconImageView.snp.right).offset(8)
                }

                symbolLabel.snp.makeConstraints { (m) in
                    m.centerY.equalTo(iconImageView)
                    m.right.equalToSuperview().offset(-12)
                }

                feeLabel.snp.makeConstraints { (m) in
                    m.centerY.equalTo(iconImageView)
                    m.right.equalTo(symbolLabel.snp.left).offset(-6)
                }

                earningsLabel.snp.makeConstraints { (m) in
                    m.bottom.equalToSuperview()
                    m.right.equalToSuperview().offset(-12)
                }

                self.snp.makeConstraints { (m) in
                    m.height.equalTo(36)
                }
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }

    class ListHeaderView: UIView {

        static let height: CGFloat = 40

        let titleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.text = R.string.localizable.miningTradingPageListTitle()
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

    class ItemCell: BaseTableViewCell {
        static let cellHeight: CGFloat = 70

        let feeLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        }

        let earningsLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x24272B)
        }

        let symbolLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        }

        let timeLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)


            selectionStyle = .none

            contentView.addSubview(feeLabel)
            contentView.addSubview(earningsLabel)
            contentView.addSubview(symbolLabel)
            contentView.addSubview(timeLabel)

            let hLine = UIView().then {
                $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
            }

            addSubview(hLine)

            feeLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(12)
                m.left.equalToSuperview().offset(12)
            }

            earningsLabel.snp.makeConstraints { (m) in
                m.centerY.equalTo(feeLabel)
            }

            symbolLabel.snp.makeConstraints { (m) in
                m.centerY.equalTo(feeLabel)
                m.left.equalTo(earningsLabel.snp.right).offset(6)
                m.right.equalToSuperview().offset(-12)
            }

            timeLabel.snp.makeConstraints { (m) in
                m.bottom.equalToSuperview().offset(-12)
                m.left.equalToSuperview().offset(12)
            }

            hLine.snp.makeConstraints { (m) in
                m.height.equalTo(CGFloat.singleLineWidth)
                m.bottom.equalToSuperview()
                m.left.right.equalToSuperview().inset(12)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func bind(_ item: MiningTradeDetail.Trade) {
            feeLabel.text = "\(R.string.localizable.miningTradingPageHeaderTitle()) \(item.feeAmount) \(item.miningToken)"
            earningsLabel.text = item.miningAmount
            symbolLabel.text = "VX"
            timeLabel.text = Date(timeIntervalSince1970: TimeInterval(item.date)).format()
        }
    }
}
