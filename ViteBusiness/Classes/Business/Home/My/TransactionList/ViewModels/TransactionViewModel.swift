//
//  TransactionViewModel.swift
//  Vite
//
//  Created by Stone on 2018/9/11.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import BigInt

final class TransactionViewModel: TransactionViewModelType {
    let typeImage: UIImage
    let typeName: String
    let address: String
    let timeString: String
    let balanceString: String
    let balanceColor: UIColor
    let symbolString: String
    let hash: String
    let isGenesis: Bool
    let accountBlock: AccountBlock

    init(accountBlock: AccountBlock) {
        self.accountBlock = accountBlock
        if accountBlock.type == .genesisReceive {
            self.isGenesis = true
            self.typeImage = accountBlock.transactionType.icon
            self.typeName = R.string.localizable.transactionListPageGenesisCellName()
            self.address = (accountBlock.transactionType == .receive ? accountBlock.fromAddress : accountBlock.toAddress) ?? ""
            self.timeString = {
                if let t = accountBlock.timestamp, t > 0 {
                    return Date(timeIntervalSince1970: TimeInterval(t)).format("yyyy.MM.dd HH:mm:ss")
                } else {
                    return ""
                }
            }()
            self.balanceString = ""
            self.balanceColor = accountBlock.transactionType == .receive ? UIColor(netHex: 0x5BC500) : UIColor(netHex: 0xFF0008)
            self.symbolString = accountBlock.token?.symbol ?? ""
            self.hash = accountBlock.hash ?? ""
        } else {
            self.isGenesis = false
            self.typeImage = accountBlock.transactionType.icon
            self.typeName = accountBlock.transactionType.name
            self.address = (accountBlock.transactionType == .receive ? accountBlock.fromAddress : accountBlock.toAddress) ?? ""
            self.timeString = {
                if let t = accountBlock.timestamp, t > 0 {
                    return Date(timeIntervalSince1970: TimeInterval(t)).format("yyyy.MM.dd HH:mm:ss")
                } else {
                    return ""
                }
            }()
            let symbol = (accountBlock.amount ?? 0) == 0 ? "" : (accountBlock.transactionType == .receive ? "+" : "-")
            self.balanceString = "\(symbol)\(accountBlock.amount!.amountShortWithGroupSeparator(decimals: accountBlock.token!.decimals))"
            self.balanceColor = accountBlock.transactionType == .receive ? UIColor(netHex: 0x5BC500) : UIColor(netHex: 0xFF0008)
            self.symbolString = accountBlock.token?.symbol ?? ""
            self.hash = accountBlock.hash ?? ""
        }
    }
}

extension AccountBlock.TransactionType {
    var name: String {
        switch self {
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

    var icon: UIImage! {
        switch self {
        case .register, .registerUpdate, .cancelRegister:
            return R.image.icon_tx_register()
        case .extractReward:
            return R.image.icon_tx_reward()
        case .vote, .cancelVote:
            return R.image.icon_tx_vote()
        case .pledge, .cancelPledge:
            return R.image.icon_tx_pledge()
        case .coin:
            return R.image.icon_tx_coin()
        case .send:
            return R.image.icon_tx_send()
        case .receive:
            return R.image.icon_tx_receive()
        }
    }
}
