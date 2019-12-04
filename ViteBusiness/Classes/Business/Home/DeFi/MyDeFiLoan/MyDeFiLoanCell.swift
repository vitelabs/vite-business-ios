//
//  MyDeFiLoanCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import UIKit

class MyDeFiLoanCell: BaseTableViewCell, ListCellable {
    typealias Model = DeFiLoan

    static var cellHeight: CGFloat {
        return 160
    }

    func bind(_ item: DeFiLoan) {
        textLabel?.text = "123"
    }

}
