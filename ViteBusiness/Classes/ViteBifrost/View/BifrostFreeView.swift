//
//  BifrostFreeView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import UIKit

class BifrostFreeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        let imageView = UIImageView(image: R.image.icon_vb_placeholder_free())
        let headerLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x24272B)
            $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        let contentLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x24272B, alpha: 0.6)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        let addressLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x24272B, alpha: 0.6)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        let countButton = UIButton().then {
            $0.setTitleColor(.black, for: .normal)
        }
        let autoConfirmSwitch = UISwitch()

        headerLabel.text = R.string.localizable.bifrostHomePageFreeHeader()
        contentLabel.text = R.string.localizable.bifrostHomePageFreeContent()

        addSubview(imageView)
        addSubview(headerLabel)
        addSubview(contentLabel)

        imageView.snp.makeConstraints { (m) in
            m.top.centerX.equalToSuperview()
        }

        headerLabel.snp.makeConstraints { (m) in
            m.top.equalTo(imageView.snp.bottom).offset(20)
            m.left.equalToSuperview().offset(15)
            m.right.equalToSuperview().offset(-15)
        }

        contentLabel.snp.makeConstraints { (m) in
            m.top.equalTo(headerLabel.snp.bottom).offset(10)
            m.left.equalToSuperview().offset(15)
            m.right.equalToSuperview().offset(-15)
            m.bottom.equalToSuperview()
        }

        addSubview(addressLabel)
        addSubview(countButton)
        addSubview(autoConfirmSwitch)

        addressLabel.snp.makeConstraints { (m) in
            m.top.equalTo(imageView)
            m.left.right.equalToSuperview()
        }

        countButton.snp.makeConstraints { (m) in
            m.top.equalTo(addressLabel.snp.bottom).offset(10)
            m.left.right.equalToSuperview()
        }

        autoConfirmSwitch.snp.makeConstraints { (m) in
            m.top.equalTo(countButton.snp.bottom).offset(10)
            m.centerX.equalToSuperview()
        }

        countButton.setTitle("dsfsdfs", for: .normal)
        countButton.backgroundColor = .red
        HDWalletManager.instance.accountDriver.map{ $0?.address }.drive(addressLabel.rx.text).disposed(by: rx.disposeBag)

        BifrostManager.instance.allTasksDriver.map{ "\($0.count)" }.drive(countButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)

        BifrostManager.instance.isAutoConfirmBehaviorRelay.asDriver().drive(autoConfirmSwitch.rx.isOn).disposed(by: rx.disposeBag)

        countButton.rx.tap.bind {
            let vc = BifrostTaskListViewController()
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)


        autoConfirmSwitch.rx.value.skip(1).bind { [weak self] isOn in
            if isOn {
                self?.showConfirm(completion: { (ret) in
                    if ret {
                        BifrostManager.instance.isAutoConfirmBehaviorRelay.accept(true)
                    } else {
                        BifrostManager.instance.isAutoConfirmBehaviorRelay.accept(false)
                    }
                })
            } else {
                BifrostManager.instance.isAutoConfirmBehaviorRelay.accept(false)
            }
        }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func showConfirm(completion: @escaping (Bool) -> ()) {
        func showConfirm() {
            BifrostConfirmView(title: "dsfsdfs") { (ret) in
                switch ret {
                case .biometryAuthFailed:
                    Alert.show(title: R.string.localizable.workflowConfirmPageBiometryAuthFailedTitle(), message: nil,
                               titles: [.default(title: R.string.localizable.workflowConfirmPageBiometryAuthFailedBack())])
                    completion(false)
                case .passwordAuthFailed:
                    Alert.show(title: R.string.localizable.workflowConfirmPageToastPasswordError(), message: nil,
                               titles: [.default(title: R.string.localizable.workflowConfirmPagePasswordAuthFailedRetry())],
                               handler: { _, _ in showConfirm() })
                case .cancelled:
                    completion(false)
                case .success:
                    completion(true)
                }
                }.show()
        }
        showConfirm()
    }
}
