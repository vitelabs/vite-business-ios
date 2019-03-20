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
import MLeaksFinder

typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TokenInfo>>

class TokenListManageController: BaseViewController {
    let viewModel = TokenListManageViewModel()

    override func willDealloc() -> Bool {
        return false
    }

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
        print("======= TokenListManageController deinit")
    }

    fileprivate lazy var searchResultVC = TokenListSearchViewController()

    fileprivate lazy var placeholderAttributes = [NSAttributedString.Key.font: Fonts.Font13,
                                 NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x24272B, alpha: 0.31)]

    fileprivate lazy var attributedPlaceholder: NSAttributedString = NSAttributedString(string: R.string.localizable.tokenListPageSearchTitle(), attributes: self.placeholderAttributes)

    fileprivate lazy var searchVC : ViteSearchController? = {[weak self] in
        let
        searchVC = ViteSearchController(searchResultsController:self?.searchResultVC)
        searchVC.searchResultsUpdater = self?.searchResultVC

        let cancelButton = searchVC.searchBar.value(forKey: "cancelButtonText") as? UIButton
        cancelButton?.setTitle(R.string.localizable.cancel(),for:.normal)
        cancelButton?.setTitle(R.string.localizable.cancel(),for:.highlighted)

        let searchField = searchVC.searchBar.value(forKey: "searchField") as? UITextField
        searchField?.attributedPlaceholder = attributedPlaceholder
        searchField?.background = nil
        searchField?.backgroundColor = .clear

        searchVC.delegate = self
        searchVC.searchBar.returnKeyType = .done
        searchVC.searchBar.enablesReturnKeyAutomatically = false
        searchVC.searchBar.delegate = self
        searchVC.searchBar.tintColor = UIColor(netHex: 0x007AFF)
        searchVC.searchBar.barTintColor = .white
        searchVC.searchBar.layer.borderColor = UIColor.white.cgColor
        searchVC.searchBar.backgroundImage = R.image.icon_background()?.resizable
        searchVC.dimsBackgroundDuringPresentation = false
        searchVC.definesPresentationContext = true

        return searchVC
    }()

    func setupUI() {
         self.definesPresentationContext = true
        tableView.tableHeaderView = self.searchVC?.searchBar
    }

    var tokenListArray : TokenListArray = TokenListArray()

    func bindData() {
        let dataSource = DataSource(
            configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
                let cell: TokenListInfoCell = tableView.dequeueReusableCell(for: indexPath)
                cell.reloadData(item)
                return cell
        } ,
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
        })
        self.viewModel.tokenListRefreshDriver.asObservable().filterEmpty().map {
                [weak self](data) in
                self?.tokenListArray = data
                var sectionModels = Array<SectionModel<String,TokenInfo>>()
                for item in data {
                    sectionModels.append(SectionModel(model: item[0].coinType.rawValue, items: item))
                }
                return sectionModels
            }.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

        tableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.searchVC?.searchResultsUpdater = nil
        self.searchVC?.searchBar.delegate = nil
        self.searchVC?.delegate = nil
        self.searchVC = nil
    }
}

extension TokenListManageController : UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        self.searchVC?.isActive = false
    }
    func willDismissSearchController(_ searchController: UISearchController) {
        self.viewModel.refreshList()
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        self.searchVC?.isActive = true
    }
}

extension TokenListManageController : UISearchBarDelegate {
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
//        searchBar.text = ""
        self.searchVC?.isActive = false
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
//        searchBar.text = ""
//        self.searchVC?.dismiss(animated: true, completion: nil)
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
