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
import ViteUtils

class TokenListSearchViewController: UIViewController {
    let viewModel = TokenListSearchViewModel()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public  var searchBar : UISearchBar?

    fileprivate  lazy var tableView = UITableView().then { (tableView) in
        view.addSubview(tableView)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 78
        tableView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
            m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
        }
        tableView.register(TokenListInfoCell.self, forCellReuseIdentifier: "TokenListInfoCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }

    var tokenListArray : TokenListArray = TokenListArray()

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TokenInfo>>

    let dataSource = DataSource(
        configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
            let cell: TokenListInfoCell = tableView.dequeueReusableCell(withIdentifier: "TokenListInfoCell") as! TokenListInfoCell
            cell.tokenInfo = item
            return cell
    } ,
        titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = .top

        self.setupUI()
        self.bindData()
    }

    func bindData() {
        self.viewModel.tokenListSearchDriver.map { [weak self] (data) in
            self?.tokenListArray = data
            var sectionModels = Array<SectionModel<String,TokenInfo>>()
            for item in data {
                sectionModels.append(SectionModel(model: item[0].coinType.rawValue, items: item))
            }
            return sectionModels
        }.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

        tableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }

    func setupUI() {

    }
}

extension TokenListSearchViewController : UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar?.resignFirstResponder()
    }
}

extension TokenListSearchViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let key = searchController.searchBar.text ?? ""
        self.viewModel.search(key)
    }
}

extension TokenListSearchViewController : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let contentView = UIView()
        contentView.backgroundColor = .white
        let lab = UILabel.init(frame: CGRect.init(x: 24, y: 10, width: 100, height: 20))
        lab.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lab.textColor = UIColor.init(netHex: 0x3E4A59)
        lab.backgroundColor = .white
        contentView.addSubview(lab)

        lab.text = self.tokenListArray[section][0].getCoinHeaderDisplay()
        return contentView
    }
}
