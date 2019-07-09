//
//  BnbTransactionListViewController.swift
//  ViteBusiness
//
//  Created by Water on 2019/7/3.
//

import Foundation
import ViteWallet
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources
import MJRefresh

import BinanceChain

class BnbTransactionListViewController: BaseTableViewController {
    var symbol : String

    init(symbol:String) {
        self.symbol = symbol
        super.init(.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Tx>>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.bind()
    }

    var tableViewModel: BnbTransactionListTableViewModel!

    fileprivate func setupView() {
        tableView.separatorStyle = .none
        tableView.rowHeight = BnbTransactionCell.cellHeight
        tableView.estimatedRowHeight = BnbTransactionCell.cellHeight
        let header = RefreshHeader(refreshingBlock: { [weak self] in
            self?.refreshList(finished: { [weak self] in
                self?.tableView.mj_header.endRefreshing()
            })
        })

        tableView.mj_header = header

        var safeAreaBottom: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: safeAreaBottom, right: 0.0);
    }

    let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: BnbTransactionCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item, index: indexPath.row)
        return cell
    })

    let footerView = GetMoreLoadingView(frame: CGRect(x: 0, y: 0, width: 0, height: 80))

    func bind() {

        if tableViewModel == nil {
            tableViewModel = BnbTransactionListTableViewModel(symbol: self.symbol)

            tableViewModel.hasMore.asObservable().bind { [weak self] in
                self?.tableView.tableFooterView = $0 ? self?.footerView : nil
                }.disposed(by: rx.disposeBag)

            tableViewModel.transactionsDriver.asObservable()
                .map { [SectionModel(model: "transaction", items: $0)] }
                .bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

            tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
            tableView.rx.itemSelected
                .bind { [weak self] indexPath in
                    guard let `self` = self else { return }
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    if let viewModel = (try? self.dataSource.model(at: indexPath)) as? Tx {
                        let host = "https://explorer.binance.org/tx"
                        guard let string = viewModel.txHash.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
                        guard let url = URL(string: "\(host)/\(string)") else { return }
                        WebHandler.open(url)
                    }
                }
                .disposed(by: rx.disposeBag)

            let endScroll = Observable.merge(tableView.rx.didEndDragging.filter { !$0 }.map { _ in Swift.Void() }.asObservable(),
                                             tableView.rx.didEndDecelerating.asObservable())
            endScroll
                .filter { [unowned self] in
                    guard let footerView = self.tableView.tableFooterView else { return false }
                    let triggerOffset = self.tableView.frame.height / 2
                    let frame = footerView.superview!.convert(footerView.frame, to: self.view)
                    return frame.origin.y < self.view.frame.height + triggerOffset
                }
                .bind { [unowned self] in
                    self.getMore()
                }
                .disposed(by: rx.disposeBag)

            footerView.retry.throttle(0.5, scheduler: MainScheduler.instance)
                .bind { [unowned self] in
                    self.getMore()
                    self.footerView.status = .loading
                }
                .disposed(by: rx.disposeBag)
        } else {
            tableViewModel.update()
        }

        dataStatus = .loading
        refreshList()
    }

    private func getMore(finished: (() -> Void)? = nil) {
        self.tableViewModel.getMore { error in
            if let _ = error {
                self.footerView.status = .failed
            }
        }
    }

    private func refreshList(finished: (() -> Void)? = nil) {
        tableViewModel.refreshList { [weak self] error in
            if let f = finished {
                f()
            }

            if let error = error {
                self?.dataStatus = .networkError(error, { [weak self] in
                    self?.refreshList()
                })
            } else {
                guard let `self` = self else { return }
                if self.tableView.numberOfRows(inSection: 0) > 0 {
                    self.dataStatus = .normal
                } else {
                    self.dataStatus = .empty
                }
            }
        }
    }
}

extension BnbTransactionListViewController: ViewControllerDataStatusable {

    private var showImage: Bool {
        return UIScreen.main.bounds.size != CGSize(width: 320, height: 568)
    }

    func networkErrorView(error: Error, retry: @escaping () -> Void) -> UIView {
        return UIView.networkErrorAndshowAccountView(error: error, showImage: showImage) { [weak self] in
            var urlStr = String.init(format: "https://explorer.binance.org/address/%@", BnbWallet.shared.fromAddress ?? "") 
            let vc = WKWebViewController(url: URL.init(string: urlStr)!)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func emptyView() -> UIView {
        return UIView.defaultPlaceholderView(text: R.string.localizable.transactionListPageEmpty(), showImage: showImage)
    }
}

