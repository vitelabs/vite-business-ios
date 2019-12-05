//
//  DeFiSubscriptionViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/5.
//

import UIKit
import ViteWallet

class DeFiSubscriptionViewController: BaseScrollableViewController {

    let productHash: String

    init(productHash: String) {
        self.productHash = productHash
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()


    }
}
