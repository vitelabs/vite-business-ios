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
        if indexPath.row == 8 {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: nil)
            cell.detailTextLabel?.numberOfLines = 0
        } else {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: nil)
        }

        if indexPath.row == 1 || indexPath.row == 3 {
            cell.detailTextLabel?.textColor = UIColor.init(netHex: 0x007AFF)
        } else {
            cell.detailTextLabel?.textColor = UIColor.init(netHex: 0x3E4A59, alpha:  0.7)
        }

        cell.textLabel?.font = font(16)
        cell.textLabel?.textColor = UIColor.init(netHex: 0x24272B)
        cell.textLabel?.text = self.itemTitles[indexPath.row]
        cell.detailTextLabel?.font = font(16)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        return 54
    }

}
