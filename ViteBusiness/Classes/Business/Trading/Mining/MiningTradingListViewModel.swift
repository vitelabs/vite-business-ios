//
//  MiningTradingListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/2.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet

class MiningTradingListViewModel: ListViewModel<MiningTradeDetail.Trade> {
    static let limit = 50
    let address: ViteAddress

    let totalViewModelBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let miningTradingViewModelBehaviorRelay: BehaviorRelay<MiningTradingViewModel?> = BehaviorRelay(value: nil)

    init(tableView: UITableView, address: ViteAddress) {
        self.address = address
        super.init(tableView: tableView)
        self.tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [MiningTradeDetail.Trade], hasMore: Bool)> {
        fetch()
        return UnifyProvider.vitex.getMiningTradeDetail(address: address, offset: 0, limit: type(of: self).limit)
            .map { [weak self] in

                self?.totalViewModelBehaviorRelay.accept($0.miningTotal)
                return (items: $0.list, hasMore: $0.list.count >= MiningTradingListViewModel.limit)

        }
    }

    override func loadMore() -> Promise<(items: [MiningTradeDetail.Trade], hasMore: Bool)> {
        return UnifyProvider.vitex.getMiningTradeDetail(address: address, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0.list, hasMore: $0.list.count >= type(of: self).limit) }
    }

    override func clicked(model: MiningTradeDetail.Trade) {

    }

    override func cellHeight(model: MiningTradeDetail.Trade) -> CGFloat {
        return MiningTradingViewController.ItemCell.cellHeight
    }

    override func cellFor(model: MiningTradeDetail.Trade, indexPath: IndexPath) -> UITableViewCell {
        let cell: MiningTradingViewController.ItemCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    }

    override func merge(items: [MiningTradeDetail.Trade]) {
        self.items.append(contentsOf: items)
    }
}

extension MiningTradingListViewModel {
    func fetch() {
        ViteNode.dex.info.getDexTradingMiningInfo(address: address)
            .done { [weak self] (miningInfo, tradingMiningFeeInfo, addressFeeInfo) in
            self?.miningTradingViewModelBehaviorRelay.accept(MiningTradingViewModel(miningInfo: miningInfo, tradingMiningFeeInfo: tradingMiningFeeInfo, addressFeeInfo: addressFeeInfo))
        }.catch { (error) in

        }
    }
}



struct MiningTradingViewModel {

    let viteFee: String
    let viteEarnings: String

    let btcFee: String
    let btcEarnings: String

    let ethFee: String
    let ethEarnings: String

    let usdtFee: String
    let usdtEarnings: String

    init(miningInfo: DexMiningInfo, tradingMiningFeeInfo: DexTradingMiningFeeInfo, addressFeeInfo: DexAddressFeeInfo) {

        let placeholder = "0"

        if let base = addressFeeInfo.vite?.base {
            viteFee = base.amount(decimals: 18, count: 6, groupSeparator: true)
            viteEarnings = (miningInfo.feeMineVite * base / tradingMiningFeeInfo.vite).amount(decimals: 18, count: 6, groupSeparator: true)
        } else {
            viteFee = placeholder
            viteEarnings = placeholder
        }

        if let base = addressFeeInfo.btc?.base {
            btcFee = base.amount(decimals: 8, count: 6, groupSeparator: true)
            btcEarnings = (miningInfo.feeMineBtc * base / tradingMiningFeeInfo.btc).amount(decimals: 18, count: 6, groupSeparator: true)
        } else {
            btcFee = placeholder
            btcEarnings = placeholder
        }

        if let base = addressFeeInfo.eth?.base {
            ethFee = base.amount(decimals: 18, count: 6, groupSeparator: true)
            ethEarnings = (miningInfo.feeMineEth * base / tradingMiningFeeInfo.eth).amount(decimals: 18, count: 6, groupSeparator: true)
        } else {
            ethFee = placeholder
            ethEarnings = placeholder
        }

        if let base = addressFeeInfo.usdt?.base {
            usdtFee = base.amount(decimals: 6, count: 6, groupSeparator: true)
            usdtEarnings = (miningInfo.feeMineUsdt * base / tradingMiningFeeInfo.usdt).amount(decimals: 18, count: 6, groupSeparator: true)
        } else {
            usdtFee = placeholder
            usdtEarnings = placeholder
        }
    }
}
