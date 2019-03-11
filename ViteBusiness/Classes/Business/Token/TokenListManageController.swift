//
//  TokenListManageController.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/22.
//

import Foundation
import ViteWallet
import RxCocoa
import RxSwift
import SnapKit
import NSObject_Rx
import RxDataSources
import ViteUtils

class TokenListManageController: BaseViewController {
    let viewModel = TokenListManageViewModel()

    fileprivate lazy var tableView = UITableView().then { (tableView) in
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindData()
        self.viewModel.refreshList()
    }

    deinit {
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = nil
        } else {
            
        }
    }

    fileprivate lazy var searchResultVC = TokenListSearchViewController()

    fileprivate lazy var searchVC = UISearchController(searchResultsController:self.searchResultVC).then { (searchVC) in
        searchVC.searchResultsUpdater = self.searchResultVC
        let placeholderAttributes = [NSAttributedString.Key.font: Fonts.Font13,
                          NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x24272B, alpha: 0.31)]


        let attributedPlaceholder: NSAttributedString = NSAttributedString(string: R.string.localizable.tokenListPageSearchTitle(), attributes: placeholderAttributes)
        let textFieldPlaceHolder = searchVC.searchBar.value(forKey: "searchField") as? UITextField
        textFieldPlaceHolder?.attributedPlaceholder = attributedPlaceholder


        searchVC.searchBar.tintColor = UIColor.init(red:22, green:161, blue: 1)
        searchVC.searchBar.barTintColor = UIColor.white
        searchVC.searchBar.layer.borderColor = UIColor.white.cgColor
        searchVC.searchBar.backgroundImage = R.image.icon_background()?.resizable
        searchVC.dimsBackgroundDuringPresentation = true
    }

    func setupUI() {
         self.definesPresentationContext = true
//        if #available(iOS 11.0, *) {
//            self.navigationItem.searchController = self.searchVC
//        } else {
            tableView.tableHeaderView = self.searchVC.searchBar
//        }
//        tableView.reloadData()
//        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)


//        self.searchVC.delegate = self
//
//        self.searchVC.searchBar.delegate = self

//         searchController.hidesNavigationBarDuringPresentation = true


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

    func bindData() {
        self.viewModel.tokenListRefreshDriver.asObservable().filterEmpty().map {[weak self](data) in
                self?.tokenListArray = data
                var sectionModels = Array<SectionModel<String,TokenInfo>>()
                for item in data {
                    sectionModels.append(SectionModel(model: item[0].coinType.rawValue, items: item))
                }
                return sectionModels
            }.bind(to:tableView.rx.items(dataSource: self.dataSource)).disposed(by: rx.disposeBag)

        self.viewModel.tokenListRefreshDriver.asObservable()
        .filterEmpty().throttle(0.5, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self]  _ in
                self?.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }).disposed(by: rx.disposeBag)

        tableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension TokenListManageController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView)  {

    }
}


extension TokenListManageController : UITableViewDelegate {



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
extension TokenListManageController: ViewControllerDataStatusable {

    func networkErrorView(error: Error, retry: @escaping () -> Void) -> UIView {
        return UIView.defaultNetworkErrorView(error: error) { [weak self] in
            self?.view.displayLoading()
            retry()
        }
    }
    func emptyView() -> UIView {
        return UIView.defaultPlaceholderView(text: R.string.localizable.transactionListPageEmpty())
    }
}
