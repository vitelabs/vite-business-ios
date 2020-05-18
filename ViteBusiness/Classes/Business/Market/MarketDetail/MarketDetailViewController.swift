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
    var klineHolder: MarketKlineHolder?
    var depthHolder: MarketDataIndoHolder?

    let depthVC = OrderBookViewController()
    let tradsVC = LastTradesViewController()
    let tokenInfoVC = MarketTokenInfoViewController()
    let operatorInfoVC = MarketOperatorInfoViewController()

    init(marketInfo: MarketInfo) {
        self.marketInfoBehaviorRelay = BehaviorRelay(value: marketInfo)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    let navView = MarketDetailNavView()
    let marketDetailInfoView = MarketDetailInfoView()
    let candlestickChartView = CandlestickChartView(klineType: MarketKlineType.day1)
    let bottomView = BottomView()

    lazy var contentView: LTSimpleManager = {
        let titles = [
            R.string.localizable.marketDetailPageSegmentOrderBookTitle(),
            R.string.localizable.marketDetailPageSegmentLastTradesTitle(),
            R.string.localizable.marketDetailPageSegmentTokenInfoTitle(),
            R.string.localizable.marketDetailPageSegmentOperatorIntoTitle(),
        ]

        let viewControllers = [
            self.depthVC,
            self.tradsVC,
            self.tokenInfoVC,
            self.operatorInfoVC
        ]

        let layout: LTLayout = {
            let layout = LTLayout()
            layout.sliderHeight = 38

            layout.bottomLineHeight = 2
            layout.bottomLineCornerRadius = 0
            layout.bottomLineColor = UIColor.init(netHex: 0x007aff)

            layout.scale = 1
            layout.lrMargin = 12
            layout.titleMargin = 30
            layout.titleFont = UIFont.boldSystemFont(ofSize: 13)
            layout.titleViewBgColor = UIColor(netHex: 0x3E4A59, alpha: 0.02)
            layout.titleColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
            layout.titleSelectColor = UIColor.init(netHex: 0x3E4A59)

            layout.pageBottomLineColor = UIColor(netHex: 0xD3DFEF)
            layout.pageBottomLineHeight = CGFloat.singleLineWidth
            
            layout.showsHorizontalScrollIndicator = false

            return layout
        }()

        let frame: CGRect =  {
            let statusBarH = UIApplication.shared.statusBarFrame.size.height
            let navH: CGFloat = MarketDetailNavView.height
            let bottomH: CGFloat = BottomView.height
            let bottomSafeH: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
            var H: CGFloat = kScreenH - statusBarH - navH - bottomH - bottomSafeH
            return CGRect(x: 0, y: statusBarH + navH, width: kScreenW, height: H)
        }()

        let contentView = LTSimpleManager(frame: frame, viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout)

        contentView.configHeaderView {[weak self] in
            guard let strongSelf = self else { return nil }
            let headerView = strongSelf.headerView
            return headerView
        }

        contentView.scrollToIndex(index: 0)
        return contentView
    }()

    lazy var headerView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0,
                                              width: self.view.bounds.width,
                                              height: MarketDetailInfoView.height + CandlestickChartView.height))

        headerView.addSubview(self.marketDetailInfoView)
        headerView.addSubview(self.candlestickChartView)

        self.marketDetailInfoView.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
        }

        self.candlestickChartView.snp.makeConstraints { (m) in
            m.top.equalTo(self.marketDetailInfoView.snp.bottom)
            m.left.right.equalToSuperview()
        }
        return headerView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    func setupView() {

        view.addSubview(navView)
        view.addSubview(contentView)
        view.addSubview(bottomView)

        navView.snp.remakeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalTo(view)
            m.right.equalTo(view)
        }

        contentView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom).offset(0)
            m.left.right.equalToSuperview()
        }

        bottomView.snp.makeConstraints { (m) in
            m.top.equalTo(contentView.snp.bottom)
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
            m.height.equalTo(BottomView.height)
        }
    }

    func bind() {

        navView.switchPair = { [weak self] info in
            guard let `self` = self else { return }
            self.marketInfoBehaviorRelay.accept(info)
        }

        operatorInfoVC.switchPair = { [weak self] info in
            guard let `self` = self else { return }
            NotificationCenter.default.post(name: .goTradingPage, object: self, userInfo: ["marketInfo": info, "isBuy" : true])
        }

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

        Driver.combineLatest(marketInfoBehaviorRelay.asDriver(),
                             candlestickChartView.kineTypeBehaviorRelay.asDriver())
            .drive(onNext: { [weak self] (info, type) in
                guard let `self` = self else { return }

                if let holder = self.klineHolder {
                    guard info.statistic.symbol != holder.marketInfo.statistic.symbol ||
                        type != holder.kineType else {
                        return
                    }
                    holder.unsub()
                }


                let klineHolder = MarketKlineHolder(marketInfo: info, kineType: type)
                klineHolder.klinesBehaviorRelay.bind { [weak self] in
                    self?.candlestickChartView.bind(klineItems: $0, info: info)
                }.disposed(by: klineHolder.rx.disposeBag)

                self.klineHolder = klineHolder


            }).disposed(by: rx.disposeBag)

        marketInfoBehaviorRelay.asDriver().distinctUntilChanged { (left, right) -> Bool in
            left.statistic.symbol == right.statistic.symbol
        }.drive(onNext: { [weak self] info in
            guard let `self` = self else { return }
            self.navView.bind(marketInfo: info)
            let holder = MarketDataIndoHolder(marketInfo: info)
            holder.depthListBehaviorRelay.bind { [weak self] in
                plog(level: .debug, log: $0)
                guard let `self` = self else { return }
                self.depthVC.bind(info: info, depthList: $0.0, myOrders: $0.1)
            }.disposed(by: holder.rx.disposeBag)

            holder.tradesBehaviorRelay.bind { [weak self] in
                plog(level: .debug, log: $0)
                guard let `self` = self else { return }
                self.tradsVC.bind(info: info, trades: $0)
            }.disposed(by: holder.rx.disposeBag)
            self.depthHolder = holder
            holder.marketPairDetailInfoBehaviorRelay.bind { [weak self] in
                plog(level: .debug, log: $0)
                guard let `self` = self else { return }
                self.tokenInfoVC.bind(info: $0)
                self.operatorInfoVC.bind(info: $0)
                self.navView.setOpertionIcon($0?.operatorInfo.icon)
            }.disposed(by: holder.rx.disposeBag)
        }).disposed(by: rx.disposeBag)

        bottomView.buyButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            NotificationCenter.default.post(name: .goTradingPage, object: self, userInfo: ["marketInfo": self.marketInfoBehaviorRelay.value, "isBuy" : true])
        }.disposed(by: rx.disposeBag)

        bottomView.sellButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            NotificationCenter.default.post(name: .goTradingPage, object: self, userInfo: ["marketInfo": self.marketInfoBehaviorRelay.value, "isBuy" : false])
        }.disposed(by: rx.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension MarketDetailViewController {

    class BottomView: UIView {

        static let height: CGFloat = 94

        let buyButton = UIButton(style: .green, title: R.string.localizable.marketDetailPageBuyButtonTitle())
        let sellButton = UIButton(style: .red, title: R.string.localizable.marketDetailPageSellButtonTitle())

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(buyButton)
            addSubview(sellButton)

            buyButton.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(20)
                m.left.equalToSuperview().offset(24)
                m.bottom.equalToSuperview().offset(-24)
            }

            sellButton.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(20)
                m.left.equalTo(buyButton.snp.right).offset(24)
                m.width.equalTo(buyButton)
                m.right.equalToSuperview().offset(-24)
                m.bottom.equalToSuperview().offset(-24)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }


    }
}
