//
//  GateWayDetailViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/7/30.
//

import Foundation
import Result
import SwiftyJSON
import BigInt

class GateWayDetailViewController: BaseViewController {

    let tokenInfo: TokenInfo

    let tableView = UITableView.listView()

    let itemTitles = [R.string.localizable.crosschainGatewaydetailName(),
                      R.string.localizable.crosschainGatewaydetailWebset(),
                      R.string.localizable.crosschainGatewaydetailEmail(),
                      R.string.localizable.crosschainGatewaydetailStatement(),
                      R.string.localizable.crosschainGatewaydetailHost(),
                      R.string.localizable.crosschainGatewaydetailAbstract(),
    ]

    var items = Array<String?>.init(repeating: "--", count: 6)

    init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        super.init(nibName: nil, bundle: nil)
        if let gatewayInfo = tokenInfo.gatewayInfo {
            let isEn = LocalizationService.sharedInstance.currentLanguage == .base
            items = [
                gatewayInfo.name,
                gatewayInfo.website,
                gatewayInfo.support,
                isEn ? gatewayInfo.policy["en"] : gatewayInfo.policy["zh"],
                gatewayInfo.url,
                isEn ? gatewayInfo.overview["en"] : gatewayInfo.overview["zh"]
            ]

        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let pageTitleView = PageTitleView.titleAndIcon(title: R.string.localizable.crosschainGatewaydetailTitle(), icon: tokenInfo.chainIcon)
        pageTitleView.tokenInfo = tokenInfo
        navigationTitleView = pageTitleView

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.top.equalTo(navigationTitleView!.snp.bottom)
        }
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension GateWayDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if indexPath.row == 5 {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: nil)
            cell.detailTextLabel?.numberOfLines = 0
        } else {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: nil)
        }

        if [1,2,3].contains(indexPath.row) {
            cell.detailTextLabel?.textColor = UIColor.init(netHex: 0x007AFF)
        } else {
            cell.detailTextLabel?.textColor = UIColor.init(netHex: 0x3E4A59, alpha:  0.7)
        }

        cell.textLabel?.font = font(16)
        cell.textLabel?.textColor = UIColor.init(netHex: 0x24272B)
        cell.textLabel?.text = self.itemTitles[indexPath.row]
        cell.detailTextLabel?.text = self.items[indexPath.row]
        cell.detailTextLabel?.font = font(16)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let value = items[indexPath.row] ?? ""

        if indexPath.row == 1 ||  indexPath.row == 3 {
            guard let url = URL.init(string: value) else {
                return
            }
            let vc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 2 {
            guard let url = URL.init(string: "mailto:" + value) else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5 && !(self.items[5] ?? "" ).isEmpty && self.items[5] != "--" {
            return UITableView.automaticDimension
        } else {
            return 54
        }
    }

}
