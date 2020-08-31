//
//  DexTokenDetailListWalletViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/31.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet
import BigInt

class DexTokenDetailListWalletViewModel: ListViewModel<AccountBlock> {
    static let limit = 200
    let tokenInfo: TokenInfo
    let address: ViteAddress


    init(tableView: UITableView, tokenInfo: TokenInfo, address: ViteAddress) {
        self.tokenInfo = tokenInfo
        self.address = address
        super.init(tableView: tableView)
        self.tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [AccountBlock], hasMore: Bool)> {
        return ViteNode.ledger.getAccountBlocks(address: address, tokenId: tokenInfo.viteTokenId, hash: nil, count: type(of: self).limit).map { (items: $0.accountBlocks.filter { ($0.amount ?? Amount(0)) > Amount(0) }, hasMore: false) }
    }

    override func loadMore() -> Promise<(items: [AccountBlock], hasMore: Bool)> {
        return .value(([], false))
    }

    override func clicked(model: AccountBlock) {

    }

    override func cellHeight(model: AccountBlock) -> CGFloat {
        return DexTokenDetailItemCell.cellHeight
    }

    override func cellFor(model: AccountBlock, indexPath: IndexPath) -> UITableViewCell {
        let cell: DexTokenDetailItemCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(accountBlock: model)
        return cell
    }

    override func merge(items: [AccountBlock]) {
        self.items.append(contentsOf: items)
    }
}

