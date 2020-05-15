//
//  ViteTransactionDetailHolder.swift
//  ViteBusiness
//
//  Created by Stone on 2020/5/15.
//

import Foundation
import ViteWallet
import PromiseKit

class ViteTransactionDetailHolder: TransactionDetailHolder {

    let accountBlock: AccountBlock
    init(accountBlock: AccountBlock) {
        self.accountBlock = accountBlock

        let timeString = Date(timeIntervalSince1970: TimeInterval(accountBlock.timestamp!)).format("yyyy.MM.dd HH:mm:ss")
        let link = TransactionDetailHolder.Link(text: R.string.localizable.viteTransactionDetailPageLinkButtonTitle(), url: WebHandler.viteTranscationDetailPageURL(hash: accountBlock.hash!)!)


        let typeString: String
        if accountBlock.type == .receive || accountBlock.type == .genesisReceive {
            typeString = R.string.localizable.viteTransactionDetailPageTypeReceive()
        } else {
            typeString = R.string.localizable.viteTransactionDetailPageTypeSend()
        }

        var items: [TransactionDetailHolder.Item] = [
            .address(title: R.string.localizable.ethTransactionDetailToAddress(), text: accountBlock.toAddress!, hasSeparator: true),
            .address(title: R.string.localizable.ethTransactionDetailFromAddress(), text: accountBlock.fromAddress!, hasSeparator: false),
            .ammount(title: R.string.localizable.ethTransactionDetailAmount(), text: accountBlock.amount!.amountShortWithGroupSeparator(decimals: accountBlock.token!.decimals), symbol: accountBlock.token!.symbol),
            .height(title: R.string.localizable.viteTransactionDetailPageTypeTitle(), text: typeString),
            .copyable(title: R.string.localizable.viteTransactionDetailPageHashTitle(), text: "\(accountBlock.hash!.prefix(8))...\(accountBlock.hash!.suffix(6))", rawText: accountBlock.hash!),
            .height(title: R.string.localizable.viteTransactionDetailPageHeightTitle(), text: "\(accountBlock.height!)"),
        ]

        if accountBlock.toAddress!.isDexAddress {

            let note: String?
            if let data = accountBlock.data {
                note = data.accountBlockDataToUTF8String() ?? data.toHexString()
            } else {
                note = nil
            }

            if let note = note {
                items.append(.note(title: R.string.localizable.viteTransactionDetailPageNoteTitle(), text: note))
            }

            if let receiveBlockHash = accountBlock.receiveBlockHash {

                super.init { () -> Promise<TransactionDetailHolder.ViewModel> in
                    ViteNode.ledger.getAccountBlock(hash: receiveBlockHash).map { (receiveBlock) -> TransactionDetailHolder.ViewModel in

                        let isSuccess: Bool
                        if let data = receiveBlock?.data, data.count == 33, data[32] == 0x00 {
                            isSuccess = true
                        } else {
                            isSuccess = false
                        }

                        let headerImage = isSuccess ? R.image.icon_eth_detail_success()! : R.image.icon_eth_detail_falied()!
                        let stateString = isSuccess ? R.string.localizable.viteTransactionDetailPageStateCallSuccess() : R.string.localizable.viteTransactionDetailPageStateCallFailed()
                        return TransactionDetailHolder.ViewModel(headerImage: headerImage, stateString: stateString, timeString: timeString, items: items, link: link)
                    }
                }

            } else {
                let headerImage = R.image.icon_eth_detail_wait()!
                let stateString = R.string.localizable.viteTransactionDetailPageStateCallWait()

                super.init(vm: TransactionDetailHolder.ViewModel(headerImage: headerImage, stateString: stateString, timeString: timeString, items: items, link: link))
            }
        } else {

            let headerImage = R.image.icon_eth_detail_success()!
            let stateString = R.string.localizable.viteTransactionDetailPageStateSuccess()

            if accountBlock.type == .receive {
                super.init { () -> Promise<TransactionDetailHolder.ViewModel> in
                    ViteNode.ledger.getAccountBlock(hash: accountBlock.fromHash!).map { (sendBlock) -> TransactionDetailHolder.ViewModel in
                        let note: String?
                        if let data = sendBlock?.data {
                            note = data.accountBlockDataToUTF8String() ?? data.toHexString()
                        } else {
                            note = nil
                        }

                        if let note = note {
                            items.append(.note(title: R.string.localizable.viteTransactionDetailPageNoteTitle(), text: note))
                        }

                        return TransactionDetailHolder.ViewModel(headerImage: headerImage, stateString: stateString, timeString: timeString, items: items, link: link)
                    }
                }
            } else {
                let note: String?
                if let data = accountBlock.data {
                    note = data.accountBlockDataToUTF8String() ?? data.toHexString()
                } else {
                    note = nil
                }

                if let note = note {
                    items.append(.note(title: R.string.localizable.viteTransactionDetailPageNoteTitle(), text: note))
                }


                super.init(vm: TransactionDetailHolder.ViewModel(headerImage: headerImage, stateString: stateString, timeString: timeString, items: items, link: link))
            }
        }


    }
}
