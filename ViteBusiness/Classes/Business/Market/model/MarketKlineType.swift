//
//  MarketKlineType.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/17.
//

import Foundation

enum MarketKlineType: CaseIterable {
    case min1
    case min30
    case hour1
    case hour6
    case hour12
    case day1
    case week1

    var timeFormat: String {
        switch self {
        case .min1: return "HH:mm"
        case .min30: return "HH:mm"
        case .hour1: return "MM.dd HH"
        case .hour6: return "MM.dd HH"
        case .hour12: return "MM.dd HH"
        case .day1: return "yyyy.MM.dd"
        case .week1: return "yyyy.MM.dd"
        }
    }

    func calcRequestStartTime(end: TimeInterval, limit: Int) -> TimeInterval {
        let interval: TimeInterval
        switch self {
        case .min1: interval = 60
        case .min30: interval = 60 * 30
        case .hour1: interval = 60 * 60
        case .hour6: interval = 60 * 60 * 6
        case .hour12: interval = 60 * 60 * 12
        case .day1: interval = 60 * 60 * 24
        case .week1: interval = 60 * 60 * 24 * 7
        }
        return max(0, end - TimeInterval(limit) * interval)
    }

    var text: String {
        switch self {
        case .min1: return R.string.localizable.marketDetailPageKlineTypeMin1Title()
        case .min30: return R.string.localizable.marketDetailPageKlineTypeMin30Title()
        case .hour1: return R.string.localizable.marketDetailPageKlineTypeHour1Title()
        case .hour6: return R.string.localizable.marketDetailPageKlineTypeHour6Title()
        case .hour12: return R.string.localizable.marketDetailPageKlineTypeHour12Title()
        case .day1: return R.string.localizable.marketDetailPageKlineTypeDay1Title()
        case .week1: return R.string.localizable.marketDetailPageKlineTypeWeek1Title()
        }
    }

    var requestParameter: String {
        switch self {
        case .min1: return "minute"
        case .min30: return "minute30"
        case .hour1: return "hour"
        case .hour6: return "hour6"
        case .hour12: return "hour12"
        case .day1: return "day"
        case .week1: return "week"
        }
    }

    func topic(symbol: String) -> String {
        switch self {
        case .min1: return "market.\(symbol).kline.minute"
        case .min30: return "market.\(symbol).kline.minute30"
        case .hour1: return "market.\(symbol).kline.hour"
        case .hour6: return "market.\(symbol).kline.hour6"
        case .hour12: return "market.\(symbol).kline.hour12"
        case .day1: return "market.\(symbol).kline.day"
        case .week1: return "market.\(symbol).kline.week"
        }
    }
}
