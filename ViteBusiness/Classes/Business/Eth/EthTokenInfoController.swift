//
//  EthTokenInfoController.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/21.
//

import Foundation
import ViteWallet
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import ViteUtils
import ViteEthereum

class EthTokenInfoController: BaseViewController {
    var tokenInfo : ETHToken
    var tokenName: String = ""
    var contractAddress :String = ""

    init(_ tokenInfo: ETHToken, _ contractAddress: String="") {
        self.tokenInfo = tokenInfo
        self.tokenName = self.tokenInfo.name
        self.contractAddress = self.tokenInfo.contractAddress
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
      }

    fileprivate func setupView() {
        navigationBarStyle = .clear

        let detailView = BalanceInfoDetailView()
        let imageView = UIImageView(image: R.image.empty())
        let showTransactionsButton = UIButton.init(type: .system).then {
            $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
            $0.setTitle(R.string.localizable.balanceInfoDetailShowTransactionsButtonTitle(), for: .normal)
        }

        let receiveButton = UIButton(style: .blue, title: R.string.localizable.balanceInfoDetailReveiceButtonTitle())
        let sendButton = UIButton(style: .white, title: R.string.localizable.balanceInfoDetailSendButtonTitle())

        view.addSubview(detailView)
        view.addSubview(imageView)
        view.addSubview(showTransactionsButton)
        view.addSubview(receiveButton)
        view.addSubview(sendButton)

        detailView.snp.makeConstraints { (m) in
            m.top.equalTo(view)
            m.left.right.equalTo(view)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(182)
        }

        let contentLayout = UILayoutGuide()
        let centerLayout = UILayoutGuide()

        view.addLayoutGuide(contentLayout)
        view.addLayoutGuide(centerLayout)

        contentLayout.snp.makeConstraints { (m) in
            m.left.right.equalTo(view)
            m.top.equalTo(detailView.snp.bottom)
            m.bottom.equalTo(receiveButton.snp.top)
        }

        centerLayout.snp.makeConstraints { (m) in
            m.left.right.equalTo(contentLayout)
            m.centerY.equalTo(contentLayout)
        }

        imageView.snp.makeConstraints { (m) in
            m.top.equalTo(centerLayout)
            m.centerX.equalTo(centerLayout)
        }

        showTransactionsButton.snp.makeConstraints { (m) in
            m.top.equalTo(imageView.snp.bottom).offset(20)
            m.bottom.equalTo(centerLayout)
            m.centerX.equalTo(centerLayout)
        }

        receiveButton.snp.makeConstraints { (m) in
            m.left.equalTo(view).offset(24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }

        sendButton.snp.makeConstraints { (m) in
            m.left.equalTo(receiveButton.snp.right).offset(23)
            m.right.equalTo(view).offset(-24)
            m.width.equalTo(receiveButton)
            m.bottom.equalTo(receiveButton)
        }
        
        showTransactionsButton.rx.tap.bind { [weak self] in
            var infoUrl = String.init(format: "https://ropsten.etherscan.io/address/%@", EtherWallet.account.address ?? "")
            guard let url = URL(string: infoUrl) else { return }
            let vc = WKWebViewController.init(url: url)
            self?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

        receiveButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            }.disposed(by: rx.disposeBag)

        sendButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let vc = EthSendTokenController(self.tokenInfo)
            self.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)
    }
}

