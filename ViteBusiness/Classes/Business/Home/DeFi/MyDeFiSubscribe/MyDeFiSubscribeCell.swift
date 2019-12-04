//
//  MyDeFiSubscribeCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import UIKit

class MyDeFiSubscribeCell: BaseTableViewCell, ListCellable {
    typealias Model = DeFiSubscription

    static var cellHeight: CGFloat {
        return 150
    }

    func bind(_ item: DeFiSubscription) {
        textLabel?.text = "456"
    }
}
