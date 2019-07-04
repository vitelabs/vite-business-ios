//
//  BifrostViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/11.
//

import UIKit

class BifrostViewController: BaseViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
        bind()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let freeView = BifrostFreeView()
    let busyView = BifrostBusyView()

    fileprivate func setupView() {
        navigationBarStyle = .custom(tintColor: UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45), backgroundColor: UIColor.clear)
        view.backgroundColor = UIColor(netHex: 0xF5FAFF)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_button_vb_disconnect(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(onDisconnect))


        view.addSubview(freeView)
        freeView.snp.makeConstraints { (m) in
            m.centerY.left.right.equalToSuperview()
        }

        view.addSubview(busyView)
        busyView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        freeView.isHidden = false
        busyView.isHidden = true
//
//        let item1 = BifrostConfrimItemInfo(title: "订单类型", value: "买ABC", valueColor: .red, backgroundColor: UIColor(netHex: 0x007AFF, alpha: 0.06))
//        let item2 = BifrostConfrimItemInfo(title: "价格", value: "1000000", valueColor: nil, backgroundColor: nil)
//
//        let info = BifrostConfrimInfo(title: "交易所挂单", items: [item1, item2,item1, item2,item2,item1,item1,item2])
//
//        busyView.set(info)
    }

    fileprivate func bind() {

        busyView.cancelButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            guard let block = self.confrimResult else { return }
            block(false, self)
        }.disposed(by: rx.disposeBag)

        busyView.confrimButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            guard let block = self.confrimResult else { return }
            block(true, self)
        }.disposed(by: rx.disposeBag)
    }

    @objc fileprivate func onDisconnect() {
        BifrostManager.instance.disConnect()
    }


    var confrimResult: ((Bool, BifrostViewController) -> Void)?

    func showConfrim(_ info: BifrostConfrimInfo, result: @escaping (Bool, BifrostViewController) -> Void) {
        freeView.isHidden = true
        busyView.isHidden = false
        busyView.set(info)
        confrimResult = result
    }

    func hideConfrim() {
        self.confrimResult = nil
        self.freeView.isHidden = false
        self.busyView.isHidden = true
    }
}
