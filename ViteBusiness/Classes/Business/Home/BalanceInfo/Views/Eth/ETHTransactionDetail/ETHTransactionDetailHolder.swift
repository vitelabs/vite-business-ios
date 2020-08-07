//
//  ETHTransactionDetailHolder.swift
//  ViteBusiness
//
//  Created by Stone on 2020/5/14.
//

import Foundation
import BigInt

class ETHTransactionDetailHolder: TransactionDetailHolder {

    init(transaction: ETHTransaction) {
                
        let headerImage = transaction.isError ? R.image.icon_eth_detail_falied()! : R.image.icon_eth_detail_success()!
        let stateString = transaction.isError ? R.string.localizable.ethTransactionDetailFailed() : R.string.localizable.ethTransactionDetailSuccess()
        let timeString = transaction.timeStamp.format("yyyy.MM.dd HH:mm:ss")
        let link = TransactionDetailHolder.Link(text: R.string.localizable.ethTransactionDetailGoButtonTitle(), url: URL(string: "\(ViteConst.instance.eth.explorer)/tx/\(transaction.hash)")!)
        let confirmations = BigInt(transaction.confirmations)! > 120 ? "120+" : transaction.confirmations
        var items: [TransactionDetailHolder.Item] = [
            .address(title: R.string.localizable.ethTransactionDetailToAddress(), text: transaction.toAddress, hasSeparator: true),
            .address(title: R.string.localizable.ethTransactionDetailFromAddress(), text: transaction.fromAddress, hasSeparator: false),
            .ammount(title: R.string.localizable.ethTransactionDetailAmount(), text: transaction.amount.amountShortWithGroupSeparator(decimals: transaction.tokenInfo.decimals), symbol: transaction.tokenInfo.symbol),
            .ammount(title: R.string.localizable.ethTransactionDetailGasFee(), text: (transaction.gasUsed*transaction.gasPrice).amountFullWithGroupSeparator(decimals: TokenInfo.BuildIn.eth.value.decimals), symbol: TokenInfo.BuildIn.eth.value.symbol),
            .copyable(title: R.string.localizable.ethTransactionDetailHash(), text: "\(transaction.hash.prefix(8))...\(transaction.hash.suffix(6))", rawText: transaction.hash),
            .height(title: R.string.localizable.viteTransactionDetailPageConfirmationsTitle(), text: confirmations),
            .height(title: R.string.localizable.ethTransactionDetailBlock(), text: transaction.blockNumber)
        ]

        if transaction.tokenInfo.isEtherCoin && transaction.input.count > 2 {
            var text = transaction.input
            let bytes = transaction.input.hex2Bytes
            if bytes.count > 0, let note = String(bytes: bytes, encoding: .utf8) {
                text = note
            }
            items.append(.note(title: R.string.localizable.ethTransactionDetailNote(), text: text))
        }

        let vm = TransactionDetailHolder.ViewModel(headerImage: headerImage, stateString: stateString, timeString: timeString, items: items, link: link)
        super.init(vm: vm)
    }

    init(unconfirmed: ETHUnconfirmedTransaction, isShowingInEthList: Bool) {
        let headerImage = R.image.icon_eth_detail_wait()!
        let stateString = R.string.localizable.ethTransactionDetailPageStateCallWait()
        let timeString = unconfirmed.timeStamp.format("yyyy.MM.dd HH:mm:ss")
        let confirmations = "0"

        let toAddress = isShowingInEthList ? unconfirmed.toAddress : unconfirmed.erc20ToAddress
        let amount = isShowingInEthList ? unconfirmed.amount : unconfirmed.erc20Amount
        let decimals = isShowingInEthList ? TokenInfo.BuildIn.eth.value.decimals : unconfirmed.tokenInfo.decimals
        let symbol = isShowingInEthList ? TokenInfo.BuildIn.eth.value.symbol : unconfirmed.tokenInfo.symbol

        var items: [TransactionDetailHolder.Item] = [
            .address(title: R.string.localizable.ethTransactionDetailToAddress(), text: toAddress, hasSeparator: true),
            .address(title: R.string.localizable.ethTransactionDetailFromAddress(), text: unconfirmed.fromAddress, hasSeparator: false),
            .ammount(title: R.string.localizable.ethTransactionDetailAmount(), text: amount.amountShortWithGroupSeparator(decimals: decimals), symbol: symbol),
            .ammount(title: R.string.localizable.ethTransactionDetailGasPrice(), text: unconfirmed.gasPrice.amount(decimals: 9, count: 4, groupSeparator: true), symbol: "gwei"),
            .height(title: R.string.localizable.ethTransactionDetailGasLimit(), text: unconfirmed.gasLimit.description),
            .ammount(title: R.string.localizable.ethTransactionDetailGasFee(), text: "--", symbol: TokenInfo.BuildIn.eth.value.symbol),
            .copyable(title: R.string.localizable.ethTransactionDetailHash(), text: "\(unconfirmed.hash.prefix(8))...\(unconfirmed.hash.suffix(6))", rawText: unconfirmed.hash),
            .height(title: R.string.localizable.viteTransactionDetailPageConfirmationsTitle(), text: confirmations),
            .height(title: R.string.localizable.ethTransactionDetailBlock(), text: R.string.localizable.ethTransactionDetailPageStateCallWait())
        ]

        if isShowingInEthList && unconfirmed.input.count > 2 {
            var text = unconfirmed.input
            let bytes = unconfirmed.input.hex2Bytes
            if bytes.count > 0, let note = String(bytes: bytes, encoding: .utf8) {
                text = note
            }
            items.append(.note(title: R.string.localizable.ethTransactionDetailNote(), text: text))
        }

        let vm = TransactionDetailHolder.ViewModel(headerImage: headerImage, stateString: stateString, timeString: timeString, items: items, link: nil)
        super.init(vm: vm)
    }
}
