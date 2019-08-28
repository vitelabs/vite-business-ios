//
//  GatewayWithdrawViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/6/11.
//

import UIKit
import BigInt
import ViteWallet
import RxSwift
import RxCocoa

class CrossChainHistoryCell: UITableViewCell {

    let iconImageView = UIImageView()
    let statusLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x77808A)
    }

    let reasonLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x77808A)
    }

    let feeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
    }

    let seperator = UIView().then {
        $0.backgroundColor = UIColor.init(netHex: 0xE5E5EA)
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
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }
    let rightHashLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 11)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }

    let leftHashButton = UIButton()

    let rightHashButton = UIButton()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none

        contentView.addSubview(iconImageView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(feeLabel)
        contentView.addSubview(seperator)
        contentView.addSubview(reasonLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(symbleLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(leftHashLabel)
        contentView.addSubview(rightHashLabel)
        contentView.addSubview(leftHashButton)
        contentView.addSubview(rightHashButton)


        iconImageView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.top.equalToSuperview().offset(18)
            m.width.height.equalTo(14)
        }

        statusLabel.snp.makeConstraints { (m) in
            m.left.equalTo(iconImageView.snp.right).offset(3)
            m.centerY.equalTo(iconImageView)
        }

        feeLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalTo(iconImageView)
        }

        seperator.snp.makeConstraints { (m) in
            m.left.equalTo(statusLabel.snp.right).offset(3)
            m.centerY.equalTo(iconImageView)
            m.width.equalTo(1)
            m.height.equalTo(12)
        }

        reasonLabel.snp.makeConstraints { (m) in
            m.left.equalTo(seperator.snp.right).offset(3)
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
            m.height.equalTo(16)
            m.width.equalTo(width)
        }

        rightHashLabel.snp.makeConstraints { (m) in
            m.top.equalTo(timeLabel.snp.bottom).offset(9)
            m.right.equalTo(symbleLabel)
            m.height.equalTo(16)
            m.width.equalTo(width)
        }

        leftHashButton.snp.makeConstraints { (m) in
            m.edges.equalTo(leftHashLabel)
        }

        rightHashButton.snp.makeConstraints { (m) in
            m.edges.equalTo(rightHashLabel)
        }

        seperator.isHidden = true
        reasonLabel.isHidden = true
    }

    var leftAction: Disposable?
    var rightAction: Disposable?

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

        seperator.isHidden = true
        reasonLabel.isHidden = true

        statusLabel.text = record.state.rawValue

        let date = Date.init(timeIntervalSince1970: TimeInterval((Double(record.dateTime) ?? 0.0
            ) / 1000.0))
        let timeString = CrossChainHistoryCell.dateFormatter.string(from: date)
        timeLabel.text = timeString

        amountLabel.text = Amount(record.amount)?.amountShort(decimals: tokenInfo.decimals)

        let viteSymble = "VITE"
        let othenPlatform = tokenInfo.gatewayInfo?.mappedToken.rawChainName ?? ""

        symbleLabel.text = tokenInfo.gatewayInfo?.mappedToken.symbol

        if let fee = Amount(record.fee)?.amountShort(decimals: tokenInfo.decimals) {
            feeLabel.text = "\(R.string.localizable.crosschainFee()) \(fee)"
        }


        if type == .withdraw {
            leftHashLabel.text =  " \(viteSymble) Hash: \(record.inTxHash) "
            rightHashLabel.text = " \(othenPlatform) Hash: \(record.outTxHash ?? "") "

            leftAction?.dispose()
            if !record.inTxHash.isEmpty {
                leftHashLabel.textColor = UIColor.init(netHex: 0x007AFF,alpha: 0.5)
                leftAction = leftHashButton.rx.tap.bind {
                    if let url = URL.init(string:record.inTxExplorer) {
                        let vc = WKWebViewController.init(url: url)
                        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                leftAction?.disposed(by: rx.disposeBag)
            } else {
                leftHashLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
            }

            rightAction?.dispose()
            if let outHash = record.outTxHash, !outHash.isEmpty {
                rightHashLabel.textColor = UIColor.init(netHex: 0x007AFF,alpha: 0.5)
                rightAction = rightHashButton.rx.tap.bind {
                    if let url = URL.init(string:record.outTxExplorer) {
                        let vc = WKWebViewController.init(url: url)
                        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                rightAction?.disposed(by: rx.disposeBag)
            } else {
                rightHashLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
            }

            var statusString = ""
            switch record.state {
            case .OPPOSITE_PROCESSING:
                statusString = R.string.localizable.crosschainStatusWaitToConfirm(othenPlatform)
                iconImageView.image = R.image.crosschain_status_vite()
            case .OPPOSITE_CONFIRMED:
                statusString = R.string.localizable.crosschainStatusConfirmed()
                iconImageView.image = R.image.crosschain_status_confirm()
            case .BELOW_MINIMUM:
                statusString = ""
            case .TOT_EXCEED_THE_LIMIT:
                seperator.isHidden = false
                reasonLabel.isHidden = false
                statusString = R.string.localizable.crosschainStatusWithdrawFailed()
                iconImageView.image = R.image.crosschain_status_failure()
                reasonLabel.text = R.string.localizable.crosschainStatusTotExceedLimit()
            case .WRONG_WITHDRAW_ADDRESS:
                statusString = R.string.localizable.crosschainStatusWrongAddress()
                iconImageView.image = R.image.crosschain_status_failure()
            case .TOT_PROCESSING:
                statusString = R.string.localizable.crosschainStatusWaitToConfirm(viteSymble)
                if let current = record.inTxConfirmedCount, let total = record.inTxConfirmationCount {
                    statusString = statusString + "(\(current)/\(total))"
                }
                iconImageView.image = R.image.crosschain_status_vite()
            case .TOT_CONFIRMED:
                statusString = R.string.localizable.crosschainStatusGatewayReceived()
                iconImageView.image = R.image.crosschain_status_gateway()
            case .UNKNOW:
                statusString = ""
            }
            statusLabel.text = statusString

        } else if type == .desposit {
            leftHashLabel.text = "\(othenPlatform) Hash:" + record.inTxHash
            rightHashLabel.text = "\(viteSymble) Hash:" + (record.outTxHash ?? "")

            leftAction?.dispose()
            rightAction?.dispose()

            if !record.inTxHash.isEmpty {
                leftHashLabel.textColor = UIColor.init(netHex: 0x007AFF,alpha: 0.5)
                leftAction = leftHashButton.rx.tap.bind {
                    if let url = URL.init(string:record.inTxExplorer) {
                        let vc = WKWebViewController.init(url: url)
                        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                leftAction?.disposed(by: rx.disposeBag)
            } else {
                leftHashLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
            }

            if let outHash = record.outTxHash, !outHash.isEmpty {
                rightHashLabel.textColor = UIColor.init(netHex: 0x007AFF,alpha: 0.5)
                rightAction = rightHashButton.rx.tap.bind {
                    if let url = URL.init(string:record.outTxExplorer) {
                        let vc = WKWebViewController.init(url: url)
                        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                rightAction?.disposed(by: rx.disposeBag)
            } else {
                rightHashLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
            }

            var statusString = ""
            switch record.state {
            case .OPPOSITE_PROCESSING:
                statusString = R.string.localizable.crosschainStatusWaitToConfirm(othenPlatform)
                if let current = record.inTxConfirmedCount, let total = record.inTxConfirmationCount {
                    statusString = statusString + "(\(current)/\(total))"
                }
                iconImageView.image = R.image.crosschain_status_vite()
            case .OPPOSITE_CONFIRMED:
                statusString = R.string.localizable.crosschainStatusGatewayReceived()
                iconImageView.image = R.image.crosschain_status_gateway()
            case .BELOW_MINIMUM:
                seperator.isHidden = false
                reasonLabel.isHidden = false
                statusString = R.string.localizable.crosschainStatusFailed()
                reasonLabel.text = R.string.localizable.crosschainStatusFailedBecausePoor()
                iconImageView.image = R.image.crosschain_status_failure()
                amountLabel.text = nil
                symbleLabel.text = nil
            case .TOT_EXCEED_THE_LIMIT:
                statusString = ""
            case .WRONG_WITHDRAW_ADDRESS:
                statusString = R.string.localizable.crosschainStatusFailed()
                iconImageView.image = R.image.crosschain_status_failure()
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
