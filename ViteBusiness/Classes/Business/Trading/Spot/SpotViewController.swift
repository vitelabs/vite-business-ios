//
//  SpotViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit
import RxSwift
import RxCocoa

class SpotViewController: BaseTableViewController {

    let marketInfoBehaviorRelay: BehaviorRelay<MarketInfo?> = BehaviorRelay(value: nil)
    var depthHolder: MarketDataIndoHolder?
    var viewModle: SpotOpenedOrderListViewModel?
    
    init(symbol: String) {
        if let marketInfo = MarketInfoService.shared.marketInfo(symbol: symbol) {
            self.marketInfoBehaviorRelay.accept(marketInfo)
        }
        super.init(.plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()

    }

    func setupView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = makeHeaderView()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.rowHeight = 85
//        tableView.estimatedRowHeight = 85
//        tableView.separatorStyle = .none
//
//        let emptyView = UIView.defaultPlaceholderView(text: R.string.localizable.spotPageOrderEmpty())
//        emptyView.frame = CGRect(x: 0, y: 0, width: 0, height: 275)
//        tableView.tableFooterView = emptyView
    }

    func bind() {

        navView.switchPair = { [weak self] in
            self?.marketInfoBehaviorRelay.accept($0)
        }

        depthView.priceClicked = { [weak self] in
            self?.operationView.setPrice($0)
        }

        MarketInfoService.shared.sortedMarketDataBehaviorRelay.bind { [weak self] array in
            guard let `self` = self else { return }
            let infos = array.flatMap { $0.infos }
            for info in infos where info.statistic.symbol == self.marketInfoBehaviorRelay.value?.statistic.symbol {
                self.marketInfoBehaviorRelay.accept(info)
                break
            }
        }.disposed(by: rx.disposeBag)

        self.marketInfoBehaviorRelay.bind { [weak self] in
            guard let `self` = self else { return }
            self.navView.bind(marketInfo: $0)
            self.depthView.bind(marketInfo: $0)
        }.disposed(by: rx.disposeBag)

        self.marketInfoBehaviorRelay.asDriver().distinctUntilChanged { (left, right) -> Bool in
            left?.statistic.symbol == right?.statistic.symbol
        }.drive(onNext: { [weak self] info in
            guard let `self` = self else { return }
            guard let info = info else { return }

            self.operationView.bind(marketInfo: info)

            let holder = MarketDataIndoHolder(marketInfo: info)

            holder.marketPairDetailInfoBehaviorRelay.bind { [weak self] in
                guard let `self` = self else { return }
                self.navView.setOpertionIcon($0?.operatorInfo.icon)
            }.disposed(by: holder.rx.disposeBag)

            holder.depthListBehaviorRelay.bind { [weak self] in
                guard let `self` = self else { return }
                self.depthView.bind(depthList: $0)
            }.disposed(by: holder.rx.disposeBag)

            self.depthHolder = holder
            self.viewModle = SpotOpenedOrderListViewModel(tableView: self.tableView, tradeTokenSymbol: info.statistic.tradeTokenSymbol, quoteTokenSymbol: info.statistic.quoteTokenSymbol)
        }).disposed(by: rx.disposeBag)

    }

    let navView = SpotNavView()
    let operationView = SpotOperationView()
    let depthView = SpotDepthView()
    let ordersHeaderView = SpotOrdersHeaderView()

    func makeHeaderView() -> UIView {
        let view = UIView()
        var height = SpotNavView.height
        height += 10
        height += max(SpotOperationView.height, SpotDepthView.height)
        height += 16
        height += 16
        height += SpotOrdersHeaderView.height
        view.frame = CGRect(x: 0, y: 0, width: 0, height: height)

        view.addSubview(navView)
        view.addSubview(operationView)
        view.addSubview(depthView)
        view.addSubview(ordersHeaderView)

        navView.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
        }

        operationView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom).offset(10)
            m.left.equalToSuperview().offset(24)
            m.right.equalTo(view.snp.centerX)
        }

        depthView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom).offset(10)
            m.left.equalTo(view.snp.centerX).offset(12)
            m.right.equalToSuperview().offset(-24)
        }

        let line = UIView()
        line.backgroundColor = UIColor(netHex: 0xF3F5F9)
        view.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.top.greaterThanOrEqualTo(operationView.snp.bottom).offset(16)
            m.top.greaterThanOrEqualTo(depthView.snp.bottom).offset(16)
            m.left.right.equalToSuperview()
            m.height.equalTo(16)
        }

        ordersHeaderView.snp.makeConstraints { (m) in
            m.top.equalTo(line.snp.bottom)
            m.left.right.equalToSuperview()
        }
        return view
    }
}

extension SpotViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return SpotOrderCell()
    }
}
