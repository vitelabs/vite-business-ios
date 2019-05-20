//
//  ConfigGrinNodeVM.swift
//  Action
//
//  Created by haoshenyang on 2019/5/17.
//

import UIKit

class ConfigGrinNodeVM: NSObject {

    override init() {

    }

    let viteNode = GrinManager.default.viteGrinNode

    lazy var nodes: [[GrinNode]] = {
        let viteNode = [self.viteNode]
        let customnNodes = GrinLocalInfoService.shared.getNodeAddress()
        self.viteNode.seleted =  customnNodes.contains(where: { (node) -> Bool in
            node.seleted == true
        })
        return [viteNode,customnNodes]
    }()


    


//    let nodes:
}
