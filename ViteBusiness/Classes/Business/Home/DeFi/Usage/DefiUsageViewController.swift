//
//  DefiUsageViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/12/9.
//

import UIKit
import PromiseKit

class DefiUsageViewController: BaseTableViewController {

    var productHash: String

    init(productHash: String) {
        self.productHash = productHash
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var viewModel = DefiUsageViewModel(tableView: self.tableView, productHash: self.productHash)

    let titleView = PageTitleView.onlyTitle(title: R.string.localizable.defiUsePageTitle())

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableHeaderView = titleView
        self.setNavTitle(title: R.string.localizable.defiUsePageTitle(), bindTo: self.tableView)
        _ = viewModel
    }

}

class DefiUsageViewModel: ListViewModel<DefiUsageInfo> {

    let address = HDWalletManager.instance.account!.address
    let productHash: String

    init(tableView: UITableView, productHash: String) {
        self.productHash = productHash
        super.init(tableView: tableView)
        tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [DefiUsageInfo], hasMore: Bool)> {
        return UnifyProvider.defi.getUsage(address: HDWalletManager.instance.account!.address,productHash: productHash)
        .map { (items: $0, hasMore: false) }
    }

    override func clicked(model: DefiUsageInfo) {

    }

    override func cellHeight(model: DefiUsageInfo) -> CGFloat {
       if model.usageType == 3{
            return DefiUsageForSBPCell.cellHeight
       } else if  model.usageType == 2{
            return DefiUsageForSVIPCell.cellHeight
       } else if  model.usageType == 4{
            return DefiUsageForQuotalCell.cellHeight
       } else if  model.usageType == 1{
            return DefiUsageForMinningCell.cellHeight
       }
        return 0
   }

   override func cellFor(model: DefiUsageInfo, indexPath: IndexPath) -> UITableViewCell {
    if model.usageType == 3{
        let cell: DefiUsageForSBPCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    } else if  model.usageType == 2{
        let cell: DefiUsageForSVIPCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    } else if  model.usageType == 4{
        let cell: DefiUsageForQuotalCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    } else if  model.usageType == 1{
        let cell: DefiUsageForMinningCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    }
    return UITableViewCell()

   }


}
