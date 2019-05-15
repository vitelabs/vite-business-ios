//
//  BackupMnemonicViewController.swift
//  Vite
//
//  Created by Water on 2018/9/4.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import Vite_HDWalletKit
import ActiveLabel
import RxSwift
import RxCocoa

class BackupMnemonicViewController: BaseViewController {
    fileprivate var viewModel: BackupMnemonicVM

    init() {
        self.viewModel = BackupMnemonicVM()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self._setupView()
        self._bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // other page inter then refresh words
        self.viewModel.fetchNewMnemonicWordsAction?.execute(())
    }

    lazy var tipTitleLab: UILabel = {
        let tipTitleLab = UILabel()
        tipTitleLab.textAlignment = .left
        tipTitleLab.numberOfLines = 0
        tipTitleLab.adjustsFontSizeToFitWidth = true
        tipTitleLab.font = Fonts.descFont
        tipTitleLab.textColor  = Colors.titleGray
        tipTitleLab.text =  R.string.localizable.mnemonicBackupPageTipTitle()
        return tipTitleLab
    }()

    lazy var switchTipView: LabelTipView = {
        let switchTipView = LabelTipView(R.string.localizable.mnemonicBackupPageSwitchModeTitle("12"))
        switchTipView.titleLab.font = Fonts.Font12
        switchTipView.titleLab.textColor = UIColor(netHex: 0x007AFF)
        switchTipView.titleLab.textAlignment = .right
        switchTipView.tipButton.setImage(R.image.switch_mode_icon(), for: .normal)
        switchTipView.tipButton.setImage(R.image.switch_mode_icon(), for: .highlighted)
        switchTipView.rx.tap.bind {[unowned self] in
            self.viewModel.switchModeMnemonicWordsAction?.execute(())
        }.disposed(by: rx.disposeBag)
        switchTipView.tipButton.rx.tap.bind {[unowned self] in
            self.viewModel.switchModeMnemonicWordsAction?.execute(())
        }.disposed(by: rx.disposeBag)
        return switchTipView
    }()

    lazy var mnemonicCollectionView: MnemonicCollectionView = {
        let mnemonicCollectionView = MnemonicCollectionView.init(isHasSelected: true)
        return mnemonicCollectionView
    }()

    lazy var afreshMnemonicBtn: UIButton = {
        let afreshMnemonicBtn = UIButton.init(style: .whiteWithShadow)
    afreshMnemonicBtn.setTitle(R.string.localizable.mnemonicBackupPageTipAnewBtnTitle(), for: .normal)
        afreshMnemonicBtn.rx.tap.bind {[unowned self] in
                    self.viewModel.fetchNewMnemonicWordsAction?.execute(())
        }.disposed(by: rx.disposeBag)
        return afreshMnemonicBtn
    }()

    lazy var nextMnemonicBtn: UIButton = {
        let nextMnemonicBtn = UIButton.init(style: .blueWithShadow)
        nextMnemonicBtn.setTitle(R.string.localizable.mnemonicBackupPageTipNextBtnTitle(), for: .normal)
        nextMnemonicBtn.addTarget(self, action: #selector(nextMnemonicBtnAction), for: .touchUpInside)
        return nextMnemonicBtn
    }()

    lazy var contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 4, left: 24, bottom: 10, right: 24)).then {
        $0.stackView.spacing = 0
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
}

extension BackupMnemonicViewController {
    private func _bindViewModel() {
        self.viewModel.mnemonicWordsList.asObservable().subscribe { [unowned self](_) in
            if self.viewModel.mnemonicWordsList.value.count == 12 {
                self.switchTipView.titleLab.text = R.string.localizable.mnemonicBackupPageSwitchModeTitle("24")
                self.mnemonicCollectionView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(kScreenH * (96.0/667.0))
                }
                self.mnemonicCollectionView.h_num =  CGFloat(3.0)
            } else {
                self.switchTipView.titleLab.text = R.string.localizable.mnemonicBackupPageSwitchModeTitle("12")
                self.mnemonicCollectionView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(kScreenH * (186.0/667.0))
                }
                self.mnemonicCollectionView.h_num =  CGFloat(6.0)
            }

            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.layoutIfNeeded()
            })

            self.mnemonicCollectionView.dataList = (self.viewModel.mnemonicWordsList.value)
        }.disposed(by: rx.disposeBag)

        NotificationCenter.default.rx
            .notification(UIApplication.userDidTakeScreenshotNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                Alert.show(title: R.string.localizable.mnemonicBackupPageAlterTitle(), message: R.string.localizable.mnemonicBackupPageAlterMessage(), actions: [
                    (.default(title: R.string.localizable.mnemonicBackupPageAlterCancel()), nil),
                    (.default(title: R.string.localizable.mnemonicBackupPageAlterConfirm()), { _ in
                        self.viewModel.fetchNewMnemonicWordsAction?.execute(())
                    }),
                    ])
            }).disposed(by: rx.disposeBag)
    }

    private func _setupView() {
        self.view.backgroundColor = .white
        navigationTitleView = NavigationTitleView(title: R.string.localizable.mnemonicBackupPageTitle())

        self._addViewConstraint()
    }
    private func _addViewConstraint() {

        view.addSubview(scrollView)
        view.addSubview(nextMnemonicBtn)
        view.addSubview(afreshMnemonicBtn)

        scrollView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.equalTo((self.navigationTitleView?.snp.bottom)!)
        }

        afreshMnemonicBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(scrollView.snp.bottom)
            make.left.equalTo(view).offset(24)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }

        nextMnemonicBtn.snp.makeConstraints { (make) -> Void in
            make.top.bottom.width.height.equalTo(self.afreshMnemonicBtn)
            make.left.equalTo(afreshMnemonicBtn.snp.right).offset(23)
            make.right.equalTo(view).offset(-24)
        }

        scrollView.stackView.addArrangedSubview(tipTitleLab)
        scrollView.stackView.addPlaceholder(height: 6)
        scrollView.stackView.addArrangedSubview(switchTipView)
        scrollView.stackView.addPlaceholder(height: 6)
        scrollView.stackView.addArrangedSubview(mnemonicCollectionView)


        let checkButton1 = ConfirmView().then { view in
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


        let checkButton2 = ConfirmView().then { view in
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
        

        let checkButton3 = ConfirmView().then { view in
            view.label.text = R.string.localizable.mnemonicBackupPageCheckButton3Title() + R.string.localizable.mnemonicBackupPageClauseButtonTitle()
            let customType = ActiveType.custom(pattern: R.string.localizable.mnemonicBackupPageCheckButton3Title())
            let termType = ActiveType.custom(pattern: R.string.localizable.mnemonicBackupPageClauseButtonTitle())
            view.label.enabledTypes = [termType, customType]
            view.label.customize { [weak view] label in
                label.customColor[customType] = view?.label.textColor
                label.customSelectedColor[customType] = view?.label.textColor
                label.handleCustomTap(for: customType) { [weak view] element in
                    view?.checkButton.isSelected = !(view?.checkButton.isSelected ?? true)
                }
            }

            view.label.customize { label in
                label.customColor[termType] = UIColor(netHex: 0x007AFF)
                label.customSelectedColor[termType] = UIColor(netHex: 0x007AFF).highlighted
                label.handleCustomTap(for: termType) { element in
                    guard let url = URL(string: "https://growth.vite.net/term") else { return }
                    let vc = WKWebViewController.init(url: url)
                    UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }

        Driver.combineLatest(
            checkButton1.checkButton.rx.observe(Bool.self, #keyPath(UIButton.isSelected)).asDriver(onErrorJustReturn: false),
            checkButton2.checkButton.rx.observe(Bool.self, #keyPath(UIButton.isSelected)).asDriver(onErrorJustReturn: false),
            checkButton3.checkButton.rx.observe(Bool.self, #keyPath(UIButton.isSelected)).asDriver(onErrorJustReturn: false))
            .map({ (r1, r2, r3) -> Bool in
                if let r1 = r1, let r2 = r2, let r3 = r3 {
                    return r1 && r2 && r3
                } else {
                    return false
                }
            })
            .drive(onNext: { [unowned self] (r) in
                self.nextMnemonicBtn.isEnabled = r
            }).disposed(by: rx.disposeBag)

        scrollView.stackView.addPlaceholder(height: 22)
        scrollView.stackView.addArrangedSubview(checkButton1)
        scrollView.stackView.addPlaceholder(height: 6)
        scrollView.stackView.addArrangedSubview(checkButton2)
        scrollView.stackView.addPlaceholder(height: 6)
        scrollView.stackView.addArrangedSubview(checkButton3)

        self.tipTitleLab.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(48)
        }

        self.switchTipView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
        }

        self.mnemonicCollectionView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(kScreenH * (186.0/667.0))
        }
    }

    @objc func nextMnemonicBtnAction() {
        CreateWalletService.sharedInstance.mnemonic = self.viewModel.mnemonicWordsStr.value
        let vc = AffirmInputMnemonicViewController.init(mnemonicWordsStr: self.viewModel.mnemonicWordsStr.value)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BackupMnemonicViewController {
    fileprivate class ConfirmView: UIView {

        let checkButton = UIButton()
        let label = ActiveLabel()

        override init(frame: CGRect) {
            super.init(frame: frame)

            checkButton.setImage(R.image.unselected(), for: .normal)
            checkButton.setImage(R.image.selected(), for: .selected)

            checkButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                self.checkButton.isSelected = !self.checkButton.isSelected
            }.disposed(by: rx.disposeBag)

            label.numberOfLines = 0
            label.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
            label.font = UIFont.systemFont(ofSize: 14, weight: .regular)

            addSubview(checkButton)
            addSubview(label)
            checkButton.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(2)
                m.left.equalToSuperview()
                m.size.equalTo(CGSize(width: 12, height: 12))
            }
            label.snp.makeConstraints { (m) in
                m.top.right.bottom.equalToSuperview()
                m.left.equalTo(checkButton.snp.right).offset(6)
            }


        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
