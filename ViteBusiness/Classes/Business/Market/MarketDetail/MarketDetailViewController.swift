//
//  MarketDetailViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit
import Then

class MarketDetailViewController: BaseViewController {

    let marketInfo: MarketInfo

    init(marketInfo: MarketInfo) {
        self.marketInfo = marketInfo
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


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

        navigationTitleView = NavigationTitleView(title: "xxxxx")

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
            m.top.equalTo(navigationTitleView!.snp.bottom).offset(0)
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
}
