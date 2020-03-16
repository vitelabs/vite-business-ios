//
//  MarketDetailViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit
import Then
import RxSwift
import RxCocoa

class MarketDetailViewController: BaseViewController {

    let marketInfoBehaviorRelay: BehaviorRelay<MarketInfo>

    init(marketInfo: MarketInfo) {
        self.marketInfoBehaviorRelay = BehaviorRelay(value: marketInfo)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    let navView = MarketDetailNavView()
    let marketDetailInfoView = MarketDetailInfoView()
    let candlestickChartView = CandlestickChartView()

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).then {
        $0.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    private var manager: DNSPageViewManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    func setupView() {
        navigationTitleView = navView

        let bottomButtonView = UIView()
        bottomButtonView.backgroundColor = .green


        let pageStyle = DNSPageStyle()
        pageStyle.isShowBottomLine = true
        pageStyle.isTitleViewScrollEnabled = true
        pageStyle.titleViewBackgroundColor = .white
        pageStyle.titleSelectedColor = Colors.titleGray
        pageStyle.titleColor = Colors.titleGray_61
        pageStyle.titleFont = Fonts.Font13
        pageStyle.bottomLineColor = Colors.blueBg
        pageStyle.bottomLineHeight = 3

        let viewControllers = [
            OrderBookViewController(),
            LastTradesViewController(),
            MarketTokenInfoViewController(),
            MarketOperatorInfoViewController()
        ]

        let titles = [
            R.string.localizable.marketDetailPageSegmentOrderBookTitle(),
            R.string.localizable.marketDetailPageSegmentLastTradesTitle(),
            R.string.localizable.marketDetailPageSegmentTokenInfoTitle(),
            R.string.localizable.marketDetailPageSegmentOperatorIntoTitle(),
        ]

        let manager = DNSPageViewManager(style: pageStyle, titles: titles, childViewControllers: viewControllers)
        self.manager = manager


        manager.titleView.snp.makeConstraints { (make) in
            make.height.equalTo(35)
        }

        manager.contentView.snp.makeConstraints { (make) in
            make.height.equalTo(300)
        }



        view.addSubview(scrollView)
        view.addSubview(bottomButtonView)

        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom).offset(0)
            m.left.right.equalToSuperview()
        }

        bottomButtonView.snp.makeConstraints { (m) in
            m.top.equalTo(scrollView.snp.bottom)
            m.left.right.bottom.equalToSuperview()
            m.height.equalTo(100)
        }

        scrollView.stackView.addArrangedSubview(marketDetailInfoView)
        scrollView.stackView.addArrangedSubview(candlestickChartView)
        scrollView.stackView.addArrangedSubview(manager.titleView)
        scrollView.stackView.addArrangedSubview(manager.contentView)
    }

    func bind() {
        navView.bind(marketInfo: marketInfoBehaviorRelay.value)

        MarketInfoService.shared.sortedMarketDataBehaviorRelay.bind { [weak self] array in
            guard let `self` = self else { return }
            let infos = array.flatMap { $0.infos }
            for info in infos where info.statistic.symbol == self.marketInfoBehaviorRelay.value.statistic.symbol {
                self.marketInfoBehaviorRelay.accept(info)
                break
            }
        }.disposed(by: rx.disposeBag)

        marketInfoBehaviorRelay.bind { [weak self] in
            guard let `self` = self else { return }
            self.marketDetailInfoView.bind(marketInfo: $0)
        }.disposed(by: rx.disposeBag)
    }

//    var subId: SubId? = nil
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        subId = MarketInfoService.shared.marketSocket.subMarketPair(pairId: "VX_BTC-000") { data in
//            guard let tickerStatisticsProto = try? Protocol.TickerStatisticsProto.parseFrom(data: data) else { return }
//            plog(level: .debug, log: "\(tickerStatisticsProto)", tag: .market)
//        }
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        guard let subId = subId else { return }
//        MarketInfoService.shared.marketSocket.unsub(subId: subId)
//        self.subId = nil
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}
