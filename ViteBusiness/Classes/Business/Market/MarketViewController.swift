//
//  MarketViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/10/8.
//

private let glt_iphoneX = (UIScreen.main.bounds.height >= 812.0)

import UIKit
import MJRefresh
import RxCocoa
import NSObject_Rx
import RxDataSources

class MarketViewController: BaseViewController {

    let marketVM = MarketInfoVM()

    let navTitleView: UILabel = {
        let label = UILabel()
        label.text = "交易所"
        label.font = UIFont.systemFont(ofSize: 17)
        label.alpha = 0
        return label
    }()

    let navSearchButton: UIButton = {
        let searchButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 28))
        searchButton.setBackgroundImage(R.image.market_search(), for: .normal)
        searchButton.alpha = 0
        return searchButton
    }()

    let sortByPriceStatusImg: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 28))
        img.image = (R.image.market_ascend_default())
        return img
    }()

    let sortByPercenteStatusImg: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 28))
        img.image = (R.image.market_ascend_default())
        return img
    }()

    let sortByPriceButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 28))
        return button
    }()

    let sortByPercentButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 28))
        return button
    }()

   lazy var contentView: LTSimpleManager! = {
        let titles: [String] = self.marketVM.sortedMarketDataBehaviorRelay.value.map { (data) -> String in
            return data.categary
        }

        let viewControllers: [MarketPairsViewController] = {
            var vcs = [MarketPairsViewController]()
            for (index, _) in titles.enumerated() {
                let pairsVC = MarketPairsViewController()
                pairsVC.marketVM = marketVM
                pairsVC.index = index
                vcs.append(pairsVC)
            }
            return vcs
        }()

        let layout: LTLayout = {
            let layout = LTLayout()
            layout.bottomLineHeight = 2
            layout.bottomLineCornerRadius = 0
            layout.titleViewBgColor = UIColor.init(hex: "0xFFFFFF")
            layout.titleColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
            layout.titleSelectColor = UIColor.init(netHex: 0x3E4A59)
            layout.pageBottomLineColor = UIColor.white
            layout.sliderHeight = 80
            layout.pageBottomLineHeight = 40
            layout.scale = 1
            layout.titleFont = UIFont.boldSystemFont(ofSize: 13)
            layout.lrMargin = 24
            layout.titleMargin = 30
            layout.bottomLineColor = UIColor.init(netHex: 0x007aff)
            layout.pageBottomLineColor = .white
            return layout
        }()

        let frame: CGRect =  {
            let statusBarH = UIApplication.shared.statusBarFrame.size.height
            let tabBarH = self.tabBarController?.tabBar.frame.size.height ?? 0
            var H: CGFloat = kScreenH - statusBarH - tabBarH - 44
            return CGRect(x: 0, y: 0, width: view.bounds.width, height: H)
        }()

        let contentView = LTSimpleManager(frame: frame, viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout)


        contentView.configHeaderView {[weak self] in
            guard let strongSelf = self else { return nil }
            let headerView = strongSelf.headerView
            return headerView
        }

        let sortViewContainer = contentView.titleView.pageBottomLineView
        sortViewContainer.addSubview(self.sortView)
         self.sortView.snp.makeConstraints { (m) in
             m.edges.equalToSuperview()
         }
        return contentView
    }()

    lazy var headerView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 180))

        let titleLabel = UILabel()
        titleLabel.text = "交易所"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24)
        }

        let searchButton = UIButton()
        searchButton.setBackgroundImage(R.image.market_search(), for: .normal)
        headerView.addSubview(searchButton)
        searchButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.right.equalToSuperview().offset(-16)
            m.width.height.equalTo(28)
        }
        searchButton.addTarget(self, action: #selector(goToSearchVC), for: .touchUpInside)

        let imageView = UIImageView()
        imageView.image = R.image.market_top_bg()
        headerView.addSubview(imageView)
        imageView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalToSuperview().offset(-10)
            m.top.equalTo(searchButton.snp.bottom).offset(20)
        }

        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tappedBanner))
        imageView.addGestureRecognizer(tapGes)
        imageView.isUserInteractionEnabled = true

        let bannerLabel = UILabel()
        bannerLabel.text = "一分钟玩转Vitex"
        bannerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        bannerLabel.textColor = .white
        imageView.addSubview(bannerLabel)
        bannerLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(20)
            m.left.equalToSuperview().offset(16)
        }
        return headerView
    }()

    lazy var sortView: UIView = {
        let sortView = UIView()

         let symbleTitleLabel: UILabel = {
             let label = UILabel()
             label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
             label.font = UIFont.systemFont(ofSize: 12)
             label.text = "名称"
             return label
         }()

         let priceTitleLabel: UILabel = {
             let label = UILabel()
             label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
             label.font = UIFont.systemFont(ofSize: 12)
             label.text = "最新价"
             return label
         }()

         let percentTitleLabel: UILabel = {
             let label = UILabel()
             label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
             label.font = UIFont.systemFont(ofSize: 12)
             label.text = "涨跌幅"
             return label
         }()

         sortView.addSubview(symbleTitleLabel)
         sortView.addSubview(priceTitleLabel)
         sortView.addSubview(percentTitleLabel)
        sortView.addSubview(self.sortByPriceStatusImg)
        sortView.addSubview(self.sortByPercenteStatusImg)
         sortView.addSubview(self.sortByPriceButton)
         sortView.addSubview(self.sortByPercentButton)

         symbleTitleLabel.snp.makeConstraints { (make) -> Void in
             make.left.equalToSuperview().offset(24)
             make.centerY.equalToSuperview()
         }

         self.sortByPriceStatusImg.snp.makeConstraints { (make) -> Void in
             make.right.equalToSuperview().offset(-(kScreenW - 48)*0.33)
             make.centerY.equalToSuperview()
//            make.width.height.equalTo(12)`

         }

         self.sortByPercenteStatusImg.snp.makeConstraints { (make) -> Void in
             make.right.equalToSuperview().offset(-24)
             make.centerY.equalToSuperview()
//            make.width.height.equalTo(12)

         }

         priceTitleLabel.snp.makeConstraints { (make) -> Void in
             make.right.equalTo(self.sortByPriceStatusImg.snp.left)
             make.centerY.equalToSuperview()
        }

        percentTitleLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.sortByPercenteStatusImg.snp.left)
            make.centerY.equalToSuperview()
        }

         self.sortByPriceButton.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.sortByPriceStatusImg)
            make.left.bottom.top.equalTo(priceTitleLabel)
         }

         self.sortByPercentButton.snp.makeConstraints { (make) -> Void in
             make.right.equalTo(self.sortByPercenteStatusImg)
             make.left.bottom.top.equalTo(percentTitleLabel)

         }
        return sortView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false

        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.titleView = navTitleView
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: navSearchButton)
        navSearchButton.addTarget(self, action: #selector(goToSearchVC), for: .touchUpInside)

        view.addSubview(contentView)
        contentView.delegate = self

        contentView.didSelectIndexHandle { [unowned self] (index) in
            self.configSortStatus()
        }
        sortByPercentButton.rx.tap.bind { [unowned self] _ in
            let index = self.contentView.pageView.currentIndex()
            self.marketVM.sortByPercent(index: index)
        }

        sortByPriceButton.rx.tap.bind { [unowned self] _ in
            let index = self.contentView.pageView.currentIndex()
            self.marketVM.sortByPrice(index: index)

        }

        marketVM.sortedMarketDataBehaviorRelay.asObservable()
            .bind { [weak self] _ in
                self?.configSortStatus()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.marketVM.requestPageList()
    }

    @objc func goToSearchVC() {
        let vc = MarketSearchViewController()
        vc.originalData = Array(self.marketVM.sortedMarketDataBehaviorRelay.value.dropFirst())
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func tappedBanner() {
        if (LocalizationService.sharedInstance.currentLanguage == .chinese){
            WebHandler.open("https://forum.vite.net/topic/2655/vitex-%E4%BA%A4%E6%98%93%E6%89%80%E7%A7%BB%E5%8A%A8%E7%AB%AF%E6%93%8D%E4%BD%9C%E6%8C%87%E5%8D%97")
          } else {
            WebHandler.open("https://forum.vite.net/topic/2654/vitex-mobile-terminal-operation-guide")
          }
    }

    func configSortStatus() {
        let configs = self.marketVM.sortedMarketDataBehaviorRelay.value.map { $0.sortStatus }
        let index = self.contentView.pageView.currentIndex()
        let config = configs[index]
        let images = [R.image.market_ascend_default(),R.image.marketr_descending(),R.image.marketr_ascending(),]
        self.sortByPriceStatusImg.image = images[config.0.rawValue]
        self.sortByPercenteStatusImg.image = images[config.1.rawValue]
    }
}


extension MarketViewController: LTSimpleScrollViewDelegate {

    func glt_scrollViewDidScroll(_ scrollView: UIScrollView) {
        let alpha = max(min(scrollView.contentOffset.y, 64.0), 0.0) / 64.0
        navTitleView.alpha = alpha
        navSearchButton.alpha = alpha
    }

    func glt_refreshScrollView(_ scrollView: UIScrollView, _ index: Int) {
        scrollView.mj_header = MJRefreshNormalHeader {[weak scrollView] in
            self.marketVM.requestPageList()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                scrollView?.mj_header.endRefreshing()
            })
        }
    }
}




