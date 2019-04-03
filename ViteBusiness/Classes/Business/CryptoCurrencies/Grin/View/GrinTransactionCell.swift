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

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var creationTimeLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    func bind(_ tx: TxLogEntry) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        var timeString = tx.creationTs
        if let creationTs = tx.creationTs.components(separatedBy: ".").first?.replacingOccurrences(of: "-", with: "/").replacingOccurrences(of: "T", with: " ") {
            timeString = creationTs
            if let date = dateFormatter.date(from: creationTs) {
                dateFormatter.timeZone = TimeZone.current
                timeString = dateFormatter.string(from: date)
            }
        }
        self.creationTimeLabel.text = (timeString) + " \(R.string.localizable.grinTxFileInitStatus())"

        self.feeLabel.text = "\(R.string.localizable.grinSentFee()) \(Balance(value: BigInt(tx.fee ?? 0)).amountShort(decimals:9))"

        let amount = (tx.amountCredited ?? 0) - (tx.amountDebited ?? 0) + (tx.fee ?? 0)
        self.amountLabel.text =  (amount < 0 ? "-" : "") + Balance(value: BigInt(abs(amount))).amount(decimals: 9, count: 2)
        if amount > 0 {
            amountLabel.textColor = UIColor.init(netHex: 0x5BC500)
            icon.image = R.image.grin_tx_receive()
        } else {
            amountLabel.textColor = UIColor.init(netHex: 0xFF0008)
            icon.image = R.image.grin_tx_send()
        }

        var status = "Grin Transaction"
        var image: UIImage? = R.image.grin_tx_send()
        if tx.txType == .confirmedCoinbase {
            status = R.string.localizable.grinTxTypeConfirmedCoinbase()
            image = R.image.grin_txlist_confirmdconbase()
        } else if tx.confirmed {
            status = R.string.localizable.grinTxTypeConfirmed()
            image = R.image.grin_txlist_singe()
        } else if tx.txType == .txSentCancelled ||  tx.txType == .txReceivedCancelled {
            status = R.string.localizable.grinTxCancele()
            image = R.image.grin_txlist_cancled()
        } else if tx.txType == .txReceived {
            status = R.string.localizable.grinTxTypeReceived()
            image = R.image.grin_txlist_confirmd()
        } else if tx.txType == .txSent {
            if let slateId = tx.txSlateId,
                GrinManager.default.finalizedTxs().contains(slateId) {
                status =  R.string.localizable.grinTxTypeFinalized()
                image = R.image.grin_txlist_finalized()
            } else {
                status =  R.string.localizable.grinTxTypeSent()
                image = R.image.grin_txlist_send()
            }
        }
        self.statusLabel.text = status
        icon.image = image

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
