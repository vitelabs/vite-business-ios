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
