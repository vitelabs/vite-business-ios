//
//  DividendsListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/3.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet

class DividendsListViewModel: ListViewModel<DexDividendDetail.Info> {
    static let limit = 100
    let address: ViteAddress
    
    let totalDividendInfoModelBehaviorRelay: BehaviorRelay<DexDividendInfo?> = BehaviorRelay(value: nil)
    let myDividendInfoModelBehaviorRelay: BehaviorRelay<DexDividendInfo?> = BehaviorRelay(value: nil)
    let isAutoLockMinedVxModelBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    init(tableView: UITableView, address: ViteAddress) {
        self.address = address
        super.init(tableView: tableView)
        self.tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [DexDividendDetail.Info], hasMore: Bool)> {
        fetch()
        return UnifyProvider.vitex.getDexdividend(address: address, offset: 0, limit: type(of: self).limit)
            .map { [weak self] in
                self?.myDividendInfoModelBehaviorRelay.accept($0.myDexDividendInfo)
                return (items: $0.list, hasMore: $0.list.count >= MiningInviteListViewModel.limit)

        }
    }

    override func loadMore() -> Promise<(items: [DexDividendDetail.Info], hasMore: Bool)> {
        return UnifyProvider.vitex.getDexdividend(address: address, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0.list, hasMore: $0.list.count >= type(of: self).limit) }
    }

    override func clicked(model: DexDividendDetail.Info) {

    }

    override func cellHeight(model: DexDividendDetail.Info) -> CGFloat {
        return DividendsItemCell.cellHeight
    }

    override func cellFor(model: DexDividendDetail.Info, indexPath: IndexPath) -> UITableViewCell {
        let cell: DividendsItemCell = tableView.dequeueReusableCell(for: indexPath)
        let (_, price) = model.dividendInfo.totalBtcAndPriceStrig()
        let total = "\(R.string.localizable.dividendsPageLockCellTotal()) \(price)"
        let vm = DividendsItemCellViewModel(vx: model.vxQuantity.tryToTruncationDigits(2), btc: model.dividendInfo.btcString, eth: model.dividendInfo.ethString, usdt: model.dividendInfo.usdtString, price: price, date: model.date)
        cell.bind(vm)
        return cell
    }

    override func merge(items: [DexDividendDetail.Info]) {
        self.items.append(contentsOf: items)
    }
}

extension DividendsListViewModel {
    func fetch() {
        ViteNode.dex.info.getDexDividendPoolsInfoRequest()
            .done { [weak self] info in
            self?.totalDividendInfoModelBehaviorRelay.accept(info)
        }.catch { (error) in

        }
        
        ViteNode.dex.info.getDexIsAutoLockMinedVx(address: address)
            .done { [weak self] info in
            self?.isAutoLockMinedVxModelBehaviorRelay.accept(info)
        }.catch { (error) in

        }
    }
}
