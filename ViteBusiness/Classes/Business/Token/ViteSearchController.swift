//
//  ViteSearchController.swift
//  ViteBusiness
//
//  Created by Water on 2019/3/12.
//

class ViteSearchController: UISearchController {
    override var isActive: Bool {
        didSet {
            self.reallySearchBar.isActive = isActive
        }
    }

    fileprivate lazy var reallySearchBar = ViteSearchBar()

    var alwaysHiddenCancelButton: Bool = true {
        didSet {
            reallySearchBar.alwaysHiddenCancelButton = alwaysHiddenCancelButton
        }
    }
    override var searchBar: UISearchBar {
        return reallySearchBar
    }

   
}
