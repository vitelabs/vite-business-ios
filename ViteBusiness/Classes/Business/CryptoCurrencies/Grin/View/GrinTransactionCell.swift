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
        let creationTs = tx.creationTs.components(separatedBy: ".").first?.replacingOccurrences(of: "-", with: "/").replacingOccurrences(of: "T", with: " ")
        self.creationTimeLabel.text = (creationTs ?? tx.creationTs) + " \(R.string.localizable.grinTxFileInitStatus())"

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
        if tx.txType == .confirmedCoinbase {
            status = R.string.localizable.grinTxTypeConfirmedCoinbase()
        } else if tx.confirmed {
            status = R.string.localizable.grinTxTypeConfirmed()
        } else if tx.txType == .txSentCancelled ||  tx.txType == .txReceivedCancelled {
            status = R.string.localizable.grinTxCancele()
        } else if tx.txType == .txReceived {
            status = R.string.localizable.grinTxTypeReceived()
        } else if tx.txType == .txSent {
            if let slateId = tx.txSlateId,
                GrinManager.default.finalizedTxs().contains(slateId) {
                status =  R.string.localizable.grinTxTypeFinalized()
            } else {
                status =  R.string.localizable.grinTxTypeSent()
            }
        }
        self.statusLabel.text = status
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
