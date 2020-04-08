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

class MarketInfoService: NSObject {

    static let shared = MarketInfoService()

    let marketSocket = MarketWebSocket()

    var operatorValue: [String: Any]?

    private var rateMap = [String: Double]()

    lazy var sortedMarketDataBehaviorRelay = { () -> BehaviorRelay<[MarketData]> in
        var orignialMarketData = [
            MarketData.init(categary: R.string.localizable.marketFavourite(), infos: []),
            MarketData.init(categary: "BTC", infos: []),
            MarketData.init(categary: "ETH", infos: []),
            MarketData.init(categary: "VITE", infos: []),
            MarketData.init(categary: "USDT", infos: []),
        ]
        return BehaviorRelay<[MarketData]>(value: orignialMarketData)
    }()

    func marketInfo(symbol: String) -> MarketInfo? {
        let infos = sortedMarketDataBehaviorRelay.value.flatMap { $0.infos }
        for info in infos where info.statistic.symbol == symbol {
            return info
        }
        return nil
    }

    var sortStatuses: [(SortStatus,SortStatus)] = Array<(SortStatus,SortStatus)>(repeating: (.normal, .normal), count: 5)

    override init() {
        self.favouriteBehaviorRelay = BehaviorRelay(value: MarketCache.readFavourite())
        super.init()

        marketSocket.onNewTickerStatistics = { statistic in
            let relay = self.sortedMarketDataBehaviorRelay.value
            for data in relay {
                for info in data.infos {
//                    if info.statistic.symbol == statistic.symbol,
//                        let new = try? info.statistic.getBuilder().mergeFrom(other:statistic).build(){
//                        info.statistic = new
//                    }
                    if info.statistic.symbol == statistic.symbol {
                        info.statistic = statistic
                    }
                }
            }
            self.sortedMarketDataBehaviorRelay.accept(relay)
        }

        NotificationCenter.default.rx.notification(.languageChanged).asObservable()
            .bind {[unowned self] _ in
                let values = self.sortedMarketDataBehaviorRelay.value
                values.first?.categary = R.string.localizable.marketFavourite()
                self.sortedMarketDataBehaviorRelay.accept(values)
        }.disposed(by: rx.disposeBag)

        readCaches()
        requestPageList()
        marketSocket.start()
    }


    //MARK: favourite
    let favouriteBehaviorRelay: BehaviorRelay<[String]>

    func isFavourite(symbol: String) -> Bool {
        favouriteBehaviorRelay.value.contains(symbol)
    }

    func addFavourite(symbol: String) {
        guard !isFavourite(symbol: symbol) else { return }
        var array = favouriteBehaviorRelay.value
        array.append(symbol)
        favouriteBehaviorRelay.accept(array)
        MarketCache.saveFavourites(favourites: array)
    }

    func removeFavourite(symbol: String) {
        guard isFavourite(symbol: symbol) else { return }
        var array = favouriteBehaviorRelay.value
        for (index, s) in array.enumerated() where s == symbol {
            array.remove(at: index)
            break
        }
        favouriteBehaviorRelay.accept(array)
        MarketCache.saveFavourites(favourites: array)
    }
}

extension MarketInfoService {

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

extension MarketInfoService {

    func requestPageList()  {
        let ticker = Alamofire
            .request( ViteConst.instance.market.vitexHost + "/api/v2/ticker/24hr",
                         parameters: ["quoteTokenCategory":"VITE,ETH,BTC,USDT"])
            .responseJSON()
            .map(on: .main) { data, response -> [[String: Any]] in
                return JSON(response.data)["data"].arrayObject as? [[String: Any]] ?? []
            }

        var tokenIDs = "tti_b90c9baffffc9dae58d1f33f,tti_687d8a93915393b219212c73,tti_5649544520544f4b454e6e40,tti_80f3751485e4e83456059473"
        #if DEBUG || TEST
           switch DebugService.instance.config.appEnvironment {
           case .test, .custom:
               tokenIDs = "tti_322862b3f8edae3b02b110b1,tti_06822f8d096ecdf9356b666c,tti_5649544520544f4b454e6e40,tti_973afc9ffd18c4679de42e93"
           case .stage, .online:
               break
           }
        #endif
        let rate = Alamofire
             .request(ViteConst.instance.market.vitexHost +  "/api/v1/exchange-rate",
                      parameters: ["tokenIds":tokenIDs])
            .responseJSON()
            .map(on: .main) { data, response -> [[String: Any]] in
                 return JSON(response.data)["data"].arrayObject as? [[String: Any]] ?? []
            }

        let mining = Promise<[String: Any]> { seal in
            Alamofire
            .request(ViteConst.instance.market.vitexHost + "/api/v1/mining/setting")
            .responseJSON()
            .map(on: .main) { (arg) -> [String: Any] in
                let (_, response) = arg
                return JSON(response.data)["data"].dictionaryObject as? [String: Any] ?? MarketCache.readMiningCache()
             }
            .done { (dict) in
                seal.fulfill(dict)
            }
            .catch { (e) in
                seal.fulfill(MarketCache.readMiningCache())
            }
        }

        when(fulfilled: ticker, rate, mining)
            .done { [weak self] t, r, m in
                MarketCache.saveTickerCache(data: t)
                MarketCache.saveRateCache(data: r)
                MarketCache.saveMiningCache(data: m)
                self?.loadOperatorIfNeeded()
                self?.handleData(t,r,m)
        }
        .catch { (e) in

        }

    }

    func readCaches()  {
        let t = MarketCache.readTickerCache()
        let r = MarketCache.readRateCache()
        let m = MarketCache.readMiningCache()
        handleData(t, r, m)
    }

    func legalPrice(quoteTokenSymbol: String, price: String) -> String {
        guard let rate = rateMap[quoteTokenSymbol] else { return "--" }
        return rateString(price: price, rate: rate, currency: AppSettingsService.instance.appSettings.currency)
    }

    func handleData(_ t: [[String: Any]], _ r: [[String: Any]], _ m: [String: Any])  {
        let tradeMiningSymbols = Set(m["tradeSymbols"] as? [String] ?? [])
        let orderMiningSymbols = Set(m["orderSymbols"] as? [String] ?? [])
        let bothMiningSymbols = tradeMiningSymbols.intersection(orderMiningSymbols)

        let marketDatas = [
            MarketData.init(categary: R.string.localizable.marketFavourite(), infos: []),
            MarketData.init(categary: "BTC", infos: []),
            MarketData.init(categary: "ETH", infos: []),
            MarketData.init(categary: "VITE", infos: []),
            MarketData.init(categary: "USDT", infos: []),
        ]

        let currency = AppSettingsService.instance.appSettings.currency
        var rateMap = [String: Double]()
        for i in r {
            guard let key = JSON(i)["tokenSymbol"].string else { return }
            if CurrencyCode.CNY == currency {
                rateMap[key] = JSON(i)["cnyRate"].double
            } else {
                rateMap[key] = JSON(i)["usdRate"].double
            }
        }
        self.rateMap = rateMap
        let favourite = MarketCache.readFavourite()
        for item in t {
            var i = item
            let json = JSON(i)["priceChangePercent"]
            i["priceChangePercent"] = json.string ?? String(json.double ?? 0)

            guard let statistic = TickerStatisticsProto(dict: i) else {
                continue
            }
            let info = MarketInfo()
            info.statistic = statistic

            if bothMiningSymbols.contains(statistic.symbol) {
                info.miningType = .both
            } else if tradeMiningSymbols.contains(statistic.symbol) {
                    info.miningType = .trade
            } else if orderMiningSymbols.contains(statistic.symbol) {
                info.miningType = .order
            } else {
                info.miningType = .none
            }

            if let rate = rateMap[info.statistic.quoteTokenSymbol] {
                info.rate = rateString(price: info.statistic.closePrice, rate: rate, currency: currency)
            }
            info.operatorName = self.operatorValue?[info.statistic.symbol] as? String ?? "--"

           let indexs = ["BTC-000": 1, "ETH-000": 2, "VITE":3, "USDT-000":4]
            if let index = indexs[statistic.quoteTokenSymbol] {
                marketDatas[index].infos.append(info)
            }
            if favourite.contains(statistic.symbol) {
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

    func loadOperatorIfNeeded() {
        if self.operatorValue != nil { return }
        let pairs = self.sortedMarketDataBehaviorRelay.value.dropFirst().reduce([]) { (result, marekData) -> [String] in
            let arr = marekData.infos.map { $0.statistic.symbol ?? "" }
            return result + arr
        }
        var request = URLRequest(url: URL.init(string: ViteConst.instance.market.vitexHost + "/api/v1/operator/tradepair")!)
       request.httpMethod = "POST"
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       let values = pairs
       request.httpBody = try! JSONSerialization.data(withJSONObject: values)

        let operate = Alamofire
            .request(request)
           .responseJSON()
           .map(on: .main) { (arg) -> [String: Any] in
               let (_, response) = arg
               return JSON(response.data)["data"].dictionaryObject as? [String: Any] ?? [:]
            }
        .done {
            self.operatorValue = $0.mapValues({ (json) -> String in
                return JSON(json)["name"].string ?? "--"
            })
            var relayValue = self.sortedMarketDataBehaviorRelay.value
            relayValue = relayValue.map { (data) -> MarketData in
                 data.infos = data.infos.map { info -> MarketInfo in
                    info.operatorName = self.operatorValue?[info.statistic.symbol] as? String ?? "--"
                    return info
                }
                return data
            }
            self.sortedMarketDataBehaviorRelay.accept(relayValue)
        }
    }
}

public class MarketInfo {

    enum MiningType {
        case none
        case trade
        case order
        case both
    }

    public var statistic: TickerStatisticsProto!
    var miningType: MiningType = .none
    var rate = ""
    var operatorName = "--"

    private(set) lazy var vitexURL: URL = {
        let tickerStatistics =  self.statistic!
        var url = ViteConst.instance.market.baseWebUrl + "#/index"
          url = url  + "?address=" + (HDWalletManager.instance.account?.address ?? "")
          url = url   + "&currency=" + AppSettingsService.instance.appSettings.currency.rawValue
          url = url   + "&lang=" + LocalizationService.sharedInstance.currentLanguage.rawValue
           url = url   + "&category=" + (tickerStatistics.quoteTokenSymbol.components(separatedBy: "-").first ?? "")
          url = url    + "&symbol=" + tickerStatistics.symbol
          url = url    + "&tradeTokenId=" + tickerStatistics.tradeToken
          url = url    + "&quoteTokenId=" + tickerStatistics.quoteToken

        return URL.init(string: url)!
    }()
}

extension MarketInfo {
    var miningImage: UIImage? {
        switch miningType {
            case .trade:
                return R.image.market_mining_trade()
            case .order:
                return R.image.market_mining_order()
            case .both:
                return R.image.market_mining_both()
            case .none:
                return nil
        }
    }

    var persentString: String {
        let priceChangePercent = Double(statistic.priceChangePercent)! * 100
        return (priceChangePercent >= 0.0 ? "+" : "-") + String(format: "%.2f", abs(priceChangePercent)) + "%"

    }

    var persentColor: UIColor {
        return Double(statistic.priceChangePercent)! >= 0.0 ? UIColor.init(netHex: 0x01D764) : UIColor.init(netHex: 0xE5494D)
    }
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

extension TickerStatisticsProto {
    init?(dict: [String: Any]) {
        self.init()

        guard let symbol = dict["symbol"] as? String,
            let tradeTokenSymbol = dict["tradeTokenSymbol"] as? String,
            let quoteTokenSymbol = dict["quoteTokenSymbol"] as? String,
            let tradeToken = dict["tradeToken"] as? String,
            let quoteToken = dict["quoteToken"] as? String,
            let openPrice = dict["openPrice"] as? String,
            let prevClosePrice = dict["prevClosePrice"] as? String,
            let closePrice = dict["closePrice"] as? String,
            let priceChange = dict["priceChange"] as? String,
            let priceChangePercent = dict["priceChangePercent"] as? String,
            let highPrice = dict["highPrice"] as? String,
            let lowPrice = dict["lowPrice"] as? String,
            let quantity = dict["quantity"] as? String,
            let amount = dict["amount"] as? String,
            let pricePrecision = dict["pricePrecision"] as? Int32,
            let quantityPrecision = dict["quantityPrecision"] as? Int32 else {
                return nil
        }

        self.symbol = symbol
        self.tradeTokenSymbol = tradeTokenSymbol
        self.quoteTokenSymbol = quoteTokenSymbol
        self.tradeToken = tradeToken
        self.quoteToken = quoteToken
        self.openPrice = openPrice
        self.prevClosePrice = prevClosePrice
        self.closePrice = closePrice
        self.priceChange = priceChange
        self.priceChangePercent = priceChangePercent
        self.highPrice = highPrice
        self.lowPrice = lowPrice
        self.quantity = quantity
        self.amount = amount
        self.pricePrecision = pricePrecision
        self.quantityPrecision = quantityPrecision
    }
}
