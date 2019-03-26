//
//  TokenListSearchViewController.swift
//  ViteBusiness
//
//  Created by Water on 2019/3/8.
//

import Foundation
import RxCocoa
import RxSwift
import NSObject_Rx
import RxDataSources

class TokenListSearchViewController: UIViewController {
    let viewModel = TokenListSearchViewModel()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate  lazy var tableView = UITableView().then {
        (tableView) in
        tableView.backgroundColor = .white
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 78
        tableView.register(TokenListInfoCell.self, forCellReuseIdentifier: "TokenListInfoCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        tableView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
            m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
        }
    }
    var tokenListArray = TokenListArray()

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TokenInfo>>

    let dataSource = DataSource(
        configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
            let cell: TokenListInfoCell = tableView.dequeueReusableCell(withIdentifier: "TokenListInfoCell") as! TokenListInfoCell
            cell.reloadData(item)
            return cell
    } ,
        titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        automaticallyAdjustsScrollViewInsets = false
        self.definesPresentationContext = true
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)

        self.bindData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.isHidden = false
        self.tableView.reloadData()
    }

    func bindData() {
        self.viewModel.tokenListSearchDriver.map {
                [weak self] (data) in
                self?.tokenListArray = data
                var sectionModels = Array<SectionModel<String,TokenInfo>>()
                if data.count == 0 {
                     return sectionModels
                }
                for item in data {
                    sectionModels.append(SectionModel(model: item[0].coinType.rawValue, items: item))
                }
                return sectionModels
        }.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        

        tableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
}

extension TokenListSearchViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let key = searchController.searchBar.text ?? ""
        self.viewModel.searchAction.execute(key)
        self.view.isHidden = false
    }
}

extension TokenListSearchViewController : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let contentView = UIView()
        if self.tokenListArray.count == 0{
            return contentView
        }
        contentView.backgroundColor = .white
         let lab = UILabel.init(frame: CGRect.init(x: 18, y: 10, width: 100, height: 20))
        lab.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lab.textColor = UIColor.init(netHex: 0x3E4A59)
        lab.backgroundColor = .white
        contentView.addSubview(lab)

        lab.text = self.tokenListArray[section][0].getCoinHeaderDisplay()
        return contentView
    }
}
