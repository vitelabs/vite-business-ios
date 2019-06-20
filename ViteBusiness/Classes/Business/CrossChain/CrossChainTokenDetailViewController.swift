//
//  GatewayTokenDetailViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/6/11.
//

import UIKit
import Result
import SwiftyJSON

class GatewayTokenDetailViewController: BaseViewController {

    let tokenInfo: TokenInfo

    let tableView = UITableView.listView()

    var info = [String: Any]() {
        didSet {
            self.dateSource =
                [
                    (R.string.localizable.crosschainTokenDetailShortname(),JSON(info)["symbol"].string),
                    (R.string.localizable.crosschainTokenDetailId(),JSON(info)["tokenCode"].string),
                    (R.string.localizable.crosschainTokenDetailName(),JSON(info)["name"].string),
                    (R.string.localizable.crosschainTokenDetailAddress(),JSON(info)["platform"]["tokenAddress"].string),
                    (R.string.localizable.crosschainTokenDetailAmount(),JSON(info)["total"].string),
                    (R.string.localizable.crosschainTokenDetailDigit(),JSON(info)["tokenDigit"].string),
                    (R.string.localizable.crosschainTokenDetailIssuance(),JSON(info)["symbol"].string),
                    (R.string.localizable.crosschainTokenDetailDate(),JSON(info)["updateTime"].string),
                    (R.string.localizable.crosschainTokenDetailDesc(),JSON(info)["overview"].string),
                ] as! [(String, String?)]
        }
    }

    var dateSource: [(String, String?)] = []

    init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let pageTitleView = PageTitleView.titleAndIcon(title: R.string.localizable.crosschainTokendetail(), icon: tokenInfo.chainIcon)
        pageTitleView.tokenInfo = tokenInfo
        navigationTitleView = pageTitleView

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.top.equalTo(navigationTitleView!.snp.bottom)
        }
        tableView.delegate = self
        tableView.dataSource = self

        ExchangeProvider.instance.getTokenInfoDetail(tokenCode: "1224") { [weak self] (result) in
            switch result {
            case .success(let value):
                self?.info = value
                self?.tableView.reloadData()

            case .failure(let e):
                Toast.show(e.localizedDescription)
            }
        }
    }
    

}

extension GatewayTokenDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dateSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.font = font(16)
        cell.textLabel?.textColor = UIColor.init(netHex: 0x24272B)
        cell.textLabel?.text = self.dateSource[indexPath.row].0
        cell.detailTextLabel?.text = self.dateSource[indexPath.row].1
        return cell
    }

}
