//
//  MiningOrderInviteListViewModel.swift
//  ViteBusiness
//
//  Created by vite on 2022/4/19.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet

class MiningOrderInviteListViewModel: ListViewModel<MiningInviteDetail.MarketMaking> {
    static let limit = 100
    let address: ViteAddress
    
    let inviteDetailViewModelBehaviorRelay: BehaviorRelay<MiningInviteDetail?> = BehaviorRelay(value: nil)
    let totalViewModelBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    init(tableView: UITableView, address: ViteAddress, detail: MiningInviteDetail) {
        self.address = address
        super.init(tableView: tableView)
        self.items = detail.marketMakingList
        self.inviteDetailViewModelBehaviorRelay.accept(detail)
        self.totalViewModelBehaviorRelay.accept(detail.total.tryToTruncation6Digits())
    }

    override func refresh() -> Promise<(items: [MiningInviteDetail.MarketMaking], hasMore: Bool)> {
        return UnifyProvider.vitex.getMiningInviteDetail(address: address, offset: 0, limit: type(of: self).limit)
            .map { [weak self] in
                self?.inviteDetailViewModelBehaviorRelay.accept($0)
                self?.totalViewModelBehaviorRelay.accept($0.total.tryToTruncation6Digits())
                return (items: $0.marketMakingList, hasMore: $0.marketMakingList.count >= MiningInviteListViewModel.limit)

        }
    }

    override func loadMore() -> Promise<(items: [MiningInviteDetail.MarketMaking], hasMore: Bool)> {
        return UnifyProvider.vitex.getMiningInviteDetail(address: address, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0.marketMakingList, hasMore: $0.marketMakingList.count >= type(of: self).limit) }
    }

    override func clicked(model: MiningInviteDetail.MarketMaking) {

    }

    override func cellHeight(model: MiningInviteDetail.MarketMaking) -> CGFloat {
        return MiningItemCell.cellHeight
    }

    override func cellFor(model: MiningInviteDetail.MarketMaking, indexPath: IndexPath) -> UITableViewCell {
        let cell: MiningItemCell = tableView.dequeueReusableCell(for: indexPath)
        let vm = MiningItemCellViewModel(
            left: "\(R.string.localizable.miningInvitePageCellPer()) \(model.miningPercent.tryToTruncation6Digits())%",
            earnings: model.miningAmount.tryToTruncation6Digits(),
            symbol: "VX",
            date: model.date)
        cell.bind(vm)
        return cell
    }

    override func merge(items: [MiningInviteDetail.MarketMaking]) {
        self.items.append(contentsOf: items)
    }
}
