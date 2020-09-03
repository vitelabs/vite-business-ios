//
//  DexTokenMarrketSelector.swift
//  ViteBusiness
//
//  Created by Stone on 2020/9/1.
//

import Foundation

class DexTokenMarrketSelector: VisualEffectAnimationView {

    fileprivate let containerView: UIView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }

    let headerView = HeaderView()
    let tableView = UITableView()

    let symbol: String

    var infos: [MarketInfo] = []

    init(superview: UIView, symbol: String) {
        self.symbol = symbol
        super.init(superview: superview)

        isEnableTapDismiss = false

        contentView.addSubview(containerView)
        containerView.addSubview(headerView)
        containerView.addSubview(tableView)

        containerView.snp.makeConstraints { (m) in
            m.center.equalTo(contentView)
            m.width.equalTo(270)
        }

        headerView.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
            m.height.equalTo(50)
        }

        tableView.snp.makeConstraints { (m) in
            m.top.equalTo(headerView.snp.bottom)
            m.bottom.left.right.equalToSuperview()
            m.height.equalTo(ItemCell.height * 5)
        }

        headerView.cancelButton.rx.tap.bind { [weak self] in
            self?.hide()
        }.disposed(by: rx.disposeBag)

        tableView.delegate = self
        tableView.dataSource = self

        MarketInfoService.shared.sortedMarketDataBehaviorRelay.asDriver().drive(onNext: { [weak self] (datas) in
            guard let `self` = self else { return }
            self.infos.removeAll()
            // skip favourite
            for data in datas[1...] {
                for info in data.infos {
                    if info.statistic.tradeTokenSymbol == self.symbol || info.statistic.quoteTokenSymbol == self.symbol {
                        self.infos.append(info)
                    }
                }
            }

            self.infos = self.infos.sorted { "\($0.statistic.tradeTokenSymbol)/\($0.statistic.quoteTokenSymbol)" < "\($1.statistic.tradeTokenSymbol)/\($1.statistic.quoteTokenSymbol)" }

            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DexTokenMarrketSelector: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ItemCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(info: infos[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ItemCell.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let info = infos[indexPath.row]
        self.hide()
        NotificationCenter.default.post(name: .goTradingPage, object: self, userInfo: ["marketInfo": info, "isBuy" : true])
    }
}

extension DexTokenMarrketSelector {
    class HeaderView: UIView {

        fileprivate let titleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x242728)
            $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            $0.text = R.string.localizable.dexTokenMarketSelectorTitle()
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }

        fileprivate let cancelButton = UIButton().then {
            $0.setImage(R.image.icon_quota_close(), for: .normal)
            $0.setImage(R.image.icon_quota_close()?.highlighted, for: .highlighted)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(titleLabel)
            addSubview(cancelButton)

            titleLabel.snp.makeConstraints { (m) in
                m.center.equalToSuperview()
            }

            cancelButton.snp.makeConstraints { (m) in
                m.right.equalToSuperview().offset(-16)
                m.centerY.equalToSuperview()
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class ItemCell: BaseTableViewCell {
        static let height: CGFloat = 60

        let tradeSymbolLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x24272B)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        }

        let quoteSymbolLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        }
        let priceLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        }

        let rateLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        }

        let persentLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)


            contentView.addSubview(tradeSymbolLabel)
            contentView.addSubview(quoteSymbolLabel)
            contentView.addSubview(priceLabel)
            contentView.addSubview(rateLabel)
            contentView.addSubview(persentLabel)


            tradeSymbolLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(10)
                m.left.equalToSuperview().offset(16)
            }

            quoteSymbolLabel.snp.makeConstraints { (m) in
                m.centerY.equalTo(tradeSymbolLabel)
                m.left.equalTo(tradeSymbolLabel.snp.right).offset(2)
            }

            priceLabel.snp.makeConstraints { (m) in
                m.left.equalToSuperview().offset(16)
                m.bottom.equalToSuperview().offset(-10)
            }

            rateLabel.snp.makeConstraints { (m) in
                m.centerY.equalTo(priceLabel)
                m.left.equalTo(priceLabel.snp.right).offset(6)
            }

            persentLabel.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.right.equalToSuperview().offset(-16)
            }

            let line = UIView().then {
                $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
                contentView.addSubview($0)
            }
            line.snp.makeConstraints { (m) in
                m.height.equalTo(CGFloat.singleLineWidth)
                m.left.right.bottom.equalToSuperview()
            }
        }

        func bind(info: MarketInfo)  {
            tradeSymbolLabel.text = info.statistic.tradeTokenSymbol.components(separatedBy: "-").first
            let quoteTokenSymbol = (info.statistic.quoteTokenSymbol.components(separatedBy: "-").first ?? "")
            quoteSymbolLabel.text = "/" + quoteTokenSymbol
            priceLabel.text = info.statistic.closePrice
            rateLabel.text = info.rate
            persentLabel.text = info.persentString
            persentLabel.textColor = info.persentColor
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
