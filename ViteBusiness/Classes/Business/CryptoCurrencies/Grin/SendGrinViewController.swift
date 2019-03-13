//
//  SendGrinViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/3/11.
//

import UIKit
import Vite_GrinWallet

class SendGrinViewController: UIViewController {

    @IBOutlet weak var spendableLabel: UILabel!

    @IBOutlet weak var addressLabel: UITextField!

    @IBOutlet weak var amountConstraint: NSLayoutConstraint!

    let grinBridge =  GrinManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func sendAction(_ sender: Any) {


        let podBundle = Bundle(for: GrinInfoViewController.self)
        let url = podBundle.url(forResource: "ViteBusiness", withExtension: "bundle")
        let resourceBundle = Bundle.init(url: url!)
        let vc = SlateViewController.init(nibName: "SlateViewController", bundle: resourceBundle)
//        vc.slate = slate
        self.navigationController?.pushViewController(vc, animated: true)

        return
        let result = grinBridge.txCreate(amount: 1, selectionStrategyIsUseAll: true, message: "")
        switch result {
        case .success(let slate):
            print(slate)
            
            let ulr = grinBridge.getSlateUrl(slateId: slate.id, isResponse: false)
            try? slate.toJSONString()?.write(to: ulr, atomically: true, encoding: .utf8)

            let podBundle = Bundle(for: GrinInfoViewController.self)
            let url = podBundle.url(forResource: "ViteBusiness", withExtension: "bundle")
            let resourceBundle = Bundle.init(url: url!)
            let vc = SlateViewController.init(nibName: "SlateViewController", bundle: resourceBundle)
            vc.slate = slate
            self.navigationController?.pushViewController(vc, animated: true)
        case .failure( let error):
            print(error)
        }
        
    }

}
