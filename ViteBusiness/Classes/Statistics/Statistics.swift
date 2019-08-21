//
//  Statistics.swift
//  Vite
//
//  Created by Stone on 2018/10/23.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import SwiftyJSON
import FirebaseAnalytics

public class Statistics: NSObject {

    private static let stat = ViteStatistics()

    public static func initializeConfig() {
        stat.channelId = Constants.appDownloadChannel.rawValue
        stat.shortAppVersion  =  Bundle.main.versionNumber
        stat.userId = stat.getDeviceCuid()
        stat.start(withAppId: Constants.baiduMobileStat)
    }

    public static func log(eventId: String, attributes: [String: String] = [:]) {
        #if DEBUG || TEST
        let toast: String
        if attributes.isEmpty {
            toast = "Statistics Event Start: \(eventId)"
        } else {
            if let data = try? JSONSerialization.data(withJSONObject: attributes, options: []),
                let str = String(data: data, encoding: String.Encoding.utf8) {
                toast = "Statistics Event Start: \(eventId)\nAttributes: \(str)"
            } else {
                toast = "Statistics Event Start: \(eventId)\nAttributes Invalid"
            }
        }

        plog(level: .debug, log: toast, tag: .statistics)

        if DebugService.instance.config.showStatisticsToast {
            Toast.show(toast)
        }

        if DebugService.instance.config.reportEventInDebug {
            if attributes.isEmpty {
                stat.logEvent(eventId, eventLabel: eventId)
                Analytics.logEvent(eventId, parameters: [:])
            } else {
                stat.logEvent(eventId, eventLabel: eventId, attributes: attributes)
                Analytics.logEvent(eventId, parameters: attributes)
            }
        }

        #else
        if attributes.isEmpty {
            stat.logEvent(eventId, eventLabel: eventId)
            Analytics.logEvent(eventId, parameters: [:])
        } else {
            stat.logEvent(eventId, eventLabel: eventId, attributes: attributes)
            Analytics.logEvent(eventId, parameters: attributes)
        }
        #endif

    }

    public static func pageviewStart(with name: String) {
        #if DEBUG || TEST
        if DebugService.instance.config.showStatisticsToast {
            Toast.show("Statistics Page Start: \(name)")
        }

        plog(level: .debug, log: "Statistics Page Start: \(name)", tag: .statistics)

        if DebugService.instance.config.reportEventInDebug {
            stat.pageviewStart(withName: name)
            stat.logEvent(name, eventLabel: name)
            Analytics.logEvent(AnalyticsEventViewItem,
                               parameters: [AnalyticsParameterItemID:name,
                                            AnalyticsParameterItemName: name,
                                            AnalyticsParameterItemCategory:name])
        }
        #else
        stat.pageviewStart(withName: name)
        stat.logEvent(name, eventLabel: name)
        Analytics.logEvent(AnalyticsEventViewItem,
                           parameters: [AnalyticsParameterItemID:name,
                                        AnalyticsParameterItemName: name,
                                        AnalyticsParameterItemCategory:name])
        #endif
    }

    public static func pageviewEnd(with name: String) {
        #if DEBUG || TEST
        if DebugService.instance.config.showStatisticsToast {
            Toast.show("Statistics Page End: \(name)")
        }

        plog(level: .debug, log: "Statistics Page End: \(name)", tag: .statistics)

        if DebugService.instance.config.reportEventInDebug {
            stat.pageviewEnd(withName: name)
        }
        #else
        stat.pageviewEnd(withName: name)
        #endif
    }
}
