//
//  Constants.swift
//  Vite
//
//  Created by Water on 2018/9/21.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation

public struct Constants {

    public enum Channel: String {
        case appstore
    }

    // support
    public static let supportEmail = "info@vite.org"
    //baidu  statistics
    public static let baiduMobileStat = "e74c7f32c0"
    //app channel
    public static let appDownloadChannel = Channel.appstore

    public static let IntroductionPageVersion = "3.0"

    public static let whiteList = ["vite.org",
                                   "vite.net",
                                   "vite.store",
                                   "vite.wiki",
                                   "vite.blog"]
}
