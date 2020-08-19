//
//  ViteTransactionViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/19.
//

import Foundation
import ViteWallet

extension AccountBlock: TransactionViewModelType {

    var typeImage: UIImage {
        switch transactionType {
        case .contract:
            return R.image.icon_tx_contract()!
        case .register, .registerUpdate, .cancelRegister:
            return R.image.icon_tx_register()!
        case .extractReward:
            return R.image.icon_tx_reward()!
        case .vote, .cancelVote:
            return R.image.icon_tx_vote()!
        case .pledge, .cancelPledge:
            return R.image.icon_tx_pledge()!
        case .coin:
            return R.image.icon_tx_coin()!
        case .send:
            return R.image.icon_tx_send()!
        case .receive:
            return R.image.icon_tx_receive()!
        }
    }

    var typeName: String {
        switch transactionType {
        case .contract:
            return R.string.localizable.transactionListTransactionTypeNameContract()
        case .register:
            return R.string.localizable.transactionListTransactionTypeNameRegister()
        case .registerUpdate:
            return R.string.localizable.transactionListTransactionTypeNameRegisterUpdate()
        case .cancelRegister:
            return R.string.localizable.transactionListTransactionTypeNameCancelRegister()
        case .extractReward:
            return R.string.localizable.transactionListTransactionTypeNameExtractReward()
        case .vote:
            return R.string.localizable.transactionListTransactionTypeNameVote()
        case .cancelVote:
            return R.string.localizable.transactionListTransactionTypeNameCancelVote()
        case .pledge:
            return R.string.localizable.transactionListTransactionTypeNamePledge()
        case .cancelPledge:
            return R.string.localizable.transactionListTransactionTypeNameCancelPledge()
        case .coin:
            return R.string.localizable.transactionListTransactionTypeNameCoin()
        case .send, .receive:
            return R.string.localizable.transactionListTransactionTypeNameTransfer()
        }
    }

    var address: String {
        return (transactionType == .receive ? fromAddress : toAddress) ?? ""
    }

    var state: (text: String, color: UIColor) {
        if isConfirmed {
            return (text: R.string.localizable.transactionListTransactionConfirmationsFinished(), color: UIColor(netHex: 0x3E4A59, alpha: 0.3))
        } else {
            if let confirmations = confirmations, confirmations > 0 {
                return (text: R.string.localizable.transactionListTransactionConfirmations("\(confirmations)"), color: UIColor(netHex: 0x3E4A59, alpha: 0.3))
            } else {
                return (text: R.string.localizable.ethTransactionDetailPageStateCallWait(), color: UIColor(netHex: 0xB5C4FF))
            }
        }
    }

    var timeString: String {
        if let t = timestamp, t > 0 {
            return Date(timeIntervalSince1970: TimeInterval(t)).format("yyyy.MM.dd HH:mm:ss")
        } else {
            return ""
        }
    }

    var balance: (text: String, color: UIColor) {
        let symbol = (amount ?? 0) == 0 ? "" : (transactionType == .receive ? "+" : "-")
        let text = "\(symbol)\(amount!.amountShortWithGroupSeparator(decimals: token!.decimals))"
        let color = transactionType == .receive ? UIColor(netHex: 0x01D764) : UIColor(netHex: 0xFF0008)
        return (text: text, color: color)
    }


    var isConfirmed: Bool {
        if let confirmations = confirmations, confirmations <= 300 {
            return false
        } else {
            return true
        }
    }
}
