//
//  ContactsListViewController.swift
//  Vite
//
//  Created by Stone on 2018/9/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources

class ContactsListViewController: BaseTableViewController {

    

    init(viewModel: ContactsListViewModel) {
        super.init(.plain)
        view.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
