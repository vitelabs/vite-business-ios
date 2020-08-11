//
//  ETHTransactionViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/26.
//

import Foundation
import ViteWallet

struct ETHTransactionViewModel {

    let typeImage: UIImage
    let typeName: String
    let address: String
    let timeString: String
    let balanceString: String
    let balanceColor: UIColor
    let symbolString: String
    let gasString: String
    let hash: String
    let transaction: ETHTransaction?
    let unconfirmed: ETHUnconfirmedTransaction?
    let confirmations: String
    let confirmationsColor: UIColor

    init(transaction: ETHTransaction) {
        self.transaction = transaction
        self.unconfirmed = nil
        typeImage = (transaction.type == .receive) ? R.image.icon_tx_receive()! : R.image.icon_tx_send()!
        typeName = R.string.localizable.transactionListTransactionTypeNameTransfer()
        address = ((transaction.type == .receive) ? transaction.fromAddress : transaction.toAddress).lowercased()
        timeString = transaction.timeStamp.format("yyyy.MM.dd HH:mm:ss")
        let amount = transaction.amount
        let symbol = ((amount == 0) || transaction.type == .me ) ? "" : (transaction.type == .receive ? "+" : "-")
        balanceString = "\(symbol)\(amount.amountShortWithGroupSeparator(decimals: transaction.tokenInfo.decimals))"
        balanceColor = {
            switch transaction.type {
            case .send:
                return UIColor(netHex: 0xFF0008)
            case .receive:
                return UIColor(netHex: 0x01D764)
            case .me:
                return UIColor(netHex: 0xA8ADB4)
            }
        }()
        symbolString = transaction.tokenInfo.symbol
        gasString = R.string.localizable.ethPageGasFeeTitle() + " " + (transaction.gasUsed*transaction.gasPrice).amountFullWithGroupSeparator(decimals: TokenInfo.BuildIn.eth.value.decimals)
        hash = transaction.hash

        if transaction.isError {
            confirmations = R.string.localizable.ethTransactionDetailFailed()
            confirmationsColor = UIColor(netHex: 0xFF0008)
        } else {
            if transaction.isConfirmed {
                confirmations = R.string.localizable.transactionListTransactionConfirmationsFinished()
                confirmationsColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
            } else {
                confirmations = R.string.localizable.transactionListTransactionConfirmations(transaction.confirmations)
                confirmationsColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
            }
        }
    }

    init(unconfirmed: ETHUnconfirmedTransaction, isShowingInEthList: Bool) {
        self.transaction = nil
        self.unconfirmed = unconfirmed

        let type = (isShowingInEthList ? unconfirmed.ethTransactionType : unconfirmed.erc20TransactionType)
        let toAddress = isShowingInEthList ? unconfirmed.toAddress : unconfirmed.erc20ToAddress
        let amount = isShowingInEthList ? unconfirmed.amount : unconfirmed.erc20Amount
        let symbol = ((amount == 0) || type == .me ) ? "" : (type == .receive ? "+" : "-")

        typeImage = (type == .receive) ? R.image.icon_tx_receive()! : R.image.icon_tx_send()!
        typeName = R.string.localizable.transactionListTransactionTypeNameTransfer()
        address = ((type == .receive) ? unconfirmed.fromAddress : toAddress).lowercased()
        timeString = unconfirmed.timeStamp.format("yyyy.MM.dd HH:mm:ss")
        balanceString = "\(symbol)\(amount.amountShortWithGroupSeparator(decimals: unconfirmed.tokenInfo.decimals))"
        balanceColor = {
            switch type {
            case .send:
                return UIColor(netHex: 0xFF0008)
            case .receive:
                return UIColor(netHex: 0x01D764)
            case .me:
                return UIColor(netHex: 0xA8ADB4)
            }
        }()
        symbolString = unconfirmed.tokenInfo.symbol
        gasString = ""
        hash = unconfirmed.hash
        confirmations = R.string.localizable.ethTransactionDetailPageStateCallWait()
        confirmationsColor = UIColor(netHex: 0xB5C4FF)
    }
}
