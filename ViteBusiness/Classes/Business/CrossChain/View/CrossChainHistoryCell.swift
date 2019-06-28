//
//  GatewayWithdrawViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/6/11.
//

import UIKit
import BigInt
import ViteWallet

class CrossChainHistoryCell: UITableViewCell {

    let iconImageView = UIImageView()
    let statusLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x77808A)
    }
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)
    }
    let amountLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha:  0.8)
    }
    let symbleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)
    }
    let leftHashLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 11)
        $0.textColor = UIColor.init(netHex: 0x3E4A59)
        $0.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
    }
    let rightHashLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 11)
        $0.textColor = UIColor.init(netHex: 0x3E4A59)
        $0.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none

        contentView.addSubview(iconImageView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(symbleLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(leftHashLabel)
        contentView.addSubview(rightHashLabel)

        iconImageView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.top.equalToSuperview().offset(18)
            m.width.height.equalTo(14)
        }

        statusLabel.snp.makeConstraints { (m) in
            m.left.equalTo(iconImageView.snp.right).offset(3)
            m.centerY.equalTo(iconImageView)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.top.equalTo(iconImageView.snp.bottom).offset(14)
            m.left.equalTo(iconImageView)
        }

        symbleLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalTo(timeLabel)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.right.equalTo(symbleLabel.snp.left).offset(-4)
            m.centerY.equalTo(timeLabel)
        }

        let width = (kScreenW / 2) - 33.0
        leftHashLabel.snp.makeConstraints { (m) in
            m.top.equalTo(timeLabel.snp.bottom).offset(9)
            m.left.equalTo(iconImageView)
            m.width.equalTo(width)
        }

        rightHashLabel.snp.makeConstraints { (m) in
            m.top.equalTo(timeLabel.snp.bottom).offset(9)
            m.right.equalTo(symbleLabel)
            m.width.equalTo(width)
        }
    }

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return dateFormatter
    }()
    
    func bind(tokenInfo: TokenInfo,withdrawRecord record: WithdrawRecord)  {
        self.bind(tokenInfo: tokenInfo,record: record, type: .withdraw)
    }

    func bind(tokenInfo: TokenInfo,depositRecord record: DepositRecord)  {
        self.bind(tokenInfo: tokenInfo, record: record, type: .desposit)
    }

    func bind(tokenInfo: TokenInfo,record:  Record, type: CrossChainHistoryViewController.Style) {
        statusLabel.text = record.state.rawValue

        let date = Date.init(timeIntervalSince1970: TimeInterval((Double(record.dateTime) ?? 0.0
            ) / 1000.0))
        let timeString = CrossChainHistoryCell.dateFormatter.string(from: date)
        timeLabel.text = timeString

        amountLabel.text = Amount(record.amount)?.amountShort(decimals: tokenInfo.decimals)

        let viteSymble = "VITE"
        let othenSymble = tokenInfo.gatewayInfo?.mappedToken.symbol ?? "Other"

        if type == .withdraw {
            leftHashLabel.text =  "\(viteSymble) Hash:" + record.inTxHash
            rightHashLabel.text = "\(othenSymble) Hash:" + (record.outTxHash ?? "")

            var statusString = ""
            switch record.state {
            case .OPPOSITE_PROCESSING:
                statusString = R.string.localizable.crosschainStatusWaitToConfirm(othenSymble)
                iconImageView.image = R.image.crosschain_status_vite()
            case .OPPOSITE_CONFIRMED:
                statusString = R.string.localizable.crosschainStatusConfirmed()
                iconImageView.image = R.image.crosschain_status_confirm()
            case .BELOW_MINIMUM:
                statusString = ""
            case .TOT_PROCESSING:
                statusString = R.string.localizable.crosschainStatusWaitToConfirm(viteSymble)
                iconImageView.image = R.image.crosschain_status_vite()
            case .TOT_CONFIRMED:
                statusString = R.string.localizable.crosschainStatusGatewayReceived()
                iconImageView.image = R.image.crosschain_status_gateway()
            case .UNKNOW:
                statusString = ""
            }
            statusLabel.text = statusString

        } else if type == .desposit {
            leftHashLabel.text = "\(othenSymble) Hash:" + record.inTxHash
            rightHashLabel.text = "\(viteSymble) Hash:" + (record.outTxHash ?? "")

            var statusString = ""
            switch record.state {
            case .OPPOSITE_PROCESSING:
                statusString = R.string.localizable.crosschainStatusWaitToConfirm(othenSymble)
                iconImageView.image = R.image.crosschain_status_vite()
            case .OPPOSITE_CONFIRMED:
                statusString = R.string.localizable.crosschainStatusGatewayReceived()
                iconImageView.image = R.image.crosschain_status_gateway()
            case .BELOW_MINIMUM:
                statusString = R.string.localizable.crosschainStatusFailedBecausePoor()
            case .TOT_PROCESSING:
                statusString = R.string.localizable.crosschainStatusWaitToConfirm(viteSymble)
                iconImageView.image = R.image.crosschain_status_vite()
            case .TOT_CONFIRMED:
                statusString = R.string.localizable.crosschainStatusConfirmed()
                iconImageView.image = R.image.crosschain_status_confirm()
            case .UNKNOW:
                statusString = ""
            }

            statusLabel.text = statusString
        }

    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
