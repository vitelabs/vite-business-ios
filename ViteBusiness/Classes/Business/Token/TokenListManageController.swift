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
import MLeaksFinder

typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TokenInfo>>

class TokenListManageController: BaseViewController {
    var viewModel : TokenListManageViewModel

    init() {
        viewModel = TokenListManageViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        tableView.register(NewAssetTokenCell.self, forCellReuseIdentifier: "NewAssetTokenCell")
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
            configureCell: {[weak self](_, tableView, indexPath, item) ->
                UITableViewCell in
                guard let `self` = self else {
                    return UITableViewCell()
                }

                if self.viewModel.isHasNewAssetTokens() && indexPath.section == 0 {
                    let cell: NewAssetTokenCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.delegate = self
                    cell.reloadData(item)
                    return cell
                }else {
                    let cell: TokenListInfoCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.reloadData(item)
                    return cell
                }
        } ,
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
        })
        self.viewModel.tokenListRefreshDriver.asObservable().filterEmpty().map {
                [weak self](data) in
                self?.tokenListArray = data
                var sectionModels = Array<SectionModel<String,TokenInfo>>()
                for item in data {
                    if !item.isEmpty {
                        sectionModels.append(SectionModel(model: item[0].coinType.rawValue, items: item))
                    }
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
        self.searchVC?.isActive = false
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
}
extension TokenListManageController : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       if self.viewModel.isHasNewAssetTokens() && section == 0 {
        let contentView = NewAssetTableSectionView()
        contentView.titleLab.lab.text = R.string.localizable.tokenListPageIgnoreLabTitle(self.viewModel.newAssetTokenCount())

        contentView.ignoreBtn.rx.tap.bind {[weak self] in
            guard let `self` = self else {
                return
            }

            Alert.show(title: R.string.localizable.tokenListPageIgnoreAlterTitle(), message: nil, actions: [
                (.default(title: R.string.localizable.cancel()), nil),
                (.default(title: R.string.localizable.confirm()), { _ in
                    NewAssetService.instance.handleCleanNewTip()
                    self.viewModel.refreshList()
                }),
                ])

        }.disposed(by: rx.disposeBag)
            return contentView
       }else {
            let contentView = TokenListInfoSectionView()
            contentView.titleLab.text = self.tokenListArray[section][0].getCoinHeaderDisplay()
            return contentView
        }
    }
}

extension TokenListManageController : NewAssetTokenCellDelegate {
    func refreshList() {
        self.viewModel.refreshList()
    }
}
