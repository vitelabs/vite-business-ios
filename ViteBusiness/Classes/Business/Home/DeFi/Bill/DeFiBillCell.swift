//
//  DeFiBillCell.swift
//  Action
//
//  Created by haoshenyang on 2019/12/5.
//

import UIKit

class DeFiBillCell: BaseTableViewCell, ListCellable {

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return dateFormatter
    }()

    func bind(_ item: DeFiBill) {
        titleLabel.text = item.billType.itemName
        contentLabel.text = item.billAmount.amount(decimals: TokenInfo.BuildIn.vite.value.decimals, count: 2)
        if (item.billAmount >= 0) {
            contentLabel.textColor = UIColor.init(netHex: 0x5BC500)
        } else {
            contentLabel.textColor = UIColor.init(netHex: 0xFF0008)
        }
        unitLabel.text = "VITE" 
        haahLabel.text = R.string.localizable.defiMyPageMyLoanCellIdTitle() + item.productHash
        timeLabel.text = DeFiBillCell.dateFormatter.string(from: Date.init(timeIntervalSince1970: item.billTime))
    }

    static var cellHeight: CGFloat = 70

    typealias Model = DeFiBill

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    let titleLabel = UILabel().then {
             $0.font = UIFont.boldSystemFont(ofSize: 14)
             $0.textColor = UIColor.init(netHex: 0x3E4A59)
         }

      let contentLabel = UILabel().then {
            $0.font = UIFont.boldSystemFont(ofSize: 16)
          $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
        }

      let unitLabel = UILabel().then {
             $0.font = UIFont.systemFont(ofSize: 14)
             $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
         }

    let haahLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
       }

    let timeLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 14)
           $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
       }

      override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
          self.selectionStyle = .none

          contentView.addSubview(titleLabel)
          contentView.addSubview(contentLabel)
          contentView.addSubview(unitLabel)
        contentView.addSubview(haahLabel)
        contentView.addSubview(timeLabel)

          titleLabel.snp.makeConstraints { (m) in
              m.top.equalToSuperview().offset(12)
              m.left.equalToSuperview().offset(24)
          }
          titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

          unitLabel.snp.makeConstraints { (m) in
              m.top.equalToSuperview().offset(12)
              m.right.equalToSuperview().offset(-24)
          }

          contentLabel.snp.makeConstraints { (m) in
              m.top.equalToSuperview().offset(12)
              m.right.equalTo(unitLabel.snp.left).offset(-6)
              m.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(10)
          }

        haahLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-10)
            m.left.equalToSuperview().offset(24)
            m.right.equalTo(contentView.snp.centerX).offset(-5)
        }
        haahLabel.setContentCompressionResistancePriority(.required, for: .horizontal)


        timeLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-10)
            m.right.equalToSuperview().offset(-24)
        }

        let seperator = UIView().then { (view) in
            view.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
        }
        contentView.addSubview(seperator)
        seperator.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.height.equalTo(0.5)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }

      }

      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }

}
