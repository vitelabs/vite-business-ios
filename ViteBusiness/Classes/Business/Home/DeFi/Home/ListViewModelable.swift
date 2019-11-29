//
//  ListViewModelable.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/29.
//

import RxSwift
import RxDataSources

protocol ListCellable {

}



class ListViewModel<Model, Cell: UITableViewCell>: NSObject, UITableViewDelegate, UITableViewDataSource where Cell: ListCellable {
    let tableView: UITableView

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()

        tableView.delegate = self
        tableView.dataSource = self
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DeFiHomeProductCell.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(for: indexPath)
        //        cell.bind(viewModel: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
