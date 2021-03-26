//
//  GatewayInfoDetailViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/5/8.
//

import Foundation

class GatewayInfoDetailViewController: BaseTableViewController {

    let gatewayInfo: GatewayInfo
    init(gatewayInfo: GatewayInfo) {
        self.gatewayInfo = gatewayInfo
        super.init(.plain)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    var cells: [BaseTableViewCell] = []

    func setupView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension

        navigationTitleView = NavigationTitleView(title: R.string.localizable.gatewayInfoDetailPageTitle())

        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }

        cells.append({
            let cell = InfoTitleValueCell()
            cell.setTitle(R.string.localizable.gatewayInfoDetailPageName(), text: gatewayInfo.name)
            return cell
        }())

        cells.append({
            let cell = InfoTitleValueCell()
            let text = gatewayInfo.website ?? "--"
            let url = gatewayInfo.website == nil ? nil : URL(string: text)
            cell.setTitle(R.string.localizable.gatewayInfoDetailPageWebside(), text: text, url: url)
            return cell
        }())

        cells.append({
            let cell = InfoTitleValueCell()
            cell.setTitle(R.string.localizable.gatewayInfoDetailPageBrief(), text: gatewayInfo.overviewString)
            return cell
        }())

        cells.append({
            let cell = InfoTitleValueCell()
            let text = gatewayInfo.serviceSupport
            let url = URL(string: text)
            cell.setTitle(R.string.localizable.gatewayInfoDetailPageEmail(), text: text, url: url)
            return cell
        }())

        cells.append({
            let cell = InfoTitleValueCell()
            let text = gatewayInfo.policyString
            let url = URL(string: text)
            cell.setTitle(R.string.localizable.gatewayInfoDetailPageAgreement(), text: text, url: url)
            return cell
        }())

        cells.append({
            let cell = InfoTitleValueCell()
            let text = gatewayInfo.urlString
            let url = URL(string: text)
            cell.setTitle(R.string.localizable.gatewayInfoDetailPageLink(), text: text, url: url)
            return cell
        }())
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }

}
