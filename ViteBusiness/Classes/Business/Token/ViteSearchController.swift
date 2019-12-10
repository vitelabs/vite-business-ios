//
//  ViteSearchController.swift
//  ViteBusiness
//
//  Created by Water on 2019/3/12.
//

class ViteSearchController: UISearchController {

    fileprivate lazy var reallySearchBar = UISearchBar()

    override var searchBar: UISearchBar {
        return reallySearchBar
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isActive = false
    }
}
