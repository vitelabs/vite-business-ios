//
//  MiningInviteListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/3.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet

class MiningInviteListViewModel: ListViewModel<MiningInviteDetail.Trading> {
    static let limit = 100
    let address: ViteAddress

    let inviteDetailViewModelBehaviorRelay: BehaviorRelay<MiningInviteDetail?> = BehaviorRelay(value: nil)
    let totalViewModelBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    init(tableView: UITableView, address: ViteAddress) {
        self.address = address
        super.init(tableView: tableView)
        self.tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [MiningInviteDetail.Trading], hasMore: Bool)> {
        return UnifyProvider.vitex.getMiningInviteDetail(address: address, offset: 0, limit: type(of: self).limit)
            .map { [weak self] in
                self?.inviteDetailViewModelBehaviorRelay.accept($0)
                self?.totalViewModelBehaviorRelay.accept($0.total.tryToTruncation6Digits())
                return (items: $0.tradingList, hasMore: $0.tradingList.count >= MiningInviteListViewModel.limit)

        }
    }

    override func loadMore() -> Promise<(items: [MiningInviteDetail.Trading], hasMore: Bool)> {
        return UnifyProvider.vitex.getMiningInviteDetail(address: address, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0.tradingList, hasMore: $0.tradingList.count >= type(of: self).limit) }
    }

    override func clicked(model: MiningInviteDetail.Trading) {

    }

    override func cellHeight(model: MiningInviteDetail.Trading) -> CGFloat {
        return MiningItemCell.cellHeight
    }

    override func cellFor(model: MiningInviteDetail.Trading, indexPath: IndexPath) -> UITableViewCell {
        let cell: MiningItemCell = tableView.dequeueReusableCell(for: indexPath)
        let vm = MiningItemCellViewModel(
            left: "\(R.string.localizable.miningInvitePageCellFeeAmount()) \(model.feeAmount.tryToTruncation6Digits()) \(model.miningToken)",
            earnings: model.miningAmount.tryToTruncation6Digits(),
            symbol: "VX",
            date: model.date)
        cell.bind(vm)
        return cell
    }

    override func merge(items: [MiningInviteDetail.Trading]) {
        self.items.append(contentsOf: items)
    }
}
