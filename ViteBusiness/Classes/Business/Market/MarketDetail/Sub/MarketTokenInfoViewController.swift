//
//  MarketTokenInfoViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit
import ViteWallet

class MarketTokenInfoViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(view).offset(38)
            m.left.right.bottom.equalToSuperview()
        }

        glt_scrollView = tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension

        tableView.backgroundColor = UIColor(netHex: 0x3E4A59, alpha: 0.02)
    }

    var cells: [BaseTableViewCell] = []
    var info: MarketPairDetailInfo? = nil {
        didSet {
            guard oldValue?.tradeTokenDetail.tokenId != info?.tradeTokenDetail.tokenId else { return }
            guard let info = info?.tradeTokenDetail else { return }
            var cells: [BaseTableViewCell] = []

            cells.append({
                let cell = IconCell()
                cell.iconView.setTokenIcon(info.urlIcon)
                cell.symbolLabel.text = info.symbol
                cell.nameLabel.text = "(\(info.name))"
                return cell
                }())

            cells.append({
                let cell = TitleCell()
                cell.setTitle(R.string.localizable.marketDetailPageTokenInfoTokenId(), text: info.tokenId)
                return cell
                }())
            cells.append({
                let cell = TitleCell()
                let amount = Amount(info.totalSupply) ?? Amount(0)
                cell.setTitle(R.string.localizable.marketDetailPageTokenInfoTotal(), text: amount.amountShortWithGroupSeparator(decimals: info.tokenDecimals))
                return cell
                }())
            cells.append({
                let cell = TitleCell()
                cell.setTitle(R.string.localizable.marketDetailPageTokenInfoType(),
                              text: info.gateway == nil ?
                                R.string.localizable.marketDetailPageTokenInfoTypeValueNative() :
                                R.string.localizable.marketDetailPageTokenInfoTypeValueOther())
                return cell
                }())

            cells.append({
                let cell = TitleCell()
                let gatewayName = info.gateway?.name ?? "--"
                let gatewayUrlString = info.gateway?.website
                let gatewayUrl = gatewayUrlString.map { URL(string: $0)! }
                cell.setTitle(R.string.localizable.marketDetailPageTokenInfoGateway(), text: gatewayName, url: gatewayUrl)
                return cell
                }())

            cells.append({
            let cell = TitleCell()
                let urlString = info.links.website.first
                let url = urlString.map { URL(string: $0)! }
            cell.setTitle(R.string.localizable.marketDetailPageTokenInfoOfficial(), text: urlString ?? "--", url: url)
            return cell
            }())

            cells.append({
            let cell = TitleCell()
                let urlString = info.links.whitepaper.first
                let url = urlString.map { URL(string: $0)! }
            cell.setTitle(R.string.localizable.marketDetailPageTokenInfoPaper(), text: urlString ?? "--", url: url)
            return cell
            }())

            if !info.links.explorer.isEmpty {
                cells.append(contentsOf: info.links.explorer.map {
                    let cell = TitleCell()
                    let urlString = $0
                    let url = URL(string: urlString)!
                    cell.setTitle(R.string.localizable.marketDetailPageTokenInfoBrowser(), text: urlString ?? "--", url: url)
                    return cell
                })
            }

            cells.append({
                let cell = TitleCell()
                let urlString = info.links.github.first
                let url = urlString.map { URL(string: $0)! }
                cell.setTitle(R.string.localizable.marketDetailPageTokenInfoGithub(), text: urlString ?? "--", url: url)
                return cell
                }())

            cells.append({
                let cell = SocialCell()
                var values: [(image: UIImage?, url: URL)] = []
                if let urlString = info.links.twitter.first, let url = URL(string: urlString) {
                    let image = R.image.icon_market_detail_twitter()
                    values.append((image: image, url: url))
                }

                if let urlString = info.links.facebook.first, let url = URL(string: urlString) {
                    let image = R.image.icon_market_detail_facebook()
                    values.append((image: image, url: url))
                }

                if let urlString = info.links.telegram.first, let url = URL(string: urlString) {
                    let image = R.image.icon_market_detail_telegram()
                    values.append((image: image, url: url))
                }

                if let urlString = info.links.reddit.first, let url = URL(string: urlString) {
                    let image = R.image.icon_market_detail_reddit()
                    values.append((image: image, url: url))
                }

                if let urlString = info.links.discord.first, let url = URL(string: urlString) {
                    let image = R.image.icon_market_detail_discord()
                    values.append((image: image, url: url))
                }
                cell.set(values)
                return cell
                }())

            cells.append({
                let cell = BriefCell()
                cell.setText(info.overview.value)
                return cell
                }())

            cells.forEach { (cell) in
                cell.contentView.backgroundColor = UIColor(netHex: 0x3E4A59, alpha: 0.02)
            }
            self.cells = cells
        }
    }
    func bind(info: MarketPairDetailInfo?) {
        guard info?.tradeTokenDetail.tokenId != self.info?.tradeTokenDetail.tokenId else { return }
        self.info = info
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info == nil ? 0 : cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
}

extension MarketTokenInfoViewController {

    class IconCell: BaseTableViewCell {

        let iconView = TokenIconView()

        let symbolLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x24272B)
        }

        let nameLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            contentView.addSubview(iconView)
            contentView.addSubview(symbolLabel)
            contentView.addSubview(nameLabel)

            iconView.set(cornerRadius: 16)
            iconView.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(11)
                m.left.equalToSuperview().offset(24)
                m.size.equalTo(CGSize(width: 32, height: 32))
                m.bottom.equalToSuperview().offset(-12)
            }

            symbolLabel.snp.makeConstraints { (m) in
                m.centerY.equalTo(iconView)
                m.left.equalTo(iconView.snp.right).offset(12)
            }

            nameLabel.snp.makeConstraints { (m) in
                m.centerY.equalTo(iconView)
                m.left.equalTo(symbolLabel.snp.right).offset(12)
            }


            let hLine = UIView().then { $0.backgroundColor = Colors.lineGray}
            contentView.addSubview(hLine)
            hLine.snp.makeConstraints { (m) in
                m.height.equalTo(CGFloat.singleLineWidth)
                m.left.equalTo(contentView).offset(24)
                m.right.equalTo(contentView).offset(-24)
                m.bottom.equalTo(contentView)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class TitleCell: BaseTableViewCell {

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        }

        let valueLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.numberOfLines = 0
        }

        let button = UIButton().then {
            $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        }

        var url: URL?

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            contentView.addSubview(titleLabel)
            contentView.addSubview(valueLabel)
            contentView.addSubview(button)


            titleLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(12)
                m.left.right.equalToSuperview().inset(24)
            }

            valueLabel.snp.makeConstraints { (m) in
                m.top.equalTo(titleLabel.snp.bottom).offset(10)
                m.left.right.equalToSuperview().inset(24)
                m.bottom.lessThanOrEqualToSuperview().offset(-12)
            }

            button.snp.makeConstraints { (m) in
                m.top.equalTo(titleLabel.snp.bottom).offset(10)
                m.left.equalToSuperview().inset(24)
                m.bottom.lessThanOrEqualToSuperview().offset(-12)
            }

            button.isHidden = true

            let hLine = UIView().then { $0.backgroundColor = Colors.lineGray}
            contentView.addSubview(hLine)
            hLine.snp.makeConstraints { (m) in
                m.height.equalTo(CGFloat.singleLineWidth)
                m.left.equalTo(contentView).offset(24)
                m.right.equalTo(contentView).offset(-24)
                m.bottom.equalTo(contentView)
            }

            button.rx.tap.bind { [weak self] in
                guard let url = self?.url else { return }
                WebHandler.open(url)
            }.disposed(by: disposeBag)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setTitle(_ title: String, text: String) {
            titleLabel.text = title
            valueLabel.text = text

            url = nil
            valueLabel.isHidden = false
            button.isHidden = true
        }

        func setTitle(_ title: String, text: String, url: URL?) {
            titleLabel.text = title

            self.url = url
            if let url = url {
                button.setTitle(text, for: .normal)
                valueLabel.isHidden = true
                button.isHidden = false
            } else {
                valueLabel.text = text
                valueLabel.isHidden = false
                button.isHidden = true
            }
        }

    }

    class SocialCell: BaseTableViewCell {
        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.text = R.string.localizable.marketDetailPageTokenInfoSocial()
        }

        let stackView = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.spacing = 20
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            contentView.addSubview(titleLabel)
            contentView.addSubview(stackView)


            titleLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(10)
                m.left.right.equalToSuperview().inset(24)
            }

            stackView.snp.makeConstraints { (m) in
                m.top.equalTo(titleLabel.snp.bottom).offset(12)
                m.left.right.equalToSuperview().inset(24)
                m.height.equalTo(32)
                m.bottom.equalToSuperview()
            }
        }

        func set(_ values: [(image: UIImage?, url: URL)]) {
            stackView.arrangedSubviews.forEach {
                stackView.removeArrangedSubview($0)
            }

            values.forEach { value in
                let button = UIButton()
                button.setImage(value.image, for: .normal)
                button.setImage(value.image?.highlighted, for: .highlighted)
                button.snp.makeConstraints { m in m.size.equalTo(CGSize(width: 32, height: 32)) }
                button.rx.tap.bind { WebHandler.open(value.url) }.disposed(by: disposeBag)
                stackView.addArrangedSubview(button)
            }

            let view = UIView()
            view.backgroundColor = .clear
            view.snp.makeConstraints { m in m.size.equalTo(CGSize(width: 32, height: 800)).priority(.low) }
            stackView.addArrangedSubview(view)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class BriefCell: BaseTableViewCell {
        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.text = R.string.localizable.marketDetailPageTokenInfoBrief()
        }

        let valueLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.numberOfLines = 0
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            contentView.addSubview(titleLabel)
            contentView.addSubview(valueLabel)


            titleLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(12)
                m.left.right.equalToSuperview().inset(24)
            }

            valueLabel.snp.makeConstraints { (m) in
                m.top.equalTo(titleLabel.snp.bottom).offset(12)
                m.left.right.equalToSuperview().inset(24)
                m.bottom.equalToSuperview().inset(12)
            }
        }

        func setText(_ text: String) {
            self.valueLabel.text = text
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

