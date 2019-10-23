//
//  MarketSearchViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/10/16.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx
import RxDataSources

class MarketSearchViewController: UIViewController {

    var onSelectInfo: ((MarketInfo) -> ())?

    lazy var searchResultVC = MarketSearchResultViewController().then {
        $0.originalData = self.originalData
        $0.onSelectInfo = self.onSelectInfo
    }

    lazy var searchVC : UISearchController? = {[weak self] in
       let searchVC = UISearchController(searchResultsController:self?.searchResultVC)
       searchVC.searchResultsUpdater = self?.searchResultVC

       if #available(iOS 13.0, *) {
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = R.string.localizable.cancel()
       } else {
           let cancelButton = searchVC.searchBar.value(forKey: "cancelButtonText") as? UIButton
           cancelButton?.setTitle(R.string.localizable.cancel(),for:.normal)
           cancelButton?.setTitle(R.string.localizable.cancel(),for:.highlighted)
       }

       let searchField = searchVC.searchBar.value(forKey: "searchField") as? UITextField
       searchField?.background = nil
       searchField?.backgroundColor = .clear

       let placeholderAttributes = [NSAttributedString.Key.font: Fonts.Font13,
                                        NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x24272B, alpha: 0.31)]

       let attributedPlaceholder = NSAttributedString(string: "Search",
                                                      attributes: placeholderAttributes)
        searchField?.attributedPlaceholder = attributedPlaceholder


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

    lazy var tableView = UITableView.listView().then { (tableView) in
        view.addSubview(tableView)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 50
        tableView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
            m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
        }
        tableView.register(MarketSearchResultTableViewCell.self, forCellReuseIdentifier: "MarketSearchResultTableViewCell")

        tableView.delegate = self
        tableView.dataSource = self
    }

    lazy var deletHistoryButton = UIButton(type: .custom).then {(ignoreBtn) in
        ignoreBtn.setBackgroundImage(R.image.market_history_delet(), for: .normal)
    }

    lazy var historyTitleHeaderView: UIView = {
        let contentView = UIView()
         contentView.backgroundColor = .white

         var lab = UILabel().then {(lab) in
             lab.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
             lab.numberOfLines = 0
             lab.textAlignment = .left
             lab.textColor = UIColor.init(netHex: 0x3E4A59)
            lab.text =  R.string.localizable.marketSearchhistory()
         }

         contentView.addSubview(lab)
         contentView.addSubview(deletHistoryButton)

         lab.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(18)
        }

         deletHistoryButton.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-18)
            m.centerY.equalToSuperview()
        }
         return contentView
    }()

    var history: [(MarketInfo, Bool)] = []
    var originalData: [MarketData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        tableView.tableHeaderView = self.searchVC?.searchBar
        deletHistoryButton.rx.tap.bind{ [unowned self] _ in
            MarketCache.deletSearchHistory()
            self.reloadHistory()
        }.disposed(by: rx.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadHistory()
    }

    func reloadHistory() {
        let keys = MarketCache.readSearchHistory()
        var datas: [MarketInfo] = []
        for data in originalData {
            for i in data.infos where keys.contains(i.statistic.symbol) {
                datas.append(i)
            }
        }
        let favourite = MarketCache.readFavourite()
        self.history = datas.map({
            ($0 , favourite.contains($0.statistic.symbol ?? ""))
        })
        tableView.reloadData()
    }

    @objc func handleFavoureite(sender: UIButton) {
        let index = sender.tag
        let (info, favourite ) = self.history[index]
        if favourite {
            MarketCache.deletFavourite(data: info.statistic.symbol)
        } else {
            MarketCache.saveFavourite(data: info.statistic.symbol)
        }
        self.reloadHistory()
    }

}

extension MarketSearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarketSearchResultTableViewCell", for: indexPath) as! MarketSearchResultTableViewCell
        let info = self.history[indexPath.row]
        cell.bind(info)
        cell.favouriteButton.tag = indexPath.row
        cell.favouriteButton.removeTarget(nil, action: nil, for: .touchUpInside)
        cell.favouriteButton.addTarget(self, action: #selector(handleFavoureite(sender:)), for: .touchUpInside)
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.historyTitleHeaderView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let (info, _) = self.history[indexPath.row]
        self.onSelectInfo?(info)
    }
}

extension MarketSearchViewController : UISearchControllerDelegate , UISearchBarDelegate {

    func didDismissSearchController(_ searchController: UISearchController) {
        self.reloadHistory()
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        self.searchVC?.isActive = true
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        self.searchVC?.isActive = false
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
}
