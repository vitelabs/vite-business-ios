//
//  BifrostFreeView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import UIKit

class BifrostFreeView: UIView {

    fileprivate let bottomView = BottomView()

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

        headerLabel.text = R.string.localizable.bifrostHomePageFreeHeader()
        contentLabel.text = R.string.localizable.bifrostHomePageFreeContent()

        addSubview(imageView)
        addSubview(headerLabel)
        addSubview(contentLabel)
        addSubview(bottomView)

        let layout = UILayoutGuide()
        addLayoutGuide(layout)
        layout.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
        }

        imageView.snp.makeConstraints { (m) in
            m.center.equalTo(layout)
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
        }

        bottomView.snp.makeConstraints { (m) in
            m.top.equalTo(layout.snp.bottom)
            m.left.right.bottom.equalToSuperview()
        }

        HDWalletManager.instance.accountDriver.map{ $0?.address }.drive(bottomView.addressLabel.rx.text).disposed(by: rx.disposeBag)

        BifrostManager.instance.allTasksDriver.map{ "\($0.count)" }.drive(bottomView.countButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)

        BifrostManager.instance.isAutoConfirmBehaviorRelay.asDriver().drive(onNext: { [weak self] (isOn) in
            self?.bottomView.autoConfirmSwitch.on = isOn
        }).disposed(by: rx.disposeBag)

        bottomView.countButton.rx.tap.bind {
            let vc = BifrostTaskListViewController()
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        bottomView.autoConfirmSwitch.rx.controlEvent([.valueChanged]).bind { [weak self] in
            guard let `self` = self else { return }
            if self.bottomView.autoConfirmSwitch.on {
                self.showConfirm(completion: { (ret) in
                    if ret {
                        BifrostManager.instance.isAutoConfirmBehaviorRelay.accept(true)
                    } else {
                        BifrostManager.instance.isAutoConfirmBehaviorRelay.accept(false)
                    }
                })
            } else {
                BifrostManager.instance.isAutoConfirmBehaviorRelay.accept(false)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func showConfirm(completion: @escaping (Bool) -> ()) {
        func showConfirm() {
            BifrostConfirmView(title: R.string.localizable.bifrostHomePageFreeAutoSignConfrimTitle()) { (ret) in
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

extension BifrostFreeView {
    class BottomView: UIView {

        let addressTitleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.text = R.string.localizable.bifrostHomePageFreeAddressTitle()
        }

        let addressLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.numberOfLines = 2
        }

        let historyTitleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.text = R.string.localizable.bifrostHomePageFreeHistoryTitle()
        }

        let autoSignTitleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.text = R.string.localizable.bifrostHomePageFreeAutoSignTitle()
        }

        let countButton = UIButton().then {
            let image = R.image.icon_bifrost_right_arrow()?.tintColor(UIColor(netHex: 0x3E4A59, alpha: 0.45))
            $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.7), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.7).highlighted, for: .highlighted)
            $0.setImage(image, for: .normal)
            $0.setImage(image?.highlighted, for: .highlighted)
            $0.transform = CGAffineTransform(scaleX: -1, y: 1)
            $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
            $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 40)
        }

        let autoConfirmSwitch = SwitchControl.createSwitchControl()

        override init(frame: CGRect) {
            super.init(frame: frame)

            backgroundColor = .white
            layer.shadowColor = UIColor(netHex: 0x000000, alpha: 0.1).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowRadius = 10

            let cellView: () -> UIView = {
                let view = UIView()
                let separatorLine = UIView().then {
                    $0.backgroundColor = Colors.lineGray
                }
                view.addSubview(separatorLine)
                separatorLine.snp.makeConstraints { (m) in
                    m.height.equalTo(CGFloat.singleLineWidth)
                    m.left.equalToSuperview().offset(24)
                    m.right.equalToSuperview().offset(-24)
                    m.bottom.equalToSuperview()
                }

                view.snp.makeConstraints({ (m) in
                    m.height.equalTo(58)
                })

                return view
            }

            let addressBackView = UIView().then {
                $0.backgroundColor = UIColor(netHex: 0x007AFF).withAlphaComponent(0.06)
                $0.layer.borderColor = UIColor(netHex: 0x007AFF).withAlphaComponent(0.12).cgColor
                $0.layer.borderWidth = CGFloat.singleLineWidth
            }

            let historyCellView = cellView()
            let autoSignCellView = cellView()

            addSubview(addressTitleLabel)
            addSubview(addressBackView)
            addSubview(addressLabel)
            addSubview(historyCellView)
            historyCellView.addSubview(historyTitleLabel)
            historyCellView.addSubview(countButton)
            addSubview(autoSignCellView)
            autoSignCellView.addSubview(autoSignTitleLabel)
            autoSignCellView.addSubview(autoConfirmSwitch)

            addressTitleLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(16)
                m.left.equalToSuperview().offset(24)
            }

            addressBackView.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(50)
                m.left.right.equalToSuperview()
                m.height.equalTo(68)
            }

            addressLabel.snp.makeConstraints { (m) in
                m.left.right.equalToSuperview().inset(24)
                m.centerY.equalTo(addressBackView)
            }

            historyCellView.snp.makeConstraints { (m) in
                m.left.right.equalToSuperview()
                m.top.equalTo(addressBackView.snp.bottom)
            }

            autoSignCellView.snp.makeConstraints { (m) in
                m.left.right.equalToSuperview()
                m.top.equalTo(historyCellView.snp.bottom)
                m.bottom.equalTo(self.safeAreaLayoutGuideSnpBottom).offset(-36)
            }

            historyTitleLabel.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.left.equalToSuperview().offset(24)
            }

            countButton.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.right.equalToSuperview().offset(-24)
            }

            autoSignTitleLabel.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.left.equalToSuperview().offset(24)
            }

            autoConfirmSwitch.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.right.equalToSuperview().offset(-24)
                m.size.equalTo(CGSize(width: 37, height: 20))
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
