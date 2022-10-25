//
//  BalanceInfoDetailAdapter.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import Foundation

protocol BalanceInfoDetailAdapter {
    init(tokenInfo: TokenInfo, headerView: UIStackView, tableView: UITableView, vc: UIViewController?)
    var delegate: BalanceInfoDetailTableViewDelegate? { get }
    func viewDidAppear()
    func viewDidDisappear()
}

extension BalanceInfoDetailAdapter {

    init(tokenInfo: TokenInfo, headerView: UIStackView, tableView: UITableView) {
        fatalError()
    }

    var delegate: BalanceInfoDetailTableViewDelegate? {
        fatalError()
    }
}

extension TokenInfo {
    func createBalanceInfoDetailAdapter(headerView: UIStackView, tableView: UITableView, vc: UIViewController? = nil) -> BalanceInfoDetailAdapter {
        switch coinType {
        case .vite:
            if isViteCoin {
                return BalanceInfoDetailViteCoinAdapter(tokenInfo: self, headerView: headerView, tableView: tableView)
            } else if isGateway {
                return BalanceInfoDetailGatewayTokenAdapter(tokenInfo: self, headerView: headerView, tableView: tableView)
            } else {
                return BalanceInfoDetailViteTokenAdapter(tokenInfo: self, headerView: headerView, tableView: tableView)
            }
        case .unsupport:
            fatalError()
        }
    }
}
