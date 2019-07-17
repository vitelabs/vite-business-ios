//
//  BifrostViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/11.
//

import UIKit

class BifrostViewController: BaseViewController {

    let confirmResult: ((Bool, BifrostViteSendTxTask, BifrostViewController) -> Void)
    init(result: @escaping (Bool, BifrostViteSendTxTask, BifrostViewController) -> Void) {
        confirmResult = result
        super.init(nibName: nil, bundle: nil)
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupView() {
        navigationBarStyle = .custom(tintColor: UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45), backgroundColor: UIColor.clear)
        view.backgroundColor = UIColor(netHex: 0xF5FAFF)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_button_vb_disconnect(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(onDisconnect))


        view.addSubview(freeView)
        freeView.snp.makeConstraints { (m) in
            m.centerY.left.right.equalToSuperview()
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Statistics.log(eventId: Statistics.Page.WalletHome.bifrostReturn.rawValue)
    }

    @objc fileprivate func onDisconnect() {
        Statistics.log(eventId: Statistics.Page.WalletHome.bifrostDis.rawValue)
        Alert.show(title: R.string.localizable.bifrostAlertQuitTitle(),
                   message: nil,
                   actions: [
                    (.cancel, nil),
                    (.default(title: R.string.localizable.quit()), { _ in
                        BifrostManager.instance.disConnect()
                        Statistics.log(eventId: Statistics.Page.WalletHome.bifrostDisConfirm.rawValue)
                    })
            ])
    }


    let freeView = BifrostFreeView()
    var busyView: BifrostBusyView?


    func showConfirmIfNeeded() {
        guard self.busyView == nil else { return }

        if let task = BifrostManager.instance.currectTask {
            let busyView = BifrostBusyView()
            busyView.backgroundColor = UIColor(netHex: 0xF5FAFF)
            view.addSubview(busyView)
            busyView.snp.makeConstraints { (m) in
                m.left.right.equalToSuperview()
                m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
                m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
            }
            busyView.set(task.info)

            busyView.cancelButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                plog(level: .debug, log: "xxxxx cancelButton")
                self.confirmResult(false, task, self)
                }.disposed(by: busyView.rx.disposeBag)

            busyView.confirmButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                plog(level: .debug, log: "xxxxx confirmButton")
                self.confirmResult(true, task, self)
                }.disposed(by: busyView.rx.disposeBag)
            self.busyView = busyView
        }
    }

    func hideConfirm() {
        self.busyView?.removeFromSuperview()
        self.busyView = nil
    }
}
