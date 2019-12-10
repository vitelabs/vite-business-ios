//
//  DeFiUsageCell.swift
//  Action
//
//  Created by haoshenyang on 2019/12/9.
//

import UIKit

let decimals = TokenInfo.BuildIn.vite.value.decimals
let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return dateFormatter
}()

class DefiUsageForSBPCell: UITableViewCell,ListCellable {

    func bind(_ item: DefiUsageInfo) {
        bgColoredLable.text = (item.amountInfo.sbpName ?? "") + ": " + (item.amountInfo.blockProducingAddress  ?? "")
        amountLabel.text = item.usageInfo.bsseAmount.amountShort(decimals: decimals)
        timeLabel.text = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(item.usageTime)))
        borrowedFundLabel.text = "已使用借币余额：" + item.usageInfo.loanAmount.amountShort(decimals: decimals)
        baseFundLabel.text = "已使用基础余额：" + item.usageInfo.bsseAmount.amountShort(decimals: decimals)
        chainHeightLabel.text = "到期快照高度：" + String(item.amountInfo.pledgeDueHeight)

        self.editButton.rx.tap.bind { _ in

        }.disposed(by: rx.disposeBag)

        self.cancleButton.rx.tap.bind { _ in

        }.disposed(by: rx.disposeBag)
    }

     static var cellHeight: CGFloat = 224

     typealias Model = DefiUsageInfo

    let icon = UIImageView().then {
        $0.image = R.image.defi_use_sbp()
    }
    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x77808A)
        $0.text = "注册SBP"
    }
    let bgColoredLable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "  "
    }

    let seperator = UIImageView(image: R.image.icon_my_loan_cell_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

    let amountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let untilLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        $0.text = "VITE"
    }
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let amountTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "抵押余额"
    }
    let timeTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "预计到期时间"
    }
    let borrowedFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "已使用借币余额：--"
    }
    let baseFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "已使用基础余额：--"
    }
    let chainHeightLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "到期快照高度：--"
    }

    let editButton = UIButton.init(style: .white).then {
        $0.setTitle("编辑", for: .normal)
        $0.layer.cornerRadius = 13
        $0.layer.masksToBounds = true
    }

    let cancleButton = UIButton.init(style: .blue).then {
        $0.setTitle("撤销SBP", for: .normal)
        $0.layer.cornerRadius = 13
        $0.layer.masksToBounds = true
    }

    let getAwardLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        $0.text = "请到网页端提取SBP奖励"
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bgColoredLable)
        contentView.addSubview(seperator)
        contentView.addSubview(amountLabel)
        contentView.addSubview(untilLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(borrowedFundLabel)
        contentView.addSubview(baseFundLabel)
        contentView.addSubview(chainHeightLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(cancleButton)
        contentView.addSubview(getAwardLabel)

        icon.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalToSuperview().offset(22)
            m.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(icon.snp.trailing).offset(3)
            m.centerY.equalTo(icon)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        bgColoredLable.snp.makeConstraints { (m) in
            m.trailing.equalToSuperview().offset(-23)
            m.centerY.equalTo(icon)
            m.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
        }

        seperator.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(23)
            m.top.equalTo(icon.snp.bottom).offset(10)
            m.height.equalTo(1)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        untilLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(amountLabel.snp.trailing).offset(2)
            m.centerY.equalTo(amountLabel)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(contentView.snp.centerX)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        amountTitleLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        timeTitleLabel.snp.makeConstraints { (m) in
             m.leading.equalTo(timeLabel)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        borrowedFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountTitleLabel.snp.bottom).offset(10)
        }

        baseFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(borrowedFundLabel.snp.bottom).offset(6)
        }

        chainHeightLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
             m.top.equalTo(baseFundLabel.snp.bottom).offset(6)
        }

        editButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(chainHeightLabel)
            m.trailing.equalTo(contentView).offset(-106)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

        cancleButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(chainHeightLabel)
            m.trailing.equalTo(contentView).offset(-24)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

        getAwardLabel.snp.makeConstraints { (m) in
            m.top.equalTo(cancleButton.snp.bottom).offset(15)
            m.leading.equalToSuperview().offset(23)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DefiUsageForSVIPCell: UITableViewCell ,ListCellable {

    func bind(_ item: DefiUsageInfo) {
        bgColoredLable.text = "开通交易所SVIP：" + ": " + (item.amountInfo.blockProducingAddress  ?? "")
        amountLabel.text = item.usageInfo.bsseAmount.amountShort(decimals: decimals)
        timeLabel.text = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(item.usageTime)))
        borrowedFundLabel.text = "已使用借币余额：" + item.usageInfo.loanAmount.amountShort(decimals: decimals)
        baseFundLabel.text = "已使用基础余额：" + item.usageInfo.bsseAmount.amountShort(decimals: decimals)

        self.cancleButton.rx.tap.bind { _ in

        }.disposed(by: rx.disposeBag)
    }

     static var cellHeight: CGFloat = 224

     typealias Model = DefiUsageInfo

    let icon = UIImageView().then {
        $0.image = R.image.defi_use_svip()
    }
    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x77808A)
        $0.text = "开通交易所SVIP"
    }
    let bgColoredLable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "  "
    }

    let seperator = UIImageView(image: R.image.icon_my_loan_cell_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

    let amountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let untilLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        $0.text = "VITE"
    }
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let amountTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "抵押余额"
    }
    let timeTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "预计到期时间"
    }
    let borrowedFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "已使用借币余额：--"
    }
    let baseFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "已使用基础余额：--"
    }

    let cancleButton = UIButton.init(style: .blue).then {
        $0.setTitle("撤销交易所SVIP", for: .normal)
        $0.layer.cornerRadius = 13
        $0.layer.masksToBounds = true
    }



    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bgColoredLable)
        contentView.addSubview(seperator)
        contentView.addSubview(amountLabel)
        contentView.addSubview(untilLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(borrowedFundLabel)
        contentView.addSubview(baseFundLabel)
        contentView.addSubview(cancleButton)

        icon.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalToSuperview().offset(22)
            m.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(icon.snp.trailing).offset(3)
            m.centerY.equalTo(icon)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        bgColoredLable.snp.makeConstraints { (m) in
            m.trailing.equalToSuperview().offset(-23)
            m.centerY.equalTo(icon)
            m.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
        }

        seperator.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(23)
            m.top.equalTo(icon.snp.bottom).offset(10)
            m.height.equalTo(1)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        untilLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(amountLabel.snp.trailing).offset(2)
            m.centerY.equalTo(amountLabel)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(contentView.snp.centerX)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        amountTitleLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        timeTitleLabel.snp.makeConstraints { (m) in
             m.leading.equalTo(timeLabel)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        borrowedFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountTitleLabel.snp.bottom).offset(10)
        }

        baseFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(borrowedFundLabel.snp.bottom).offset(6)
        }

        cancleButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(baseFundLabel)
            m.trailing.equalTo(contentView).offset(-24)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class DefiUsageForQuotalCell: UITableViewCell ,ListCellable {

    func bind(_ item: DefiUsageInfo) {
        bgColoredLable.text = "收益地址" + ": " + (item.amountInfo.rewardWithdrawAddress  ?? "")
        amountLabel.text = item.usageInfo.bsseAmount.amountShort(decimals: decimals)
        timeLabel.text = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(item.usageTime)))
        borrowedFundLabel.text = "已使用借币余额：" + item.usageInfo.loanAmount.amountShort(decimals: decimals)
        baseFundLabel.text = "已使用基础余额：" + item.usageInfo.bsseAmount.amountShort(decimals: decimals)
        self.cancleButton.rx.tap.bind { _ in

        }.disposed(by: rx.disposeBag)

    }

     static var cellHeight: CGFloat = 224

     typealias Model = DefiUsageInfo

    let icon = UIImageView().then {
        $0.image = R.image.defi_use_quoto()
    }
    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x77808A)
        $0.text = "获取配额"
    }
    let bgColoredLable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "  "
    }

    let seperator = UIImageView(image: R.image.icon_my_loan_cell_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

    let amountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let untilLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        $0.text = "VITE"
    }
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let amountTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "抵押余额"
    }
    let timeTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "预计到期时间"
    }
    let borrowedFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "已使用借币余额：--"
    }
    let baseFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "已使用基础余额：--"
    }


    let cancleButton = UIButton.init(style: .blue).then {
        $0.setTitle("取回抵押", for: .normal)
        $0.layer.cornerRadius = 13
        $0.layer.masksToBounds = true
    }



    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bgColoredLable)
        contentView.addSubview(seperator)
        contentView.addSubview(amountLabel)
        contentView.addSubview(untilLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(borrowedFundLabel)
        contentView.addSubview(baseFundLabel)
        contentView.addSubview(cancleButton)

        icon.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalToSuperview().offset(22)
            m.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(icon.snp.trailing).offset(3)
            m.centerY.equalTo(icon)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        bgColoredLable.snp.makeConstraints { (m) in
            m.trailing.equalToSuperview().offset(-23)
            m.centerY.equalTo(icon)
            m.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
        }

        seperator.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(23)
            m.top.equalTo(icon.snp.bottom).offset(10)
            m.height.equalTo(1)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        untilLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(amountLabel.snp.trailing).offset(2)
            m.centerY.equalTo(amountLabel)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(contentView.snp.centerX)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        amountTitleLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        timeTitleLabel.snp.makeConstraints { (m) in
             m.leading.equalTo(timeLabel)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        borrowedFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountTitleLabel.snp.bottom).offset(10)
        }

        baseFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(borrowedFundLabel.snp.bottom).offset(6)
        }


        cancleButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(baseFundLabel)
            m.trailing.equalTo(contentView).offset(-24)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class DefiUsageForMinningCell: UITableViewCell ,ListCellable {

    func bind(_ item: DefiUsageInfo) {
        bgColoredLable.text = (item.amountInfo.sbpName ?? "") + ": " + (item.amountInfo.blockProducingAddress  ?? "")
        amountLabel.text = item.usageInfo.bsseAmount.amountShort(decimals: decimals)
        timeLabel.text = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(item.usageTime)))
        borrowedFundLabel.text = "已使用借币余额：" + item.usageInfo.loanAmount.amountShort(decimals: decimals)
        baseFundLabel.text = "已使用基础余额：" + item.usageInfo.bsseAmount.amountShort(decimals: decimals)
    }

     static var cellHeight: CGFloat = 224

     typealias Model = DefiUsageInfo

    let icon = UIImageView().then {
        $0.image = R.image.defi_use_minning()
    }
    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x77808A)
        $0.text = "抵押挖矿"
    }
    let bgColoredLable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "  "
    }

    let seperator = UIImageView(image: R.image.icon_my_loan_cell_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

    let amountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let untilLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        $0.text = "VITE"
    }
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let amountTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "抵押余额"
    }
    let timeTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "预计到期时间"
    }
    let borrowedFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "已使用借币余额：--"
    }
    let baseFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "已使用基础余额：--"
    }

    let editButton = UIButton.init(style: .white).then {
        $0.setTitle("查看收益", for: .normal)
        $0.layer.cornerRadius = 13
        $0.layer.masksToBounds = true
    }

    let cancleButton = UIButton.init(style: .blue).then {
        $0.setTitle("停止挖矿", for: .normal)
        $0.layer.cornerRadius = 13
        $0.layer.masksToBounds = true
    }



    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bgColoredLable)
        contentView.addSubview(seperator)
        contentView.addSubview(amountLabel)
        contentView.addSubview(untilLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(borrowedFundLabel)
        contentView.addSubview(baseFundLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(cancleButton)

        icon.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalToSuperview().offset(22)
            m.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(icon.snp.trailing).offset(3)
            m.centerY.equalTo(icon)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        bgColoredLable.snp.makeConstraints { (m) in
            m.trailing.equalToSuperview().offset(-23)
            m.centerY.equalTo(icon)
            m.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
        }

        seperator.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(23)
            m.top.equalTo(icon.snp.bottom).offset(10)
            m.height.equalTo(1)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        untilLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(amountLabel.snp.trailing).offset(2)
            m.centerY.equalTo(amountLabel)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(contentView.snp.centerX)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        amountTitleLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        timeTitleLabel.snp.makeConstraints { (m) in
             m.leading.equalTo(timeLabel)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        borrowedFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountTitleLabel.snp.bottom).offset(10)
        }

        baseFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(borrowedFundLabel.snp.bottom).offset(6)
        }


        editButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(baseFundLabel)
            m.trailing.equalTo(contentView).offset(-106)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

        cancleButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(baseFundLabel)
            m.trailing.equalTo(contentView).offset(-24)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
