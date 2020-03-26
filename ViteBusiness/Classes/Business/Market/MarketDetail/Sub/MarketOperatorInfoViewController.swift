//
//  MarketOperatorInfoViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit

class MarketOperatorInfoViewController: BaseTableViewController {

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
    }


    var cells: [BaseTableViewCell] = []
    var info: MarketPairDetailInfo? = nil {
        didSet {
            guard oldValue?.tradeTokenDetail.tokenId != info?.tradeTokenDetail.tokenId else { return }
            guard let info = info?.operatorInfo else { return }
            var cells: [BaseTableViewCell] = []

            cells.append({
                let cell = IconCell()
                cell.setImageURL(URL(string: info.icon), name: info.name)
                return cell
                }())
            cells.append({
                let cell = MarketTokenInfoViewController.TitleCell()
                cell.setTitle(R.string.localizable.marketDetailPageTokenInfoAddress(), text: info.address)
            return cell
            }())

            cells.append({
                let cell = MarketTokenInfoViewController.BriefCell()
                cell.setText(info.overview.value)
            return cell
            }())

            
            self.cells = cells
        }
    }
    func bind(info: MarketPairDetailInfo?) {
        guard info?.operatorInfo.name != self.info?.operatorInfo.name else { return }
        self.info = info
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
}

extension MarketOperatorInfoViewController {

    class IconCell: BaseTableViewCell {

        let iconView = UIImageView()

        let nameLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x24272B)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            contentView.addSubview(iconView)
            contentView.addSubview(nameLabel)

            iconView.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(11)
                m.left.equalToSuperview().offset(24)
                m.size.equalTo(CGSize(width: 32, height: 32))
                m.bottom.equalToSuperview().offset(-12)
            }

            nameLabel.snp.makeConstraints { (m) in
                m.centerY.equalTo(iconView)
                m.left.equalTo(iconView.snp.right).offset(12)
            }
        }

        func setImageURL(_ url: URL?, name: String) {
            iconView.kf.cancelDownloadTask()
            iconView.kf.setImage(with: url, placeholder: UIImage.color(UIColor(netHex: 0xF8F8F8)))
            nameLabel.text = name
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class TestCell: BaseTableViewCell {
        let leftLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
            $0.text = R.string.localizable.marketDetailPageTradeTimeTitle()
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            contentView.addSubview(leftLabel)


            contentView.backgroundColor = .red
            leftLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(19)
                m.centerX.equalToSuperview()
                m.bottom.equalToSuperview().offset(-40)
            }

        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
