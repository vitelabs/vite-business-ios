//
//  MarketInfoVM.swift
//  Action
//
//  Created by haoshenyang on 2019/10/10.
//

import UIKit
import SwiftyJSON
import RxSwift
import RxCocoa
import Alamofire
import PromiseKit

enum SortStatus: Int {
    case normal = 0
    case ascending = 1
    case descending = 2
}

class MarketInfoVM: NSObject {

    let marketSocket = MarketWebSocket()

    lazy var sortedMarketDataBehaviorRelay = { () -> BehaviorRelay<[MarketData]> in
        var orignialMarketData = [
            MarketData.init(categary: "自选", infos: []),
            MarketData.init(categary: "BTC", infos: []),
            MarketData.init(categary: "ETH", infos: []),
            MarketData.init(categary: "VITE", infos: []),
            MarketData.init(categary: "USDT", infos: []),
        ]
        return BehaviorRelay<[MarketData]>(value: orignialMarketData)
    }()

    var sortStatuses: [(SortStatus,SortStatus)] = Array<(SortStatus,SortStatus)>(repeating: (.normal, .normal), count: 5)

    override init() {
        super.init()

        marketSocket.onNewTickerStatistics = { statistic in
            print(statistic)
            let relay = self.sortedMarketDataBehaviorRelay.value
            for data in relay {
                for info in data.infos {
                    if info.statistic.symbol == statistic.symbol,
                        let new = try? info.statistic.getBuilder().mergeFrom(other:statistic).build(){
                        info.statistic = new
                    }
                }
            }
            self.sortedMarketDataBehaviorRelay.accept(relay)
        }
        readCaches()
        requestPageList()
        marketSocket.start()
    }

}

extension MarketInfoVM {

    func sortByPrice(index: Int) {
        sortStatuses[index].1 = .normal
        sortStatuses[index].0 = SortStatus.init(rawValue: (sortStatuses[index].0.rawValue + 1) % 3)!
        let sorted = self.sortedMarketDatas(sortedMarketDataBehaviorRelay.value)
        sortedMarketDataBehaviorRelay.accept(sorted)
    }

    func sortByPercent(index: Int) {
        sortStatuses[index].0 = .normal
        sortStatuses[index].1 = SortStatus.init(rawValue: (sortStatuses[index].1.rawValue + 1) % 3)!
        let sorted = self.sortedMarketDatas(sortedMarketDataBehaviorRelay.value)
        sortedMarketDataBehaviorRelay.accept(sorted)
    }

    func sortedMarketDatas(_ datas:[MarketData]) -> [MarketData] {
        for (index, data) in datas.enumerated() {
            let config = sortStatuses[index]
            data.sortStatus = config
            if config.0 == .normal && config.1 == .normal {
                datas[index].infos = datas[index].infos.sorted(by: { (info0, info1) -> Bool in
                    let p0 = Double(info0.statistic.amount ?? "") ?? 0
                    let p1 = Double(info1.statistic.amount ?? "") ?? 0
                    return p0 > p1
                })
            } else if config.0 != .normal{
                datas[index].infos = datas[index].infos.sorted(by: { (info0, info1) -> Bool in
                    let p0 = Double(info0.statistic.closePrice) ?? 0
                    let p1 = Double(info1.statistic.closePrice) ?? 0
                    if config.0 == .ascending {
                        return p0 > p1
                    } else {
                        return p0 < p1
                    }
                })
            } else  if config.1 != .normal{
                datas[index].infos = datas[index].infos.sorted(by: { (info0, info1) -> Bool in
                    let p0 = Double(info0.statistic.priceChangePercent) ?? 0
                    let p1 = Double(info1.statistic.priceChangePercent) ?? 0
                    if config.1 == .ascending {
                        return p0 > p1
                    } else {
                        return p0 < p1
                    }
                })
            }
        }
        return datas
    }

}

extension MarketInfoVM {

    func requestPageList()  {
        let ticker = Alamofire
            .request( ViteConst.instance.market.vitexHost + "/api/v1/ticker/24hr",
                         parameters: ["quoteTokenCategory":"VITE,ETH,BTC,USDT"])
            .responseJSON()
            .map(on: .main) { data, response -> [[String: Any]] in
                return JSON(response.data)["data"].arrayObject as? [[String: Any]] ?? []
            }

        let rate = Alamofire
             .request(ViteConst.instance.market.vitexHost +  "/api/v1/exchange-rate",
                      parameters: ["tokenIds":"tti_b90c9baffffc9dae58d1f33f,tti_687d8a93915393b219212c73,tti_5649544520544f4b454e6e40,tti_80f3751485e4e83456059473"])
            .responseJSON()
            .map(on: .main) { data, response -> [[String: Any]] in
                 return JSON(response.data)["data"].arrayObject as? [[String: Any]] ?? []
            }

        let mining = Alamofire
            .request(ViteConst.instance.market.vitexHost + "/api/v1/mining/setting")
            .responseJSON()
            .map(on: .main) { (arg) -> [String: Any] in
                let (_, response) = arg
                return JSON(response.data)["data"].dictionaryObject as? [String: Any] ?? [:]
             }

        when(fulfilled: ticker, rate, mining)
            .done { [weak self] t, r, m in
                MarketCache.saveTickerCache(data: t)
                MarketCache.saveRateCache(data: r)
                MarketCache.saveMiningCache(data: m)
                self?.handleData(t,r,m)
        }
    }

    func readCaches()  {
        let t = MarketCache.readTickerCache()
        let r = MarketCache.readRateCache()
        let m = MarketCache.readMiningCache()
        handleData(t, r, m)
    }

    func handleData(_ t: [[String: Any]], _ r: [[String: Any]], _ m: [String: Any])  {
        let tradeMiningSymbols = m["tradeSymbols"] as? [String] ?? []
        let orderMiningSymbols = m["orderSymbols"] as? [String] ?? []
        let miningSymbols = tradeMiningSymbols + orderMiningSymbols

        let marketDatas = [
            MarketData.init(categary: "自选", infos: []),
            MarketData.init(categary: "BTC", infos: []),
            MarketData.init(categary: "ETH", infos: []),
            MarketData.init(categary: "VITE", infos: []),
            MarketData.init(categary: "USDT", infos: []),
        ]

        let currency = AppSettingsService.instance.currencyBehaviorRelay.value?.value
        var rateMap = [String: Double]()
        for i in r {
            guard let key = JSON(i)["tokenSymbol"].string else { return }
            if CurrencyCode.CNY == currency {
                rateMap[key] = JSON(i)["cnyRate"].double
            } else {
                rateMap[key] = JSON(i)["usdRate"].double
            }
        }

        let favourite = MarketCache.readFavourite()
        for item in t {
            var i = item
            let json = JSON(i)["priceChangePercent"]
            i["priceChangePercent"] = json.string ?? (String(json.double ?? 0) ?? "0")
            guard let statistic = try? Protocol.TickerStatisticsProto.decode(jsonMap: i) else {
                continue
            }
            let info = MarketInfo()
            info.statistic = statistic
            info.mining = miningSymbols.contains { $0 == statistic.symbol }

            if let rate = rateMap[info.statistic.quoteTokenSymbol] {
                info.rate = rateString(price: info.statistic.closePrice, rate: rate, currency: currency)
            }

           let indexs = ["BTC-000": 1, "ETH-000": 2, "VITE":3, "USDT-000":4]
            if statistic.hasQuoteTokenSymbol, let index = indexs[statistic.quoteTokenSymbol] {
                marketDatas[index].infos.append(info)
            }
            if favourite.contains(statistic.symbol ?? "") {
                marketDatas[0].infos.append(info)
            }
        }

        let sorted = sortedMarketDatas(marketDatas)
        sortedMarketDataBehaviorRelay.accept(sorted)
    }

    func rateString(price: String?, rate:Double?, currency: CurrencyCode?) -> String {
        guard let price = Double(price ?? "0"),
            let rate = rate else { return "" }
        let currencySymble = currency?.symbol ?? ""
        let money = price * rate
        return String(format: "\(currencySymble)%.6f", money)
    }
}

class MarketInfo {
    var statistic: Protocol.TickerStatisticsProto!
    var mining: Bool = false
    var rate = ""

    private(set) lazy var vitexURL: URL = {
        let tickerStatistics =  self.statistic!
        var url = ViteConst.instance.market.baseWebUrl + "#/index"
              url = url  + "?address=" + (HDWalletManager.instance.account?.address ?? "")
              url = url   + "&currency=" + AppSettingsService.instance.currencyBehaviorRelay.value.rawValue
              url = url   + "&lang=" + LocalizationService.sharedInstance.currentLanguage.rawValue
               url = url   + "&category=" + (tickerStatistics.quoteTokenSymbol.components(separatedBy: "-").first ?? "")
              url = url    + "&symbol=" + tickerStatistics.symbol
              url = url    + "&tradeTokenId=" + tickerStatistics.tradeToken
              url = url    + "&quoteTokenId=" + tickerStatistics.quoteToken

        return URL.init(string: url)!
    }()
}

class MarketData {
    init(categary: String,infos: [MarketInfo]) {
        self.categary = categary
        self.infos = infos
    }
    var categary = ""
    var infos = [MarketInfo]()
    var sortStatus = (SortStatus.normal, SortStatus.normal)
}
