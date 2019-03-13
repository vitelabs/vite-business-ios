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
        self.creationTimeLabel.text = (creationTs ?? tx.creationTs) + " Initlallzed"

        self.feeLabel.text = "Fee \(Balance(value: BigInt(tx.fee ?? 0)).amountShort(decimals:9))"

        let amount = (tx.amountCredited ?? 0) - (tx.amountDebited ?? 0) + (tx.fee ?? 0)
        self.amountLabel.text =  (amount < 0 ? "-" : "") + Balance(value: BigInt(abs(amount))).amountShort(decimals:9)
        if amount > 0 {
            amountLabel.textColor = UIColor.init(netHex: 0x5BC500)
            icon.image = R.image.grin_tx_receive()
        } else {
            amountLabel.textColor = UIColor.init(netHex: 0xFF0008)
            icon.image = R.image.grin_tx_send()
        }

        if tx.confirmed {
            self.statusLabel.text = "Confirmed"
        } else if tx.txType == .txSent {
            self.statusLabel.text = "Sent"
        } else if tx.txType == .txReceived {
            self.statusLabel.text = "Signed"
        } else if tx.txType == .confirmedCoinbase || tx.txType == .txSentCancelled ||  tx.txType == .txReceivedCancelled{
            self.statusLabel.text = tx.txType.rawValue
        } 
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
