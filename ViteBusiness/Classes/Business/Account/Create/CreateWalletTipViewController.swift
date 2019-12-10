//
//  CreateWalletTipViewController.swift
//  Vite
//
//  Created by Water on 2018/9/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import Vite_HDWalletKit
import ActiveLabel
import RxSwift
import RxCocoa

class CreateWalletTipViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
}

extension CreateWalletTipViewController {
    func setupView() {
        self.view.backgroundColor = .white
        navigationTitleView = NavigationTitleView(title: R.string.localizable.createPageTipTitle())

        let scrollView = ScrollableView(insets: UIEdgeInsets(top: 2, left: 24, bottom: 24, right: 24)).then {
            if #available(iOS 11.0, *) {
                $0.contentInsetAdjustmentBehavior = .never
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
        }

        let skipButton = UIButton(style: .whiteWithShadow, title: R.string.localizable.createPageTipButtonSkipTitle())
        let backupButton = UIButton(style: .blue, title: R.string.localizable.createPageTipButtonNextTitle())

        let checkButton1 = BackupMnemonicViewController.ConfirmView().then { view in
            view.label.text = R.string.localizable.mnemonicBackupPageCheckButton1Title()
            let customType = ActiveType.custom(pattern: view.label.text!)
            view.label.enabledTypes = [customType]
            view.label.customize { [weak view] label in
                label.customColor[customType] = view?.label.textColor
                label.customSelectedColor[customType] = view?.label.textColor
                label.handleCustomTap(for: customType) { [weak view] element in
                    view?.checkButton.isSelected = !(view?.checkButton.isSelected ?? true)
                }
            }
        }


        let checkButton2 = BackupMnemonicViewController.ConfirmView().then { view in
            view.label.text = R.string.localizable.mnemonicBackupPageCheckButton2Title()
            let customType = ActiveType.custom(pattern: view.label.text!)
            view.label.enabledTypes = [customType]
            view.label.customize { [weak view] label in
                label.customColor[customType] = view?.label.textColor
                label.customSelectedColor[customType] = view?.label.textColor
                label.handleCustomTap(for: customType) { [weak view] element in
                    view?.checkButton.isSelected = !(view?.checkButton.isSelected ?? true)
                }
            }
        }

        #if DEBUG
        checkButton1.checkButton.isSelected = true
        checkButton2.checkButton.isSelected = true
        #endif

        view.addSubview(scrollView)
        view.addSubview(skipButton)
        view.addSubview(backupButton)

        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)
        }

        skipButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(scrollView.snp.bottom)
            make.left.equalTo(view).offset(24)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }

        backupButton.snp.makeConstraints { (make) -> Void in
            make.top.bottom.width.height.equalTo(skipButton)
            make.left.equalTo(skipButton.snp.right).offset(23)
            make.right.equalTo(view).offset(-24)
        }

        scrollView.stackView.addArrangedSubview(TipTextView(text: R.string.localizable.createPageTipContent1()))
        scrollView.stackView.addPlaceholder(height: 4)
        scrollView.stackView.addArrangedSubview(TipTextView(text: R.string.localizable.createPageTipContent2()))
        scrollView.stackView.addPlaceholder(height: 8)
        scrollView.stackView.addArrangedSubview(TipTextView(text: R.string.localizable.createPageTipContent3()))
        scrollView.stackView.addPlaceholder(height: 30)
        scrollView.stackView.addArrangedSubview(UIImageView(image: R.image.beifen()).centerX())
        scrollView.stackView.addPlaceholder(height: 30)
        scrollView.stackView.addArrangedSubview(checkButton1)
        scrollView.stackView.addPlaceholder(height: 6)
        scrollView.stackView.addArrangedSubview(checkButton2)


        skipButton.rx.tap.bind {
            CreateWalletService.sharedInstance.generateMnemonic()
            CreateWalletService.sharedInstance.createWallet(isBackedUp: false)
        }.disposed(by: rx.disposeBag)

        backupButton.rx.tap.bind {
            let backupMnemonicCashVC = BackupMnemonicViewController(password: nil)
            UIViewController.current?.navigationController?.pushViewController(backupMnemonicCashVC, animated: true)
        }.disposed(by: rx.disposeBag)

        Driver.combineLatest(
            checkButton1.checkButton.rx.observeWeakly(Bool.self, #keyPath(UIButton.isSelected)).asDriver(onErrorJustReturn: false),
            checkButton2.checkButton.rx.observeWeakly(Bool.self, #keyPath(UIButton.isSelected)).asDriver(onErrorJustReturn: false))
            .map({ (r1, r2) -> Bool in
                if let r1 = r1, let r2 = r2 {
                    return r1 && r2
                } else {
                    return false
                }
            })
            .drive(onNext: { (r) in
                skipButton.isEnabled = r
                backupButton.isEnabled = r
            }).disposed(by: rx.disposeBag)
    }
}
