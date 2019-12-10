//
//  SeletcMarketPairCard.swift
//  Action
//
//  Created by haoshenyang on 2019/10/17.
//

import UIKit

private let glt_iphoneX = (UIScreen.main.bounds.height >= 812.0)

import UIKit
import MJRefresh
import RxCocoa
import NSObject_Rx
import RxDataSources

class SeletcMarketPairCard: BaseViewController {

    let marketVM = MarketInfoService.shared

    let navTitleView: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.marketSwitch()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()

    let navSearchButton: UIButton = {
        let searchButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 28))
        searchButton.setBackgroundImage(R.image.market_search(), for: .normal)
        return searchButton
    }()

    let navCloseButton: UIButton = {
        let searchButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 28))
        searchButton.setBackgroundImage(R.image.icon_quota_close(), for: .normal)
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

        let viewControllers: [SelectMarketPairSubViewController] = {
            var vcs = [SelectMarketPairSubViewController]()
            for (index, _) in titles.enumerated() {
                let pairsVC = SelectMarketPairSubViewController()
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
            layout.sliderHeight = 68
            layout.pageBottomLineHeight = 38
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
            var H: CGFloat = 600 - statusBarH - tabBarH - 44
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
        contentView.scrollToIndex(index: 1)
        return contentView
    }()

    lazy var headerView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1))
        return headerView
    }()

    lazy var sortView: UIView = {
        let sortView = UIView()

         let symbleTitleLabel: UILabel = {
             let label = UILabel()
             label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
             label.font = UIFont.systemFont(ofSize: 12)
             label.text = R.string.localizable.marketName()
             return label
         }()

         let priceTitleLabel: UILabel = {
             let label = UILabel()
             label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
             label.font = UIFont.systemFont(ofSize: 12)
             label.text = R.string.localizable.marketPrice()
             return label
         }()

         let percentTitleLabel: UILabel = {
             let label = UILabel()
             label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
             label.font = UIFont.systemFont(ofSize: 12)
             label.text = R.string.localizable.marketPercent()
             return label
         }()

        let operatorTitleLabel: UILabel = {
              let label = UILabel()
              label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
              label.font = UIFont.systemFont(ofSize: 12)
            label.text = R.string.localizable.marketOperator()
              return label
          }()

         sortView.addSubview(symbleTitleLabel)
         sortView.addSubview(priceTitleLabel)
         sortView.addSubview(percentTitleLabel)
        sortView.addSubview(self.sortByPriceStatusImg)
        sortView.addSubview(self.sortByPercenteStatusImg)
         sortView.addSubview(self.sortByPriceButton)
         sortView.addSubview(self.sortByPercentButton)
        sortView.addSubview(operatorTitleLabel)


         symbleTitleLabel.snp.makeConstraints { (make) -> Void in
             make.left.equalToSuperview().offset(24)
             make.centerY.equalToSuperview()
         }

         self.sortByPriceStatusImg.snp.makeConstraints { (make) -> Void in
             make.right.equalToSuperview().offset(-188.0 * (kScreenW )/(375.0 ))
             make.centerY.equalToSuperview()

         }

         self.sortByPercenteStatusImg.snp.makeConstraints { (make) -> Void in
             make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-110.0 * (kScreenW )/(375.0 ))

         }

         priceTitleLabel.snp.makeConstraints { (make) -> Void in
             make.right.equalTo(self.sortByPriceStatusImg.snp.left)
             make.centerY.equalToSuperview()
        }

        percentTitleLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.sortByPercenteStatusImg.snp.left)
        }

        operatorTitleLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-24)
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

        let line = UIView()
        line.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
        sortView.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalToSuperview()
            m.height.equalTo(0.5)
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

        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: navCloseButton)
        navCloseButton.addTarget(SeletcMarketPairManager.shared, action: #selector(SeletcMarketPairManager.closeCard), for: .touchUpInside)

        view.addSubview(contentView)

        contentView.didSelectIndexHandle { [unowned self] (index) in
            self.configSortStatus()
        }
        sortByPercentButton.rx.tap.bind { [unowned self] _ in
            let index = self.contentView.pageView.currentIndex()
            self.marketVM.sortByPercent(index: index)
        }.disposed(by:rx.disposeBag)

        sortByPriceButton.rx.tap.bind { [unowned self] _ in
            let index = self.contentView.pageView.currentIndex()
            self.marketVM.sortByPrice(index: index)

        }.disposed(by:rx.disposeBag)

        marketVM.sortedMarketDataBehaviorRelay.asObservable()
            .bind { [weak self] _ in
                self?.configSortStatus()
        }.disposed(by:rx.disposeBag)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.marketVM.requestPageList()
    }

    @objc func goToSearchVC() {
        SeletcMarketPairManager.shared.showSearch()
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

class SelectMarketPairSubViewController : UIViewController, LTTableViewProtocal, UITableViewDelegate, UITableViewDataSource  {

    var marketVM = MarketInfoService.shared
    var index: Int = 0

    lazy var tableView: UITableView = {

        let statusBarH = UIApplication.shared.statusBarFrame.size.height
        let tabBarH = self.tabBarController?.tabBar.frame.size.height ?? 0
        let Y: CGFloat = 0
        var H: CGFloat = 600
        H = H - tabBarH - 44 - 70
        let tableView = UITableView.listView()
        tableView.frame = CGRect(x: 0, y:44, width: view.bounds.width, height: H)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.top.equalToSuperview().offset(80)
        }
        glt_scrollView = tableView
        reftreshData()
        if #available(iOS 11.0, *) {
            glt_scrollView?.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        marketVM.sortedMarketDataBehaviorRelay.asObservable().bind{ _ in
            self.tableView.reloadData()
        }

        tableView.register(SelectMarketPairCell.self, forCellReuseIdentifier: "identifier")
    }

    func vitexPageUrl() -> URL {
        var urlStr = ViteConst.instance.vite.viteXUrl + "#/assets"
            + "?address=" + (HDWalletManager.instance.account?.address ?? "")
            + "&currency=" + AppSettingsService.instance.appSettings.currency.rawValue
        return URL.init(string:urlStr)!
    }

    fileprivate func reftreshData()  {

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.marketVM.sortedMarketDataBehaviorRelay.value[index].infos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath) as! SelectMarketPairCell
        let info = self.marketVM.sortedMarketDataBehaviorRelay.value[index].infos[indexPath.row]
        cell.bind(info: info)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let info = self.marketVM.sortedMarketDataBehaviorRelay.value[index].infos[indexPath.row]
        SeletcMarketPairManager.shared.closeCard()
        SeletcMarketPairManager.shared.onSelectInfo?(info)

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

