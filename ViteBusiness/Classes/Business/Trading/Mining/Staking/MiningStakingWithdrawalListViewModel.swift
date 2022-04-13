//
//  MiningStakingWithdrawalListViewModel.swift
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

class MiningStakingWithdrawalListViewModel: ListViewModel<Pledge> {
    static let limit = 50
    let address: ViteAddress


    init(tableView: UITableView, address: ViteAddress) {
        self.address = address
        super.init(tableView: tableView)
        self.tirggerRefresh()
    }
    
    override func refresh() -> Promise<(items: [Pledge], hasMore: Bool)> {
        return ViteNode.dex.info.getDexMiningStakeInfo(address: address, index: 0, count: type(of: self).limit)
            .map { (items: $0.0.list + $0.1.list, hasMore: false) }
    }

    override func loadMore() -> Promise<(items: [Pledge], hasMore: Bool)> {
        return ViteNode.dex.info.getDexMiningStakeInfo(address: address, index: items.count, count: type(of: self).limit)
            .map { (items: $0.0.list, hasMore: $0.0.list.count >= type(of: self).limit) }
    }

    override func clicked(model: Pledge) {

    }

    override func cellHeight(model: Pledge) -> CGFloat {
        return MiningStakingWithdrawalListCell.cellHeight
    }

    override func cellFor(model: Pledge, indexPath: IndexPath) -> UITableViewCell {
        let cell: MiningStakingWithdrawalListCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(MiningStakingWithdrawalListCellViewModel(height: "\(model.withdrawHeight)", time: model.timestamp.format(), amount: model.amount.amountShortWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals), date: model.timestamp))
        return cell
    }

    override func merge(items: [Pledge]) {
        self.items.append(contentsOf: items)
    }
}
