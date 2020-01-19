//
//  MarketSearchResultViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/10/16.
//

import UIKit

class MarketSearchResultViewController: UIViewController, UISearchResultsUpdating {

    var originalData: [MarketData]!
    var result: [(MarketInfo, Bool)] = []
    var onSelectInfo: ((MarketInfo) -> ())?


    lazy var tableView = UITableView.listView().then { (tableView) in
        view.addSubview(tableView)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 50
        tableView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
            m.top.equalTo(view.snp.top).offset(-44)
        }
        tableView.register(MarketSearchResultTableViewCell.self, forCellReuseIdentifier: "MarketSearchResultTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc func handleFavoureite(sender: UIButton) {
        let index = sender.tag
        let (info, favourite ) = self.result[index]
        if favourite {
            MarketCache.deletFavourite(data: info.statistic.symbol)
        } else {
            MarketCache.saveFavourite(data: info.statistic.symbol)
        }
        let readFavourite = MarketCache.readFavourite()
        self.result = result.map({
            ($0.0 , readFavourite.contains($0.0.statistic.symbol ?? ""))
        })
        tableView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        let key = searchController.searchBar.text ?? ""

        var datas: [MarketInfo] = []
        for data in originalData {
            for i in data.infos
                where i.statistic.symbol.lowercased().contains(key.lowercased())  {
                datas.append(i)
            }
        }
        let favourite = MarketCache.readFavourite()
        self.result = datas.map({
            ($0 , favourite.contains($0.statistic.symbol ?? ""))
        })
        tableView.reloadData()
    }

}

extension MarketSearchResultViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.set(empty: result.count == 0)
        return result.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarketSearchResultTableViewCell", for: indexPath) as! MarketSearchResultTableViewCell
        let info = self.result[indexPath.row]
       cell.bind(info)
       cell.favouriteButton.tag = indexPath.row
       cell.favouriteButton.removeTarget(nil, action: nil, for: .touchUpInside)
       cell.favouriteButton.addTarget(self, action: #selector(handleFavoureite(sender:)), for: .touchUpInside)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let (info, _) = self.result[indexPath.row]
        MarketCache.saveSearchHistory(data: info.statistic.symbol)
        self.onSelectInfo?(info)
    }

}
