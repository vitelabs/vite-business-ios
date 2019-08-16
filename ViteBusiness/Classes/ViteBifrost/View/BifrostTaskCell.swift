//
//  BifrostTaskCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/20.
//

import UIKit

class BifrostTaskCell: BaseTableViewCell {

    static var cellHeight: CGFloat {
        return 86
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
