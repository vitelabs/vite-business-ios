//
//  MyHomeListCellViewModel.swift
//  Vite
//
//  Created by Stone on 2018/11/6.
//  Copyright © 2018 vite labs. All rights reserved.
//

import UIKit
import ObjectMapper

class MyHomeListCellViewModel {

    enum ViewModelType {
        case settings
        case about
        case custom(title: String, image: UIImage?, url: String)
    }

    let title: String
    let image: UIImage?
    let url: String?
    let type: ViewModelType
    init(type: ViewModelType) {
        self.type = type
        switch type {
        case .settings:
            title = R.string.localizable.myPageSystemCellTitle()
            image = R.image.icon_setting()
            url = nil
        case .about:
            title = R.string.localizable.myPageAboutUsCellTitle()
            image = R.image.icon_token_vite()
            url = nil
        case let .custom(t, i, u):
            title = t
            image = i
            url = u
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
            guard let urlString = self.url else { return }
            if urlString == "https://growth.vite.net/invite" {
                Statistics.log(eventId: Statistics.Page.MyHome.inviteClicked.rawValue)
            } else if urlString == "https://forum.vite.net" {
                Statistics.log(eventId: Statistics.Page.MyHome.forumClicked.rawValue)
            }
            guard let url = URL(string: urlString) else { return }
            NavigatorManager.instance.route(url: url)
        }
    }
}
