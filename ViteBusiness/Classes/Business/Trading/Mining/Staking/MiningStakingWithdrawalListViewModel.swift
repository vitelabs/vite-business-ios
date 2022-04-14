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

class MiningStakingWithdrawalListViewModel: ListViewModel<MiningStakingWithdrawalListCellViewModel> {
    static let limit = 50
    let address: ViteAddress


    init(tableView: UITableView, address: ViteAddress) {
        self.address = address
        super.init(tableView: tableView)
        self.tirggerRefresh()
    }
    
    override func refresh() -> Promise<(items: [MiningStakingWithdrawalListCellViewModel], hasMore: Bool)> {
        return ViteNode.dex.info.getDexMiningStakeInfo(address: address, index: 0, count: type(of: self).limit)
            .map { (items: $0.0.list.map { model in
                MiningStakingWithdrawalListCellViewModel(height: R.string.localizable.miningStakingPageWithdrawPageHeight("\(model.withdrawHeight)"), time: R.string.localizable.miningStakingPageWithdrawPageWithdrawTime(model.timestamp.format()), amount: model.amount.amountShortWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals), date: model.timestamp, id: model.id)
            } + $0.1.list.map { model in
                MiningStakingWithdrawalListCellViewModel(height: "", time: R.string.localizable.miningStakingPageWithdrawPageLockTime(model.expirationTime.format()), amount: model.amount.amountShortWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals), date: model.expirationTime, id: nil)
            }, hasMore: false) }
    }

    override func loadMore() -> Promise<(items: [MiningStakingWithdrawalListCellViewModel], hasMore: Bool)> {
        return ViteNode.dex.info.getDexMiningStakeInfo(address: address, index: items.count, count: type(of: self).limit)
            .map { _ in (items: [], hasMore: false) }
    }

    override func clicked(model: MiningStakingWithdrawalListCellViewModel) {

    }

    override func cellHeight(model: MiningStakingWithdrawalListCellViewModel) -> CGFloat {
        return MiningStakingWithdrawalListCell.cellHeight
    }

    override func cellFor(model: MiningStakingWithdrawalListCellViewModel, indexPath: IndexPath) -> UITableViewCell {
        let cell: MiningStakingWithdrawalListCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    }

    override func merge(items: [MiningStakingWithdrawalListCellViewModel]) {
        self.items.append(contentsOf: items)
    }
}
