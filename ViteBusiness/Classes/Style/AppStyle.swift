//
//  AppStyle.swift
//  Vite
//
//  Created by Water on 2018/9/5.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

// screen height
public let kScreenH = UIScreen.main.bounds.height
// screen width
public let kScreenW = UIScreen.main.bounds.width
//Adaptive iPhoneX
let kNavibarH: CGFloat = UIDevice.current.isIPhoneX() ? 88.0 : 64.0

extension UIDevice {
    public func isIPhoneX() -> Bool {
        if kScreenH == 812 {
            return true
        }
        return false
    }
    public func isIPhone6() -> Bool {
        if kScreenH == 667 {
            return true
        }
        return false
    }
    public func isIPhone6Plus() -> Bool {
        if kScreenH == 736 {
            return true
        }
        return false
    }
}
public struct Fonts {
    static let descFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let light14 = UIFont.systemFont(ofSize: 14, weight: .light)
    static let light16 = UIFont.systemFont(ofSize: 16, weight: .light)
    public static let Font12_r = UIFont.systemFont(ofSize: 12, weight: .regular)
    public static let Font12 = UIFont.systemFont(ofSize: 12, weight: .semibold)
    public static let Font13 = UIFont.systemFont(ofSize: 13, weight: .regular)
    public static let Font14 = UIFont.systemFont(ofSize: 14, weight: .regular)
    public static let Font14_b = UIFont.systemFont(ofSize: 14, weight: .semibold)
    public static let Font16_b = UIFont.systemFont(ofSize: 16, weight: .semibold)
    static let Font17 = UIFont.systemFont(ofSize: 17, weight: .semibold)
    static let Font18 = UIFont.systemFont(ofSize: 18, weight: .regular)
    public static let Font18_b = UIFont.systemFont(ofSize: 18, weight: .semibold)
    static let Font20 = UIFont.systemFont(ofSize: 20, weight: .semibold)
    static let Font24 = UIFont.systemFont(ofSize: 24, weight: .semibold)
}

func font(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size)
}

func boldFont(_ size: CGFloat) ->  UIFont {
    return UIFont.boldSystemFont(ofSize: size)
}

extension UITableView {
    static func listView() -> UITableView {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 24, bottom: 0, right: 22)
        return tableView
    }

    func set(empty: Bool) {
        let tag = 1163
        let emptyView = self.viewWithTag(tag)
        if empty && emptyView == nil {
            let view = UIView.defaultPlaceholderView(text: R.string.localizable.transactionListPageEmpty(), showImage: true)
            view.tag = tag
            self.addSubview(view)
            view.snp.makeConstraints { (m) in
                m.center.equalToSuperview()
            }
        } else if !empty && emptyView != nil {
            emptyView?.removeFromSuperview()
        }

    }
}

public enum AppStyle {
    case inputDescWord
    case descWord
    case heading
    case headingSemiBold
    case paragraph
    case paragraphLight
    case paragraphSmall
    case largeAmount
    case error
    case formHeader
    case collactablesHeader

    var font: UIFont {
        switch self {
        case .inputDescWord:
            return UIFont.systemFont(ofSize: 18, weight: .regular)
        case .descWord:
            return UIFont.systemFont(ofSize: 16, weight: .regular)
        case .heading:
            return UIFont.systemFont(ofSize: 18, weight: .regular)
        case .headingSemiBold:
            return UIFont.systemFont(ofSize: 18, weight: .semibold)
        case .paragraph:
            return UIFont.systemFont(ofSize: 15, weight: .regular)
        case .paragraphSmall:
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        case .paragraphLight:
            return UIFont.systemFont(ofSize: 15, weight: .light)
        case .largeAmount:
            return UIFont.systemFont(ofSize: 20, weight: .medium)
        case .error:
            return UIFont.systemFont(ofSize: 13, weight: .light)
        case .formHeader:
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        case .collactablesHeader:
            return UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.regular)
        }
    }

    var textColor: UIColor {
        switch self {
        case .heading, .headingSemiBold:
            return Colors.darkBlue
        case .paragraph, .paragraphLight, .paragraphSmall:
            return Colors.darkBlue
        case .largeAmount:
            return UIColor.black
        case .error:
            return Colors.darkBlue
        case .formHeader:
            return Colors.darkBlue
        case .collactablesHeader, .inputDescWord:
            return Colors.darkBlue
        case .descWord:
            return Colors.titleGray
        }
    }
}

extension CGFloat {
    static var singleLineWidth: CGFloat { return 1.0 / UIScreen.main.scale }
}
