//
//  MyDeFiSubscribeListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import Foundation
import PromiseKit
import RxSwift
import RxCocoa

class MyDeFiSubscribeListViewModel: ListViewModel<DeFiSubscription> {

    static let limit = 20
    let address = HDWalletManager.instance.account!.address
    lazy var profitsDriver: Driver<DeFiProfits> = self.profitsBehaviorRelay.asDriver().filterNil()
    private let profitsBehaviorRelay: BehaviorRelay<DeFiProfits?> = BehaviorRelay(value: nil)

    let status: DeFiAPI.ProductStatus
    init(tableView: UITableView, status: DeFiAPI.ProductStatus) {
        self.status = status
        super.init(tableView: tableView)
        tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [DeFiSubscription], hasMore: Bool)> {
        if let address = HDWalletManager.instance.account?.address {
            UnifyProvider.defi.getDefiProfits(address: address).done { [weak self] (profits) in
                self?.profitsBehaviorRelay.accept(profits)
            }.cauterize()
        }
        return UnifyProvider.defi.getMySubscriptions(status: status, address: address, offset: 0, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func loadMore() -> Promise<(items: [DeFiSubscription], hasMore: Bool)> {
        return UnifyProvider.defi.getMySubscriptions(status: status, address: address, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func clicked(model: DeFiSubscription) {
        let vc = DeFiSubscriptionDetailViewController.init(productHash: model.productHash)
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
    }

    override func cellHeight(model: DeFiSubscription) -> CGFloat {
        return MyDeFiSubscribeCell.cellHeight
    }

    override func cellFor(model: DeFiSubscription, indexPath: IndexPath) -> UITableViewCell {
        let cell: MyDeFiSubscribeCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    }
}
