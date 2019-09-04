//
//  MyHomeListCellViewModel.swift
//  Vite
//
//  Created by Stone on 2018/11/6.
//  Copyright © 2018 vite labs. All rights reserved.
//

import UIKit
import ObjectMapper

class MyHomeListCellViewModel: Mappable {

    enum ViewModelType: String {
        case settings
        case about
        case custom
    }

    var type: ViewModelType = .custom
    fileprivate var title: StringWrapper = StringWrapper(string: "")
    fileprivate var icon: String = ""
    var url: String = ""
    fileprivate var build: Int?

    fileprivate(set) var name: StringWrapper = StringWrapper(string: "")
    fileprivate(set) var image: ImageWrapper?

    var isValid: Bool {
        if let current = Int(Bundle.main.buildNumber),
            let build = build {
            return current >= build
        } else {
            return true
        }
    }

    required init?(map: Map) {
        guard let type = map.JSON["type"] as? String, let _ = ViewModelType(rawValue: type) else {
            return nil
        }
    }

    func mapping(map: Map) {
        type <- map["type"]
        title <- map["title"]
        icon <- map["icon"]
        url <- map["url"]
        build <- map["build"]

        switch type {
        case .settings:
            name = StringWrapper(string: R.string.localizable.myPageSystemCellTitle())
            image = ImageWrapper.image(image: R.image.icon_setting()!)
        case .about:
            name = StringWrapper(string: R.string.localizable.myPageAboutUsCellTitle())
            image = ImageWrapper.image(image: R.image.icon_token_vite()!)
        case .custom:
            name = title
            image = ImageWrapper.url(url: URL(string: icon)!)
        }
    }

    func clicked(viewController: UIViewController) {
        switch type {
        case .settings:
            Statistics.log(eventId: Statistics.Page.MyHome.settingClicked.rawValue)
            let vc = SystemViewController()
            viewController.navigationController?.pushViewController(vc, animated: true)
        case .about:
            Statistics.log(eventId: Statistics.Page.MyHome.aboutClicked.rawValue)
            let vc = AboutUsViewController()
            viewController.navigationController?.pushViewController(vc, animated: true)
        case .custom:
            if url == "https://growth.vite.net/invite" {
                Statistics.log(eventId: Statistics.Page.MyHome.inviteClicked.rawValue)
            } else if url == "https://forum.vite.net" {
                Statistics.log(eventId: Statistics.Page.MyHome.forumClicked.rawValue)
            }
            guard let url = URL(string: url) else { return }
            let webvc = WKWebViewController(url: WebHandler.appendQuery(url: url))
            UIViewController.current?.navigationController?.pushViewController(webvc, animated: true)
        }
    }
}
