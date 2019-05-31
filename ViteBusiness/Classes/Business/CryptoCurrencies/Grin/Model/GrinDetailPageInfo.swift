//
//  GrinDetailPageInfo.swift
//  Action
//
//  Created by haoshenyang on 2019/5/9.
//

import Foundation

class GrinDetailPageInfo {

    var title: String = ""
    var methodString: String? = nil
    var desc: String? = nil
    var amount: String? = nil
    var fee: String? = nil
    var trueAmount: String? = nil

    var cellInfo:[GrinDetailCellInfo] = []

    var actions: [(String, ()->())] = []

}

class GrinDetailCellInfo {
    var isTitle = false
    var slateId: String?
    var statusImage: UIImage?
    var lineImage: UIImage?
    var statusAttributeStr: NSAttributedString?
    var timeStr: String?
}


class GrinHeightInfo {
    var beginHeight = 0
    var lastConfirmedHeight = 0
}

