//
//  BalanceInfoDetailTableViewDelegate.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/8.
//

import Foundation

public protocol BalanceInfoDetailTableViewDelegate: class {
    init(tokenInfo: TokenInfo, tableViewHandler: TableViewHandler)

    func getMore(finished: @escaping (Error?) -> ())
    func refresh(finished: @escaping (Error?) -> ())

    var emptyTipView: UIView { get }
    var networkErrorTipView: UIView { get }
}

public extension BalanceInfoDetailTableViewDelegate {

    func getMore(finished: @escaping (Error?) -> ()) { }
    func refresh(finished: @escaping (Error?) -> ()) { }
    var emptyTipView: UIView { return UIView() }
    var networkErrorTipView: UIView {  return UIView() }

    func generateSectionHeaderView(title: String) -> UIView {
        let view = UIView()
        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.numberOfLines = 1
        }

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(16)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }

        titleLabel.text = title
        return view
    }

    var sectionHeaderViewHeight: CGFloat {
        return 38
    }
}
