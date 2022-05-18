//
//  MiningMakingListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/3.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet

class MiningMakingListViewModel: ListViewModel<MiningOrderDetail.MarketMaking> {
    static let limit = 100
    let address: ViteAddress
    
    let estimateViewModelBehaviorRelay: BehaviorRelay<MiningOrderDetail.Estimate?> = BehaviorRelay(value: nil)
    let totalViewModelBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    init(tableView: UITableView, address: ViteAddress) {
        self.address = address
        super.init(tableView: tableView)
        self.tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [MiningOrderDetail.MarketMaking], hasMore: Bool)> {
        return UnifyProvider.vitex.getMiningOrderDetail(address: address, offset: 0, limit: type(of: self).limit)
            .map { [weak self] in
                self?.estimateViewModelBehaviorRelay.accept($0.1)
                self?.totalViewModelBehaviorRelay.accept($0.0.miningTotal.tryToTruncation6Digits())
                return (items: $0.0.miningList, hasMore: $0.0.miningList.count >= MiningInviteListViewModel.limit)

        }
    }

    override func loadMore() -> Promise<(items: [MiningOrderDetail.MarketMaking], hasMore: Bool)> {
        return UnifyProvider.vitex.getMiningOrderDetail(address: address, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0.0.miningList, hasMore: $0.0.miningList.count >= type(of: self).limit) }
    }

    override func clicked(model: MiningOrderDetail.MarketMaking) {

    }

    override func cellHeight(model: MiningOrderDetail.MarketMaking) -> CGFloat {
        return MiningItemCell.cellHeight
    }

    override func cellFor(model: MiningOrderDetail.MarketMaking, indexPath: IndexPath) -> UITableViewCell {
        let cell: MiningItemCell = tableView.dequeueReusableCell(for: indexPath)
        let vm = MiningItemCellViewModel(
            left: "\(R.string.localizable.miningInvitePageCellPer()) \(model.miningRatio.tryToTruncation6Digits())%",
            earnings: model.miningAmount.tryToTruncation6Digits(),
            symbol: "VX",
            date: model.date)
        cell.bind(vm)
        return cell
    }

    override func merge(items: [MiningOrderDetail.MarketMaking]) {
        self.items.append(contentsOf: items)
    }
}
