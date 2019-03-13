//
//  ShareSlateViewController.swift
//  Pods
//
//  Created by haoshenyang on 2019/3/12.
//

import UIKit
import Vite_GrinWallet

class SlateViewController: UIViewController {

    @IBOutlet weak var statusImageView: UIImageView!

    @IBOutlet weak var slateIdLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    var slate: Slate?


    var document: UIDocumentInteractionController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func handleSlate(_ sender: Any) {
//        guard let slate = slate else {
//            return
//        }

        let url = GrinManager.default.getSlateUrl(slateId: "00117c3a-6c7c-44c3-8ae1-2080e4f5e02d", isResponse: false)
        try? "123456".write(to: url, atomically: true, encoding: .utf8)
        if !FileManager.default.fileExists(atPath: url.path) {
           try? "123456".write(to: url, atomically: true, encoding: .utf8)
        }
         document = UIDocumentInteractionController.init(url: url)
        document.presentOpenInMenu(from: self.view.bounds, in: self.view, animated: true)

    }

}
