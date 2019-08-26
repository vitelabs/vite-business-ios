//
//  SignAndSendConfirmViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/22.
//

import UIKit
import ViteWallet

class SignAndSendConfirmViewController: BaseViewController {

    let busyView = BifrostBusyView()
    let uri: ViteURI
    var info: BifrostConfirmInfo!
    var tokenInfo: TokenInfo!

    init(uri: ViteURI) {
        self.uri = uri
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        showConfirm()
    }

    fileprivate func setupView() {
        navigationBarStyle = .custom(tintColor: UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45), backgroundColor: UIColor.clear)
        view.backgroundColor = UIColor(netHex: 0xF5FAFF)
        navigationItem.hidesBackButton = true

        busyView.isHidden = true
        busyView.headerLabel.text = R.string.localizable.appSchemeHomePageBusyHeader()
        busyView.contentLabel.text = R.string.localizable.appSchemeHomePageBusyContent()
        view.addSubview(busyView)
        busyView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }
    }

    fileprivate func bind() {
        busyView.cancelButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.dismiss()
            }.disposed(by: rx.disposeBag)

        busyView.confirmButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            guard let account = HDWalletManager.instance.account else { return }
            guard let amount = self.uri.amountForSmallestUnit(decimals: self.tokenInfo.decimals) else { return }
            guard let fee = self.uri.feeForSmallestUnit(decimals: ViteWalletConst.viteToken.decimals) else { return }
            Workflow.bifrostSendTxWithConfirm(title: self.info.title,
                                              account: account,
                                              toAddress: self.uri.address,
                                              tokenId: self.uri.tokenId,
                                              amount: amount,
                                              fee: fee,
                                              data: self.uri.data, completion: { (ret) in
                                                switch ret {
                                                case .success:
                                                    self.dismiss()
                                                case .failure:
                                                    break
                                                }
            })
            }.disposed(by: rx.disposeBag)
    }

    fileprivate func showConfirm() {
        HUD.show()
        SASConfirmViewModelFactory.generateViewModel(uri)
            .always {
                HUD.hide()
            }.done { (info, tokenInfo) in
                self.info = info
                self.tokenInfo = tokenInfo
                self.busyView.isHidden = false
                self.busyView.set(info)
            }.catch { (error) in
                Toast.show(R.string.localizable.appSchemeNetworkError())
                self.dismiss()
        }
    }
}
