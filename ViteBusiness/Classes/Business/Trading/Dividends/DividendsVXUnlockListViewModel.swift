//
//  DividendsVXUnlockListViewModel.swift
//  ViteBusiness
//
//  Created by stone on 2022/2/14.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet
import BigInt

class DividendsVXUnlockListViewModel: ListViewModel<DividendsVXUnlockListCellViewModel> {
    static let limit = 50
    let address: ViteAddress


    init(tableView: UITableView, address: ViteAddress) {
        self.address = address
        super.init(tableView: tableView)
        self.tirggerRefresh()
    }
    
    override func refresh() -> Promise<(items: [DividendsVXUnlockListCellViewModel], hasMore: Bool)> {
        return ViteNode.dex.info.getDexVxUnlockList(address: address, index: 0, count: type(of: self).limit)
            .map { (items: $0.list.map { model in
                DividendsVXUnlockListCellViewModel(time: R.string.localizable.dividendsPageUnlockListTime(model.expirationTime.format()), amount: model.amount.amountShortWithGroupSeparator(decimals: TokenInfo.BuildIn.vx.value.decimals))
            } , hasMore: $0.list.count >= type(of: self).limit) }
    }

    override func loadMore() -> Promise<(items: [DividendsVXUnlockListCellViewModel], hasMore: Bool)> {
        return ViteNode.dex.info.getDexVxUnlockList(address: address, index: items.count, count: type(of: self).limit)
            .map { (items: $0.list.map { model in
                DividendsVXUnlockListCellViewModel(time: R.string.localizable.dividendsPageUnlockListTime(model.expirationTime.format()), amount: model.amount.amountShortWithGroupSeparator(decimals: TokenInfo.BuildIn.vx.value.decimals))
            }, hasMore: $0.list.count >= type(of: self).limit) }
    }

    override func clicked(model: DividendsVXUnlockListCellViewModel) {

    }

    override func cellHeight(model: DividendsVXUnlockListCellViewModel) -> CGFloat {
        return DividendsVXUnlockListCell.cellHeight
    }

    override func cellFor(model: DividendsVXUnlockListCellViewModel, indexPath: IndexPath) -> UITableViewCell {
        let cell: DividendsVXUnlockListCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    }

    override func merge(items: [DividendsVXUnlockListCellViewModel]) {
        self.items.append(contentsOf: items)
    }
}
