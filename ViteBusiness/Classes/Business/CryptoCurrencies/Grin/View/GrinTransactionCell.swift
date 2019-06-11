//
//  GrinTransactionCell.swift
//  Action
//
//  Created by haoshenyang on 2019/3/8.
//

import UIKit
import Vite_GrinWallet
import BigInt
import ViteWallet

class GrinTransactionCell: UITableViewCell {

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        return dateFormatter
    }()

    var dateFormatter: DateFormatter {
        return GrinTransactionCell.dateFormatter
    }

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var creationTimeLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!

    let txMethodLabel = LabelBgView()


    func bind(_ fullInfo: GrinFullTxInfo) {
        txMethodLabel.isHidden = false
        if fullInfo.isHttpTx {
            txMethodLabel.titleLab.text = " \(R.string.localizable.grinTxMethodHttp()) "
        } else if fullInfo.isViteTx {
            txMethodLabel.titleLab.text = " \(R.string.localizable.grinTxMethodVite()) "
        } else if fullInfo.isFileTx {
            txMethodLabel.titleLab.text = " \(R.string.localizable.grinTxMethodFile()) "
        } else {
            txMethodLabel.isHidden = true
        }

        creationTimeLabel.text = ""

        if let slate = fullInfo.historyReceivedSendSlate() {
            icon.image = R.image.grin_txlist_receive_waitToReceive()
            statusLabel.text = R.string.localizable.grinTxTypeWaitToSign()
            let amount = slate.amount
            amountLabel.text =  (amount < 0 ? "-" : "") + Amount(amount).amount(decimals: 9, count: 4)
            amountLabel.textColor = amount >= 0 ? UIColor(netHex: 0x5BC500) : UIColor(netHex: 0xFF0008)
            feeLabel.text = "\(R.string.localizable.grinSentFee()) \(Amount(0).amountShort(decimals:9))"
            return
        }

        if let gatewayInfo = fullInfo.gatewayInfo {
            if gatewayInfo.confirmInfo?.confirm == true {
                icon.image = R.image.grin_txlist_receive_gatewayConfirmed()
                statusLabel.text = R.string.localizable.grinTxTypeConfirmed()
            } else {
                icon.image = R.image.grin_txlist_receive_gatewayReceived()
                statusLabel.text = R.string.localizable.grinTxTypeReceived()
            }
            feeLabel.text = "\(R.string.localizable.grinSentFee()) \(Amount(0).amountShort(decimals:9))"
            let amount = (Int(gatewayInfo.toAmount ?? gatewayInfo.fromAmount ?? "") ?? 0)
            amountLabel.text =  (amount < 0 ? "-" : "") + Amount(amount).amount(decimals: 9, count: 4)
            amountLabel.textColor = amount >= 0 ? UIColor(netHex: 0x5BC500) : UIColor(netHex: 0xFF0008)
            let date = Date.init(timeIntervalSince1970: TimeInterval(gatewayInfo.createTime/1000))
            let timeString = dateFormatter.string(from: date)
            creationTimeLabel.text = (timeString) + " \(R.string.localizable.grinTxFileInitStatus())"
        }

        if let localInfo = fullInfo.localInfo,
            fullInfo.txLogEntry == nil,
            localInfo.type == "Receive",
            localInfo.getSendFileTime != nil,
            localInfo.receiveTime == nil,
            let data =  FileManager.default.contents(atPath:  GrinManager.default.getSlateUrl(slateId: localInfo.slateId ?? "", isResponse: false).path),
            let slateString = String.init(data: data, encoding: .utf8),
            let slate = Slate(JSONString: slateString) {
                icon.image = R.image.grin_txlist_receive_waitToReceive()
                statusLabel.text = R.string.localizable.grinTxTypeWaitToSign()
            let amount = slate.amount
            amountLabel.text =  (amount < 0 ? "-" : "") + Amount(amount).amount(decimals: 9, count: 4)
            amountLabel.textColor = amount >= 0 ? UIColor(netHex: 0x5BC500) : UIColor(netHex: 0xFF0008)
            feeLabel.text = "\(R.string.localizable.grinSentFee()) \(Amount(0).amountShort(decimals:9))"
        }

        guard let tx = fullInfo.txLogEntry else { return }
        var timeString = tx.creationTs
        if let creationTs = tx.creationTs.components(separatedBy: ".").first?.replacingOccurrences(of: "-", with: "/").replacingOccurrences(of: "T", with: " ") {
            timeString = creationTs
            dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
            if let date = dateFormatter.date(from: creationTs) {
                dateFormatter.timeZone = TimeZone.current
                timeString = dateFormatter.string(from: date)
            }
        }

        creationTimeLabel.text = (timeString) + " \(R.string.localizable.grinTxFileInitStatus())"
        feeLabel.text = "\(R.string.localizable.grinSentFee()) \(Amount(tx.fee ?? 0).amountShort(decimals:9))"
        let amount = (tx.amountCredited ?? 0) - (tx.amountDebited ?? 0) + (tx.fee ?? 0)
        amountLabel.text =  (amount < 0 ? "-" : "") + Amount(abs(amount)).amount(decimals: 9, count: 4)
        amountLabel.textColor = amount >= 0 ? UIColor(netHex: 0x5BC500) : UIColor(netHex: 0xFF0008)

        var status = "Grin Transaction"
        var image: UIImage? = R.image.grin_tx_send()
        if tx.txType == .confirmedCoinbase {
            status = R.string.localizable.grinTxTypeConfirmedCoinbase()
            image = R.image.grin_txlist_confirmedConebase()
        } else if tx.confirmed {
            status = R.string.localizable.grinTxTypeConfirmed()
            image = R.image.grin_txlist_confirmed()
        } else if tx.txType == .txSentCancelled ||  tx.txType == .txReceivedCancelled {
            status = R.string.localizable.grinTxCancele()
            image = R.image.grin_txlist_cancled()
        } else if tx.txType == .txReceived {
            status = R.string.localizable.grinTxTypeReceived()
            image = R.image.grin_txlist_receive_received()
        } else if tx.txType == .txSent {
            if let time = fullInfo.localInfo?.finalizeTime, time > 0 {
                status =  R.string.localizable.grinTxTypeFinalized()
                image = R.image.grin_txlist_send_posting()
            } else if let time = fullInfo.localInfo?.getResponseFileTime, time > 0 {
                status =  R.string.localizable.grinTxTypeWaitToFinalize()
                image = R.image.grin_txlist_send_waitToFinalize()
            } else {
                status =  R.string.localizable.grinTxTypeSent()
                image = R.image.grin_txlist_send_created()
            }
        }
        statusLabel.text = status
        icon.image = image

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        contentView.addSubview(txMethodLabel)
        txMethodLabel.snp.makeConstraints { (m) in
            m.left.equalTo(statusLabel.snp.right).offset(8)
            m.centerY.equalTo(statusLabel)
        }

        txMethodLabel.titleLab.snp.remakeConstraints { (m) in
            m.top.bottom.equalTo(txMethodLabel)
            m.left.equalTo(txMethodLabel).offset(0)
            m.right.equalTo(txMethodLabel).offset(-3)
        }
        //        txMethodLabel.backgroundColor = UIColor.init(netHex: 0xDFEEFF,alpha: 0.61)
        txMethodLabel.titleLab.font = UIFont.systemFont(ofSize: 12)
        txMethodLabel.titleLab.textColor = UIColor.init(netHex: 0x007aff)
        txMethodLabel.bgImg.image = R.image.grin_methd_bg()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
