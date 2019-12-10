//
//  TableViewHandler.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/8.
//

import Foundation

public class TableViewHandler {

    public enum Status {
        case normal
        case refresh
        case getMore
        case empty
        case error
    }

    public let tableView: UITableView
    public weak var delegate : BalanceInfoDetailTableViewDelegate?

    public init(tableView: UITableView) {
        self.tableView = tableView
    }

    public func refresh() {
        self.didPullDown?() { [weak self] hasMore in
            self?.hasMore = hasMore
        }
    }

    public var hasMore = false { didSet { updateMJFooter() } }
    public var didPullDown: ((_ finished: @escaping (_ hasMore: Bool) -> Void) -> Void)? { didSet { updateMJHeader() } }
    public var didPullUp: ((_ finished: @escaping (_ hasMore: Bool) -> Void) -> Void)? { didSet { updateMJFooter() } }

    public var status: Status = .empty {
        didSet {
            let view: UIView?
            switch status {
            case .normal:
                view = nil
            case .refresh:
                if oldValue == .empty || oldValue == .error {
                    view = TableViewLoadingView()
                } else {
                    view = nil
                }
            case .getMore:
                view = nil
            case .empty:
                view = delegate?.emptyTipView
            case .error:
                view = delegate?.networkErrorTipView
            }

            if let view = view {
                let footerView = UIView()
                footerView.backgroundColor = .white
                footerView.addSubview(view)
                view.snp.makeConstraints { (m) in
                    m.centerY.equalToSuperview()
                    m.left.equalToSuperview().offset(24)
                    m.right.equalToSuperview().offset(-24)
                }
                view.layoutIfNeeded()
                let lastTableFooterViewHeight = tableView.tableFooterView?.frame.height ?? 0
                let height = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                footerView.frame = CGRect(x: 0, y: 0, width: 0, height: max(height, placeholderViewHeight + lastTableFooterViewHeight - tableView.contentInset.bottom))
                tableView.tableFooterView = footerView
            } else {
                tableView.tableFooterView = nil
            }
        }
    }

    fileprivate var placeholderViewHeight: CGFloat {
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        let ret = tableView.frame.height - tableView.contentSize.height
        return ret
    }

    fileprivate func updateMJHeader() {
        tableView.mj_header = RefreshHeader(refreshingBlock: { [weak self] in
            self?.didPullDown?() { [weak self] hasMore in
                self?.hasMore = hasMore
                self?.tableView.mj_header?.endRefreshing()
            }
        })
    }

    fileprivate func updateMJFooter() {
        if let block = didPullUp, tableView.mj_footer == nil {
            tableView.mj_footer = RefreshFooter(refreshingBlock: { [weak self] in
                block() { [weak self] hasMore in
                    self?.hasMore = hasMore
                    self?.tableView.mj_footer?.endRefreshing()
                }
            })
            tableView.mj_footer?.ignoredScrollViewContentInsetBottom = -20
        }
        tableView.mj_footer?.isHidden = !(status == .normal && hasMore)
    }
}
