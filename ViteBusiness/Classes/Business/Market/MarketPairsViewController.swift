//
//  MarketPairsViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/10/9.
//

import UIKit
import MJRefresh

private let glt_iphoneX = (UIScreen.main.bounds.height >= 812.0)

class MarketPairsViewController : UIViewController, LTTableViewProtocal {

    var marketVM = MarketInfoService.shared
    var index: Int = 0

    lazy var tableView: UITableView = {

        let statusBarH = UIApplication.shared.statusBarFrame.size.height
        let tabBarH = self.tabBarController?.tabBar.frame.size.height ?? 0
        let Y: CGFloat = 0
        var H: CGFloat = glt_iphoneX ? (view.bounds.height - Y - 34) : view.bounds.height - Y
        H = H - tabBarH - 44 - 70
        let tableView = UITableView.listView()
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 12, bottom: 0, right: 12)
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

        marketVM.sortedMarketDataBehaviorRelay.asObservable().bind{ [weak self] items in
            guard let `self` = self else { return }
            self.dataStatus = items[self.index].infos.isEmpty ? .empty : .normal
            self.tableView.reloadData()
        }.disposed(by: rx.disposeBag)

        tableView.register(MarketPageCell.self, forCellReuseIdentifier: "identifier")
    }

}

extension MarketPairsViewController: ViewControllerDataStatusable {
    func emptyView() -> UIView {
        return UIView.defaultPlaceholderView(text: R.string.localizable.transactionListPageEmpty())
    }
}

extension MarketPairsViewController {
    fileprivate func reftreshData()  {
        
    }
}


extension MarketPairsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.marketVM.sortedMarketDataBehaviorRelay.value[index].infos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath) as! MarketPageCell
        let info = self.marketVM.sortedMarketDataBehaviorRelay.value[index].infos[indexPath.row]
        cell.bind(info: info)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let info = self.marketVM.sortedMarketDataBehaviorRelay.value[index].infos[indexPath.row]
        let vc = MarketDetailViewController(marketInfo: info)
        self.navigationController?.pushViewController(vc, animated: true)
        Statistics.logWithUUIDAndAddress(eventId: Statistics.Page.MarketHome.pairClicked.rawValue)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}

