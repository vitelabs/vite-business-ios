//
//  BifrostTaskDetailViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/9/4.
//

import UIKit
import RxOptional

class BifrostTaskDetailViewController: BaseViewController {

    let task: BifrostViteSendTxTask
    init(task: BifrostViteSendTxTask) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let busyView = BifrostBusyView()
        busyView.headerLabel.text = R.string.localizable.bifrostTaskDetailPageBusyHeader()
        busyView.backgroundColor = UIColor(netHex: 0xF5FAFF)
        view.addSubview(busyView)
        busyView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }

        let id = task.id
        BifrostManager.instance.allTasksDriver
            .map({ tasks -> BifrostViteSendTxTask? in
                for task in tasks where task.id == id {
                    return task
                }
                return nil
            }).filterNil()
            .drive(onNext: { task in
                busyView.set(task.info)
                busyView.contentLabel.text = task.statusDescription
            }).disposed(by: rx.disposeBag)
    }
}
