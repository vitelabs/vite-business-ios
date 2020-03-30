//
//  SpotViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit

class SpotViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


//        tableView.head


    }

    func makeHeaderView() -> UIView {
        let view = UIView()


        view.frame = CGRect(x: 0, y: 0, width: 0, height: 300)
        view.backgroundColor = .red
        return view
    }
}
