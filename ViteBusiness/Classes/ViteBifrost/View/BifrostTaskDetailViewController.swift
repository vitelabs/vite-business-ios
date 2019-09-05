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
        navigationBarStyle = .custom(tintColor: UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45), backgroundColor: UIColor.clear)
        view.backgroundColor = UIColor(netHex: 0xF5FAFF)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_button_vb_disconnect(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(onDisconnect))
        let busyView = BifrostBusyView(showButton: false)
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

    @objc fileprivate func onDisconnect() {
        Statistics.log(eventId: Statistics.Page.WalletHome.bifrostDis.rawValue)
        Alert.show(title: R.string.localizable.bifrostAlertQuitTitle(),
                   message: nil,
                   actions: [
                    (.cancel, nil),
                    (.default(title: R.string.localizable.quit()), { _ in
                        BifrostManager.instance.disConnectByUser()
                        Statistics.log(eventId: Statistics.Page.WalletHome.bifrostDisConfirm.rawValue)
                    })
            ])
    }
}
