//
//  DexTokenDetailListDexViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/27.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet
import BigInt

class DexTokenDetailListDexViewModel: ListViewModel<DexDepositWithdraw> {
    static let limit = 50
    let tokenInfo: TokenInfo
    let address: ViteAddress


    init(tableView: UITableView, tokenInfo: TokenInfo, address: ViteAddress) {
        self.tokenInfo = tokenInfo
        self.address = address
        super.init(tableView: tableView)
        self.tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [DexDepositWithdraw], hasMore: Bool)> {
        return UnifyProvider.vitex.getDexDepositWithdrawList(address: address, viteTokenId: tokenInfo.viteTokenId, offset: 0, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func loadMore() -> Promise<(items: [DexDepositWithdraw], hasMore: Bool)> {
        return UnifyProvider.vitex.getDexDepositWithdrawList(address: address, viteTokenId: tokenInfo.viteTokenId, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func clicked(model: DexDepositWithdraw) {

    }

    override func cellHeight(model: DexDepositWithdraw) -> CGFloat {
        return DexTokenDetailItemCell.cellHeight
    }

    override func cellFor(model: DexDepositWithdraw, indexPath: IndexPath) -> UITableViewCell {
        let cell: DexTokenDetailItemCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(dexDepositWithdraw: model)
        return cell
    }

    override func merge(items: [DexDepositWithdraw]) {
        self.items.append(contentsOf: items)
    }
}
