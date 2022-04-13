//
//  MiningStakingListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/3.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet

class MiningStakingListViewModel: ListViewModel<MiningPledgeDetail.Pledge> {
    static let limit = 50
    let address: ViteAddress

    let totalViewModelBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let miningStakeInfoViewModelBehaviorRelay: BehaviorRelay<(DexMiningStakeInfo, DexMiningStakeInfo)?> = BehaviorRelay(value: nil)

    init(tableView: UITableView, address: ViteAddress) {
        self.address = address
        super.init(tableView: tableView)
        self.tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [MiningPledgeDetail.Pledge], hasMore: Bool)> {
        fetch()
        return UnifyProvider.vitex.getMiningTradePledge(address: address, offset: 0, limit: type(of: self).limit)
            .map { [weak self] in
                self?.totalViewModelBehaviorRelay.accept($0.miningTotal.tryToTruncation6Digits())
                return (items: $0.list, hasMore: $0.list.count >= MiningStakingListViewModel.limit)

        }
    }

    override func loadMore() -> Promise<(items: [MiningPledgeDetail.Pledge], hasMore: Bool)> {
        return UnifyProvider.vitex.getMiningTradePledge(address: address, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0.list, hasMore: $0.list.count >= type(of: self).limit) }
    }

    override func clicked(model: MiningPledgeDetail.Pledge) {

    }

    override func cellHeight(model: MiningPledgeDetail.Pledge) -> CGFloat {
        return MiningItemCell.cellHeight
    }

    override func cellFor(model: MiningPledgeDetail.Pledge, indexPath: IndexPath) -> UITableViewCell {
        let cell: MiningItemCell = tableView.dequeueReusableCell(for: indexPath)
        let vm = MiningItemCellViewModel(
            left: "\(R.string.localizable.miningStakingPageCellAmount()) \(model.pledgeAmount.tryToTruncation6Digits()) \(model.miningToken)",
            earnings: model.miningAmount.tryToTruncation6Digits(),
            symbol: "VX",
            date: model.date)
        cell.bind(vm)
        return cell
    }

    override func merge(items: [MiningPledgeDetail.Pledge]) {
        self.items.append(contentsOf: items)
    }
}

extension MiningStakingListViewModel {
    func fetch() {
        ViteNode.dex.info.getDexMiningStakeInfo(address: address, index: 0, count: 0)
            .done { [weak self] info in
            self?.miningStakeInfoViewModelBehaviorRelay.accept(info)
        }.catch { (error) in

        }
    }
}
