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
    let transaction: ETHTransaction
    let confirmations: String
    let stateString: String?

    init(transaction: ETHTransaction, isShowingInEthList: Bool) {
        self.transaction = transaction
        typeImage = (transaction.type == .receive) ? R.image.icon_tx_receive()! : R.image.icon_tx_send()!
        typeName = R.string.localizable.transactionListTransactionTypeNameTransfer()
        address = (transaction.type == .receive) ? transaction.fromAddress : transaction.toAddress
        timeString = transaction.timeStamp.format("yyyy.MM.dd HH:mm:ss")
        let amount: Amount
        if isShowingInEthList && transaction.contractAddress.isNotEmpty {
            amount = Amount(0)
        } else {
            amount = transaction.amount
        }
        let symbol = ((amount == 0) || transaction.type == .me ) ? "" : (transaction.type == .receive ? "+" : "-")
        balanceString = "\(symbol)\(amount.amountShortWithGroupSeparator(decimals: transaction.tokenInfo.decimals))"
        balanceColor = transaction.type == .send ? UIColor(netHex: 0xFF0008) : UIColor(netHex: 0x01D764)
        symbolString = transaction.tokenInfo.symbol
        gasString = R.string.localizable.ethPageGasFeeTitle() + " " + (transaction.gasUsed*transaction.gasPrice).amountFullWithGroupSeparator(decimals: TokenInfo.BuildIn.eth.value.decimals)
        hash = transaction.hash
        confirmations = transaction.confirmations
        stateString = transaction.isError ? R.string.localizable.ethTransactionDetailFailed() : nil
    }
}
