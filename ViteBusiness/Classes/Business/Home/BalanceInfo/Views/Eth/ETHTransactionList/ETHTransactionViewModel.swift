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
    let stateString: String?

    init(transaction: ETHTransaction) {
        self.transaction = transaction
        self.unconfirmed = nil
        typeImage = (transaction.type == .receive) ? R.image.icon_tx_receive()! : R.image.icon_tx_send()!
        typeName = R.string.localizable.transactionListTransactionTypeNameTransfer()
        address = (transaction.type == .receive) ? transaction.fromAddress : transaction.toAddress
        timeString = transaction.timeStamp.format("yyyy.MM.dd HH:mm:ss")
        let amount = transaction.amount
        let symbol = ((amount == 0) || transaction.type == .me ) ? "" : (transaction.type == .receive ? "+" : "-")
        balanceString = "\(symbol)\(amount.amountShortWithGroupSeparator(decimals: transaction.tokenInfo.decimals))"
        balanceColor = transaction.type == .send ? UIColor(netHex: 0xFF0008) : UIColor(netHex: 0x01D764)
        symbolString = transaction.tokenInfo.symbol
        gasString = R.string.localizable.ethPageGasFeeTitle() + " " + (transaction.gasUsed*transaction.gasPrice).amountFullWithGroupSeparator(decimals: TokenInfo.BuildIn.eth.value.decimals)
        hash = transaction.hash
        confirmations = transaction.confirmations
        stateString = transaction.isError ? R.string.localizable.ethTransactionDetailFailed() : nil
    }

    init(unconfirmed: ETHUnconfirmedTransaction, isShowingInEthList: Bool) {
        self.transaction = nil
        self.unconfirmed = unconfirmed

        let type = isShowingInEthList ? unconfirmed.ethTransactionType : unconfirmed.erc20TransactionType
        let toAddress = isShowingInEthList ? unconfirmed.toAddress : unconfirmed.erc20ToAddress
        let amount = isShowingInEthList ? unconfirmed.amount : unconfirmed.erc20Amount
        let symbol = ((amount == 0) || type == .me ) ? "" : (type == .receive ? "+" : "-")

        typeImage = (type == .receive) ? R.image.icon_tx_receive()! : R.image.icon_tx_send()!
        typeName = R.string.localizable.transactionListTransactionTypeNameTransfer()
        address = (type == .receive) ? unconfirmed.fromAddress : toAddress
        timeString = unconfirmed.timeStamp.format("yyyy.MM.dd HH:mm:ss")
        balanceString = "\(symbol)\(amount.amountShortWithGroupSeparator(decimals: unconfirmed.tokenInfo.decimals))"
        balanceColor = type == .send ? UIColor(netHex: 0xFF0008) : UIColor(netHex: 0x01D764)
        symbolString = unconfirmed.tokenInfo.symbol
        gasString = ""
        hash = unconfirmed.hash
        confirmations = "0"
        stateString = nil
    }
}
