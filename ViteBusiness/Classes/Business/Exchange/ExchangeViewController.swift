//
//  ExchangeViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/7/25.
//

import UIKit

class ExchangeViewController: BaseViewController {

    let vm = ExchangeViewModel()
    


    override func viewDidLoad() {
        super.viewDidLoad()

        vm.action.onNext(.getHistory(pageSize: 10, pageNumber: 1))
        vm.action.onNext(.getRate)
        vm.action.onNext(.report(hash: ""))
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
