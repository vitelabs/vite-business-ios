//
//  ReceiveViewController.swift
//  Vite
//
//  Created by Stone on 2018/9/10.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import SnapKit
import RxSwift
import RxCocoa
import BigInt

class ReceiveViewController: BaseViewController {

    let tokenInfo: TokenInfo
    let viewModel: ReceiveViewModelType
    init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        self.viewModel = tokenInfo.createReceiveViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // View
    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)).then {
        $0.stackView.spacing = 0
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    lazy var addressView = ReceiveAddressView(name: self.viewModel.walletName, address: self.viewModel.address, addressName: self.viewModel.addressName)
    let qrcodeView = ReceiveQRCodeView()
    let noteView = ReceiveNoteView()

    func setupView() {
        navigationBarStyle = .clear
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_nav_share_black(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(onShare))
        view.backgroundColor = UIColor.gradientColor(style: .top2bottom, frame: view.frame, colors: tokenInfo.coinBackgroundGradientColors)

        let whiteView = UIImageView(image: R.image.background_button_white()?.resizable).then {
            $0.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowOffset = CGSize(width: 0, height: 5)
            $0.layer.shadowRadius = 20
        }

        view.addSubview(whiteView)
        view.addSubview(scrollView)

        whiteView.snp.makeConstraints { (m) in
            m.edges.equalTo(scrollView)
        }

        scrollView.snp.makeConstraints { (m) in
            m.top.greaterThanOrEqualTo(view.safeAreaLayoutGuideSnpTop).offset(6)
            m.centerY.equalTo(view).priority(.medium)
            m.left.equalTo(view).offset(24)
            m.right.equalTo(view).offset(-24)
            m.bottom.lessThanOrEqualTo(view).offset(-74)
        }

        scrollView.stackView.addArrangedSubview(addressView)
        scrollView.stackView.addArrangedSubview(qrcodeView)
        if viewModel.isShowNoteView {
            scrollView.stackView.addArrangedSubview(noteView)
        } else {
            scrollView.stackView.addPlaceholder(height: 20)
        }

        let layoutGuide = UILayoutGuide()
        let iconImageView = UIImageView(image: R.image.icon_receive_logo())
        let label = UILabel()
        label.text = R.string.localizable.receivePageWalletName()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        view.addLayoutGuide(layoutGuide)
        view.addSubview(iconImageView)
        view.addSubview(label)

        layoutGuide.snp.makeConstraints { (m) in
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-26)
            m.centerX.equalTo(view)
            m.height.equalTo(1)
        }

        iconImageView.snp.makeConstraints { (m) in
            m.bottom.left.equalTo(layoutGuide)
        }

        label.snp.makeConstraints { (m) in
            m.right.equalTo(layoutGuide)
            m.centerY.equalTo(iconImageView)
            m.left.equalTo(iconImageView.snp.right).offset(10)
        }
    }

    func bind() {
        qrcodeView.iconView.tokenInfo = tokenInfo
        
        qrcodeView.amountButton.rx.tap
            .bind { [weak self] in
                Alert.show(title: R.string.localizable.receivePageTokenAmountAlertTitle(),
                           message: nil,
                           actions: [(.cancel, nil),
                                     (.default(title: R.string.localizable.confirm()), {[weak self] alertController in
                                        guard let textField = alertController.textFields?.first else { fatalError() }
                                        self?.viewModel.amountStringBehaviorRelay.accept(textField.text)
                                     }),
                                     ], config: { alertController in
                                        alertController.addTextField(configurationHandler: { [weak self] in
                                            $0.keyboardType = .decimalPad
                                            $0.text = self?.viewModel.amountStringBehaviorRelay.value
                                            $0.delegate = self
                                        })
                })
            }.disposed(by: rx.disposeBag)

        noteView.noteTitleTextFieldView.textField.rx.text.asObservable().bind(to: viewModel.noteStringBehaviorRelay).disposed(by: rx.disposeBag)

        viewModel.tipStringDriver.drive(qrcodeView.tokenSymbolLabel.rx.text).disposed(by: rx.disposeBag)

        viewModel.uriStringDriver.drive(onNext: { [weak self] in
            QRCodeHelper.createQRCode(string: $0) { [weak self] image in
                self?.qrcodeView.imageView.image = image
            }
        })
    }

    @objc func onShare() {
        share(viewModel: viewModel)
    }
}

extension ReceiveViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: min(8, tokenInfo.decimals))
        textField.text = text
        return ret
    }
}
