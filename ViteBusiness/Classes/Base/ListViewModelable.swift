//
//  ListViewModelable.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/29.
//

import RxSwift
import RxDataSources
import PromiseKit
import Foundation

protocol ListCellable where Self: UITableViewCell {
    associatedtype Model

    
    static var cellHeight: CGFloat { get }
}


class ListViewModel<Model>: NSObject, UITableViewDelegate, UITableViewDataSource {

    public enum LoadStatus: Equatable {
        case normal
        case refresh
        case loadMore
        case empty
        case error(message: String)

        func footerNeedHidden(hasMore: Bool) -> Bool {
            guard hasMore else { return true }
            switch self {
            case .normal, .loadMore:
                return false
            case .refresh, .empty, .error:
                return true
            }
        }
    }

    //MARK: pubilc
    let tableView: UITableView
    var items: [Model] = []
    fileprivate var refreshTimestamp: TimeInterval = 0
    fileprivate(set) var hasMore: Bool = false
    fileprivate(set) var loadStatus: LoadStatus = .normal {
        didSet {
            guard oldValue != loadStatus else { return }

            if oldValue == .refresh {
                self.setTipView(type: .refresh, isShow: false)
            } else if oldValue == .empty {
                self.setTipView(type: .empty, isShow: false)
            } else if case let .error(message) = oldValue {
                self.setTipView(type: .error(message: message), isShow: false)
            }

            if loadStatus == .refresh {
                if self.items.isEmpty {
                    self.setTipView(type: .refresh, isShow: true)
                }
            } else if loadStatus == .empty {
                self.setTipView(type: .empty, isShow: true)
            } else if case let .error(message) = loadStatus {
                self.setTipView(type: .error(message: message), isShow: true)
            }
        }
    }

    func updateLoadStatus() {
        guard self.loadStatus != .refresh && self.loadStatus != .loadMore else { return }
        self.loadStatus = items.isEmpty ? .empty : .normal
    }

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()

        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self

        tableView.mj_header = RefreshHeader(refreshingBlock: { [weak self] in
            self?.tirggerRefresh(clear: false)
        })

        tableView.mj_footer = RefreshFooter(refreshingBlock: { [weak self] in
            self?.tirggerLoadMore()
        })
    }

    deinit {
        clear()
    }

    func clear() {
        for subView in tipViewMap.values {
            subView.removeFromSuperview()
        }

        if tableView.isScrollEnabled == false {
            tableView.isScrollEnabled = true
        }
    }

    @discardableResult
    func tirggerRefresh(clear: Bool = false) -> Promise<(items: [Model], hasMore: Bool)> {
        if clear {
            items = []
            tableView.reloadData()
        }

        loadStatus = .refresh
        self.updateMJHeader()
        let timestamp = Date().timeIntervalSince1970
        self.refreshTimestamp = timestamp
        return refresh().then {[weak self] (items, hasMore) -> Promise<(items: [Model], hasMore: Bool)> in
            let ret = Promise.value((items: items, hasMore: hasMore))
            guard let `self` = self else { return ret }
            guard self.refreshTimestamp == timestamp else { return ret }
            self.items = items
            self.hasMore = hasMore
            self.tableView.reloadData()
            self.loadStatus = items.isEmpty ? .empty : .normal
            return ret
        }.recover {[weak self] (error) -> Promise<(items: [Model], hasMore: Bool)> in
            let ret = Promise<(items: [Model], hasMore: Bool)>(error: error)
            guard let `self` = self else { return ret }
            if self.items.isEmpty {
                self.loadStatus = .error(message: error.localizedDescription)
            } else {
                self.loadStatus = .normal
                Toast.show(error.localizedDescription)
            }
            return ret
        }.ensure { [weak self] in
            guard let `self` = self else { return }
            if self.tableView.mj_header.isRefreshing {
                self.tableView.mj_header.endRefreshing { [weak self] in
                    self?.updateMJHeader()
                    self?.updateMJFooter()
                }
            } else {
                self.updateMJHeader()
                self.updateMJFooter()
            }
        }
    }

    @discardableResult
    func tirggerLoadMore() -> Promise<(items: [Model], hasMore: Bool)> {
        loadStatus = .loadMore
        let timestamp = Date().timeIntervalSince1970
        self.refreshTimestamp = timestamp
        return loadMore().then {[weak self] (items, hasMore) -> Promise<(items: [Model], hasMore: Bool)> in
            let ret = Promise.value((items: items, hasMore: hasMore))
            guard let `self` = self else { return ret }
            guard self.refreshTimestamp == timestamp else { return ret }
            self.merge(items: items)
            self.hasMore = hasMore
            self.tableView.reloadData()
            self.loadStatus = .normal
            return ret
        }.recover {[weak self] (error) -> Promise<(items: [Model], hasMore: Bool)> in
            self?.loadStatus = .normal
            Toast.show(error.localizedDescription)
            return Promise.init(error: error)
        }.ensure { [weak self] in
            guard let `self` = self else { return }
            if self.tableView.mj_footer.isRefreshing {
                self.tableView.mj_footer.endRefreshing { [weak self] in
                    self?.updateMJFooter()
                }
            } else {
                self.updateMJFooter()
            }
        }
    }

    //MARK: must be override
    func refresh() -> Promise<(items: [Model], hasMore: Bool)> {
        fatalError("must be override")
    }

    func loadMore() -> Promise<(items: [Model], hasMore: Bool)> {
        fatalError("must be override")
    }

    func clicked(model: Model) {
        fatalError("must be override")
    }

    func cellHeight(model: Model) -> CGFloat {
        fatalError("must be override")
    }

    func cellFor(model: Model, indexPath: IndexPath) -> UITableViewCell {
        fatalError("must be override")
    }

    //MARK: can be override
    func merge(items: [Model]) {
        self.items.append(contentsOf: items)
    }

    func createLoadingView() -> UIView {
        let view = UIView().then {
            $0.backgroundColor = .white
        }
        let indicatorView = UIActivityIndicatorView(style: .gray).then {
            $0.startAnimating()
        }

        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.bottom.equalToSuperview().inset(20)
        }
        return view
    }

    func createEmptyView() -> UIView {
        return placeholderView(text: R.string.localizable.transactionListPageEmpty(), image: R.image.empty()!)
    }

    func createErrorView(message: String) -> UIView {
        return placeholderView(text: message, image: R.image.network_error()!)
    }
    
    //MARK: private
    private var tipViewMap: [String: UIView] = [:]

    private enum TipViewType {
        case refresh
        case empty
        case error(message: String)

        var key: String {
            switch self {
            case .refresh:
                return "refresh"
            case .empty:
                return "empty"
            case .error:
                return "error"
            }
        }

        var isScrollEnabled: Bool {
            switch self {
            case .refresh:
                return false
            case .empty, .error:
                return true
            }
        }
    }

    private var placeholderViewHeight: CGFloat {
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        let ret = tableView.frame.height - tableView.contentSize.height
        return ret
    }

    private func setTipView(type: TipViewType, isShow: Bool) {
        if isShow {
            guard tipViewMap[type.key] == nil else { return }
            let view: UIView
            switch type {
            case .refresh:
                view = createLoadingView()
            case .empty:
                view = createEmptyView()
            case .error(let message):
                view = createErrorView(message: message)
            }
            tableView.isScrollEnabled = type.isScrollEnabled

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
            tipViewMap[type.key] = nil
            if tableView.isScrollEnabled == false {
                tableView.isScrollEnabled = true
            }
        }
    }

    private func placeholderView(text: String, image: UIImage) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        let layoutGuide = UILayoutGuide()
        let imageView = UIImageView(image: R.image.empty())
        let label = UILabel().then {
            $0.font = UIFont.boldSystemFont(ofSize: 16)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.text = text
        }

        view.addLayoutGuide(layoutGuide)
        view.addSubview(imageView)
        view.addSubview(label)

        layoutGuide.snp.makeConstraints { (m) in
            m.left.right.equalTo(view)
            m.top.bottom.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints { (m) in
            m.top.centerX.equalTo(layoutGuide)
            m.size.equalTo(CGSize(width: 130, height: 130))
        }
        label.snp.makeConstraints { (m) in
            m.top.equalTo(imageView.snp.bottom).offset(20)
            m.left.right.equalTo(layoutGuide).inset(24)
            m.bottom.equalTo(layoutGuide)
        }

        return view
    }

    private func updateMJHeader() {
        let headerNeedHidden: Bool
        if loadStatus == .refresh && !self.tableView.mj_header.isRefreshing {
            headerNeedHidden = true
        } else {
            headerNeedHidden = false
        }
        if self.tableView.mj_header.isHidden != headerNeedHidden {
            self.tableView.mj_header.isHidden = headerNeedHidden
        }
    }
    private func updateMJFooter() {
        self.tableView.mj_footer.isHidden = self.loadStatus.footerNeedHidden(hasMore: self.hasMore)
    }

    //MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight(model: items[indexPath.row])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cellFor(model: items[indexPath.row], indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        clicked(model: items[indexPath.row])
    }
}
