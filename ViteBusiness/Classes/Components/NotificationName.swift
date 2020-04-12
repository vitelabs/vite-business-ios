//
//  NotificationName.swift
//  Vite
//
//  Created by Water on 2018/9/5.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation

extension Notification.Name {
    // Need to update UI
    public static let languageChanged = NSNotification.Name(rawValue: "Vite_APPLanguageChanged")
    public static let languageChangedInSetting = NSNotification.Name(rawValue: "Vite_APPLanguageChangedInSetting")

    public static let goTradingPage = NSNotification.Name(rawValue: "Vite_GoTradingPage")

    // account
    public static let createAccountSuccess = NSNotification.Name(rawValue: "Vite_createAccountSuccess")
    public static let logoutDidFinish = NSNotification.Name(rawValue: "Vite_logoutDidFinish")
    public static let loginDidFinish = NSNotification.Name(rawValue: "Vite_loginDidFinish")
    public static let unlockDidSuccess = NSNotification.Name(rawValue: "Vite_unlockDidSuccess")

    public static let finishShowIntroPage = NSNotification.Name(rawValue: "Vite_finishShowIntroPage")
    public static let userDidVote = NSNotification.Name(rawValue: "Vite_userDidVote")
    public static let userVoteInfoChange = NSNotification.Name(rawValue: "Vite_userVoteInfoChange")

    public static let homePageDidAppear = NSNotification.Name(rawValue: "Vite_homePageDidAppear")

    public static let goTokenInfoVC = NSNotification.Name(rawValue: "goTokenInfoVC")
    public static let goGateWayVC = NSNotification.Name(rawValue: "goGateWayVC")
}
