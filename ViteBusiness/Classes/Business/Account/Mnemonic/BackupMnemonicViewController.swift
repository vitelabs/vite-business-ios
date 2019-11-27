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
import ObjectMapper

class BackupMnemonicViewController: BaseViewController {
//    fileprivate var viewModel: BackupMnemonicVM

    fileprivate let forCreate: Bool
    fileprivate let password: String?
    fileprivate var isFirstShow = true

    fileprivate let refreshMnemonicBehaviorRelay: BehaviorRelay<Void> = BehaviorRelay(value: ())

    init(password: String?) {
        self.password = password
        self.forCreate = (password == nil)
//        self.viewModel = BackupMnemonicVM()
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

        if isFirstShow {
            isFirstShow = false
        } else {
            if forCreate {
                // other page inter then refresh words
                refreshMnemonicBehaviorRelay.accept(())
            }
        }


    }

//    lazy var switchTipView: LabelTipView = {
//        let switchTipView = LabelTipView(R.string.localizable.mnemonicBackupPageSwitchModeTitle("12"))
//        switchTipView.titleLab.font = Fonts.Font12
//        switchTipView.titleLab.textColor = UIColor(netHex: 0x007AFF)
//        switchTipView.titleLab.textAlignment = .right
//        switchTipView.tipButton.setImage(R.image.switch_mode_icon(), for: .normal)
//        switchTipView.tipButton.setImage(R.image.switch_mode_icon(), for: .highlighted)
//        switchTipView.rx.tap.bind {[unowned self] in
//            self.viewModel.switchModeMnemonicWordsAction?.execute(())
//        }.disposed(by: rx.disposeBag)
//        switchTipView.tipButton.rx.tap.bind {[unowned self] in
//            self.viewModel.switchModeMnemonicWordsAction?.execute(())
//        }.disposed(by: rx.disposeBag)
//
//        return switchTipView
//    }()

    let mnemonicSwitchView = MnemonicSwitchView()

    lazy var mnemonicCollectionView: MnemonicCollectionView = {
        let mnemonicCollectionView = MnemonicCollectionView.init(isHasSelected: true)
        return mnemonicCollectionView
    }()

    lazy var afreshMnemonicBtn: UIButton = {
        let afreshMnemonicBtn = UIButton.init(style: .whiteWithShadow)
        afreshMnemonicBtn.setTitle(R.string.localizable.mnemonicBackupPageTipAnewBtnTitle(), for: .normal)
        afreshMnemonicBtn.rx.tap.bind {[weak self] in
            self?.refreshMnemonicBehaviorRelay.accept(())
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

    let qrImageView = UIImageView()

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 0, left: 24, bottom: 10, right: 24)).then {
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
}

extension BackupMnemonicViewController {



    func updateQRImageView(name: String, mnemonic: String, language: MnemonicCodeBook, password: String) {
        guard let uri = CreateWalletService.BackupWalletURI(name: name,
                                                            mnemonic: mnemonic,
                                                            language: language,
                                                            password: password) else {
                                                                return

        }
        QRCodeHelper.createQRCode(string: uri.uri) { [weak self] image in
            self?.qrImageView.image = image
        }
    }
    private func _bindViewModel() {

        if forCreate {
            Driver.combineLatest(refreshMnemonicBehaviorRelay.asDriver(),
                                 mnemonicSwitchView.typeDriver).drive(onNext: { (_, arg) in
                                    let (length, lang) = arg
                                    let strength: Mnemonic.Strength
                                    let language: MnemonicCodeBook

                                    switch length {
                                    case .l12:
                                        strength = .weak
                                    case .l24:
                                        strength = .strong
                                    }

                                    switch lang {
                                    case .en:
                                        language = .english
                                    case .zh:
                                        language = .simplifiedChinese
                                    }

                                    CreateWalletService.sharedInstance.generateMnemonic(strength: strength, language: language)
                                 }).disposed(by: rx.disposeBag)

            CreateWalletService.sharedInstance.mnemonicDriver.drive(onNext: { [weak self] (mnemonic) in
                guard let `self` = self else { return }
                let array = mnemonic.components(separatedBy: " ")
                if array.count == 12 {
                    self.mnemonicCollectionView.snp.updateConstraints { (make) -> Void in
                        make.height.equalTo(kScreenH * (96.0/667.0))
                    }
                    self.mnemonicCollectionView.h_num =  CGFloat(3.0)
                } else {
                    self.mnemonicCollectionView.snp.updateConstraints { (make) -> Void in
                        make.height.equalTo(kScreenH * (186.0/667.0))
                    }
                    self.mnemonicCollectionView.h_num =  CGFloat(6.0)
                }

                UIView.animate(withDuration: 0.3, animations: {
                    self.scrollView.layoutIfNeeded()
                })

                self.mnemonicCollectionView.dataList = array
                self.updateQRImageView(name: CreateWalletService.sharedInstance.name,
                                       mnemonic: CreateWalletService.sharedInstance.mnemonic,
                                       language: CreateWalletService.sharedInstance.language,
                                       password: CreateWalletService.sharedInstance.password)
            }).disposed(by: rx.disposeBag)
        } else {
            guard let mnemonic = HDWalletManager.instance.mnemonic,
            let name = HDWalletManager.instance.wallet?.name,
            let language = HDWalletManager.instance.language,
            let password = self.password else {
                return
            }

            let list = mnemonic.components(separatedBy: " ")
            if list.count == 12 {
                self.mnemonicCollectionView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(kScreenH * (96.0/667.0))
                }
                self.mnemonicCollectionView.h_num =  CGFloat(3.0)
            } else {
                self.mnemonicCollectionView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(kScreenH * (186.0/667.0))
                }
                self.mnemonicCollectionView.h_num =  CGFloat(6.0)
            }
            self.mnemonicCollectionView.dataList = list
            self.updateQRImageView(name: name, mnemonic: mnemonic, language: language, password: password)
        }

        NotificationCenter.default.rx
            .notification(UIApplication.userDidTakeScreenshotNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (_) in
                Alert.show(title: R.string.localizable.mnemonicBackupPageAlterTitle(), message: R.string.localizable.mnemonicBackupPageAlterMessage(), actions: [
                    (.default(title: R.string.localizable.mnemonicBackupPageAlterCancel()), nil),
                    (.default(title: R.string.localizable.mnemonicBackupPageAlterConfirm()), {[weak self] _ in
                        self?.refreshMnemonicBehaviorRelay.accept(())
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


        scrollView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.equalTo((self.navigationTitleView?.snp.bottom)!)
        }

        if forCreate {
            view.addSubview(nextMnemonicBtn)
            view.addSubview(afreshMnemonicBtn)
            afreshMnemonicBtn.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(scrollView.snp.bottom).offset(20)
                make.left.equalTo(view).offset(24)
                make.height.equalTo(50)
                make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
            }

            nextMnemonicBtn.snp.makeConstraints { (make) -> Void in
                make.top.bottom.width.height.equalTo(self.afreshMnemonicBtn)
                make.left.equalTo(afreshMnemonicBtn.snp.right).offset(23)
                make.right.equalTo(view).offset(-24)
            }
        } else {
            view.addSubview(nextMnemonicBtn)
            nextMnemonicBtn.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(scrollView.snp.bottom)
                make.left.equalTo(view).offset(24)
                make.height.equalTo(50)
                make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
                make.right.equalTo(view).offset(-24)
            }
        }

        if forCreate {
            scrollView.stackView.addArrangedSubview(mnemonicSwitchView)
        }

        let tip1Label = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.8)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.numberOfLines = 0
            $0.text = R.string.localizable.mnemonicBackupPageTip1()
        }

        let tip1View = UILabel().then {
            $0.textColor = UIColor(netHex: 0x24272B)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.text = R.string.localizable.mnemonicBackupPageTip1()
        }

        let tip2View = TipTextView(text: R.string.localizable.mnemonicBackupPageTip2())
        let tip3View = TipTextView(text: R.string.localizable.mnemonicBackupPageTip3())

        qrImageView.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize(width: 140, height: 140))
        }

        scrollView.stackView.addPlaceholder(height: 8)
        scrollView.stackView.addArrangedSubview(mnemonicCollectionView)
        scrollView.stackView.addPlaceholder(height: 16)
        scrollView.stackView.addArrangedSubview(tip1View)
        scrollView.stackView.addPlaceholder(height: 10)
        scrollView.stackView.addArrangedSubview(tip2View)
        scrollView.stackView.addPlaceholder(height: 4)
        scrollView.stackView.addArrangedSubview(tip3View)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(qrImageView.centerX())


        mnemonicSwitchView.typeDriver.drive(onNext: { (length, language) in
            plog(level: .debug, log: "\(length) \(language)")
        }).disposed(by: rx.disposeBag)

        self.mnemonicCollectionView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(kScreenH * (186.0/667.0))
        }
    }

    @objc func nextMnemonicBtnAction() {
        let mnemonicWordsStr: String
        if forCreate {
            mnemonicWordsStr = CreateWalletService.sharedInstance.mnemonic
        } else {
            mnemonicWordsStr = HDWalletManager.instance.mnemonic ?? ""
        }
        let vc = AffirmInputMnemonicViewController.init(mnemonicWordsStr: mnemonicWordsStr, forCreate: forCreate)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BackupMnemonicViewController {
    public class ConfirmView: UIView {

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
                m.top.equalToSuperview().offset(3)
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

class MnemonicSwitchView: UIView {

    lazy var typeDriver: Driver<(lengthType, MnemonicLanguageSwitchButton.LanguageType)>
        = Driver.combineLatest(lengthBehaviorRelay.asDriver(), self.languageSwitchButton.typeDriver)
    private var lengthBehaviorRelay: BehaviorRelay<lengthType> = BehaviorRelay(value: .l12)

    enum lengthType {
        case l12
        case l24
    }


    let languageSwitchButton = MnemonicLanguageSwitchButton()

    let lengthButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setImage(R.image.switch_mode_icon(), for: .normal)
        $0.setImage(R.image.switch_mode_icon()?.highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.setTitle(R.string.localizable.mnemonicBackupPageSwitchModeTitle("24"), for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(languageSwitchButton)
        addSubview(lengthButton)

        languageSwitchButton.snp.makeConstraints { (m) in
            m.left.top.bottom.equalToSuperview()
        }

        lengthButton.snp.makeConstraints { (m) in
            m.top.bottom.right.equalToSuperview()
        }

        lengthButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            switch self.lengthBehaviorRelay.value {
            case .l12:
                self.lengthBehaviorRelay.accept(.l24)
                self.lengthButton.setTitle(R.string.localizable.mnemonicBackupPageSwitchModeTitle("12"), for: .normal)
            case .l24:
                self.lengthBehaviorRelay.accept(.l12)
                self.lengthButton.setTitle(R.string.localizable.mnemonicBackupPageSwitchModeTitle("24"), for: .normal)
            }
        }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MnemonicLanguageSwitchButton: UIView {

    enum LanguageType {
        case en
        case zh
    }

    let selectView = UIView().then {
        $0.backgroundColor = UIColor(netHex: 0x007AFF, alpha: 0.05)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 11
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(netHex: 0xE5E5EA).cgColor
    }

    let enLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.text = R.string.localizable.mnemonicBackupLanguageEn()
        $0.textAlignment = .center
    }

    let zhLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.text = R.string.localizable.mnemonicBackupLanguageZh()
        $0.textAlignment = .center
    }

    lazy var typeDriver: Driver<LanguageType> = self.typeBehaviorRelay.asDriver()
    private var typeBehaviorRelay: BehaviorRelay<LanguageType> = BehaviorRelay(value: .en)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 11
        layer.borderWidth = 1
        layer.borderColor = UIColor(netHex: 0xE5E5EA).cgColor

        addSubview(selectView)
        addSubview(enLabel)
        addSubview(zhLabel)

        self.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize(width: 96, height: 22))
        }

        selectView.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.width.equalToSuperview().multipliedBy(0.5)
            m.left.equalToSuperview()
        }

        enLabel.snp.makeConstraints { (m) in
            m.top.left.bottom.equalToSuperview()
        }

        zhLabel.snp.makeConstraints { (m) in
            m.top.right.bottom.equalToSuperview()
            m.left.equalTo(enLabel.snp.right)
            m.width.equalTo(enLabel)
        }

        enLabel.textColor = UIColor(netHex: 0x007AFF)
        zhLabel.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)

        typeDriver.skip(1).drive(onNext: { [weak self] (type) in
            self?.animate(type: type)
        }).disposed(by: rx.disposeBag)

        self.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: nil, action: nil)
        addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.rx.event.subscribe(onNext: { [weak self] (r) in
            guard let `self` = self else { return }
            switch self.typeBehaviorRelay.value {
            case .en:
                self.typeBehaviorRelay.accept(.zh)
            case .zh:
                self.typeBehaviorRelay.accept(.en)
            }
        }).disposed(by: rx.disposeBag)
    }

    func animate(type: LanguageType) {
        self.isUserInteractionEnabled = false
        switch type {
        case .en:
            self.selectView.snp.remakeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.width.equalToSuperview().multipliedBy(0.5)
                m.left.equalToSuperview()
            }

            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
                self.enLabel.textColor = UIColor(netHex: 0x007AFF)
                self.zhLabel.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            }, completion: { (_) in
                self.isUserInteractionEnabled = true
            })
        case .zh:
            self.selectView.snp.remakeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.width.equalToSuperview().multipliedBy(0.5)
                m.right.equalToSuperview()
            }

            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
                self.enLabel.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
                self.zhLabel.textColor = UIColor(netHex: 0x007AFF)
            }, completion: { (_) in
                self.isUserInteractionEnabled = true
            })
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
