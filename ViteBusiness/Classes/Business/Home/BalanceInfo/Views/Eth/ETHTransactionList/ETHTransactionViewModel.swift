//
//  ETHTransactionViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/26.
//

import Foundation
import ViteWallet

extension ETHTransaction: TransactionViewModelType {
    var typeImage: UIImage {
        (type == .receive) ? R.image.icon_tx_receive()! : R.image.icon_tx_send()!
    }

    var typeName: String {
        R.string.localizable.transactionListTransactionTypeNameTransfer()
    }

    var address: String {
        ((type == .receive) ? fromAddress : toAddress).lowercased()
    }

    var state: (text: String, color: UIColor) {
        if isError {
            return (text: R.string.localizable.ethTransactionDetailFailed(), color: UIColor(netHex: 0xFF0008))
        } else {
            if isConfirmed {
                return (text: R.string.localizable.transactionListTransactionConfirmationsFinished(), color: UIColor(netHex: 0x3E4A59, alpha: 0.3))
            } else {
                return (text: R.string.localizable.transactionListTransactionConfirmations(confirmations), color: UIColor(netHex: 0x3E4A59, alpha: 0.3))
            }
        }
    }

    var timeString: String {
        timeStamp.format("yyyy.MM.dd HH:mm:ss")
    }

    var balance: (text: String, color: UIColor) {
        let symbol = ((amount == 0) || type == .me ) ? "" : (type == .receive ? "+" : "-")
        let text = "\(symbol)\(amount.amountShortWithGroupSeparator(decimals: tokenInfo.decimals))"
        let color: UIColor = {
            switch type {
            case .send:
                return UIColor(netHex: 0xFF0008)
            case .receive:
                return UIColor(netHex: 0x01D764)
            case .me:
                return UIColor(netHex: 0xA8ADB4)
            }
        }()
        return (text: text, color: color)
    }
}

struct ETHUnconfirmedTransactionViewModel: TransactionViewModelType {

    let unconfirmed: ETHUnconfirmedTransaction
    let type: ETHUnconfirmedTransaction.TransactionType
    private let isShowingInEthList: Bool

    init(unconfirmed: ETHUnconfirmedTransaction, isShowingInEthList: Bool) {
        self.unconfirmed = unconfirmed
        self.isShowingInEthList = isShowingInEthList
        self.type = (isShowingInEthList ? unconfirmed.ethTransactionType : unconfirmed.erc20TransactionType)
    }

    var typeImage: UIImage {
        (type == .receive) ? R.image.icon_tx_receive()! : R.image.icon_tx_send()!
    }

    var typeName: String {
        R.string.localizable.transactionListTransactionTypeNameTransfer()
    }

    var address: String {
        let toAddress = isShowingInEthList ? unconfirmed.toAddress : unconfirmed.erc20ToAddress
        return ((type == .receive) ? unconfirmed.fromAddress : toAddress).lowercased()
    }

    var state: (text: String, color: UIColor) {
        return (text: R.string.localizable.ethTransactionDetailPageStateCallWait(), color: UIColor(netHex: 0xB5C4FF))
    }

    var timeString: String {
        unconfirmed.timeStamp.format("yyyy.MM.dd HH:mm:ss")
    }

    var balance: (text: String, color: UIColor) {
        let amount = isShowingInEthList ? unconfirmed.amount : unconfirmed.erc20Amount
        let symbol = ((amount == 0) || type == .me ) ? "" : (type == .receive ? "+" : "-")
        let text = "\(symbol)\(amount.amountShortWithGroupSeparator(decimals: unconfirmed.tokenInfo.decimals))"
        let color: UIColor = {
            switch type {
            case .send:
                return UIColor(netHex: 0xFF0008)
            case .receive:
                return UIColor(netHex: 0x01D764)
            case .me:
                return UIColor(netHex: 0xA8ADB4)
            }
        }()
        return (text: text, color: color)
    }
}
