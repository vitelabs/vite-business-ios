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



    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private lazy var ethInfoCardView: EthInfoCardView = {
        let ethInfoCardView = EthInfoCardView(self.tokenInfo)
        return ethInfoCardView
    }()

    fileprivate func setupView() {
        let detailView = BalanceInfoDetailView()
        let imageView = UIImageView(image: R.image.empty())
        let showTransactionsButton = UIButton.init(type: .system).then {
            $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
            $0.setTitle(R.string.localizable.balanceInfoDetailShowTransactionsButtonTitle(), for: .normal)
        }

        view.addSubview(detailView)
        view.addSubview(imageView)
        view.addSubview(showTransactionsButton)

        view.addSubview(ethInfoCardView)
        ethInfoCardView.snp.makeConstraints { (m) in
            m.top.equalTo(view).offset(100)
            m.left.equalTo(view).offset(24)
            m.right.equalTo(view).offset(-24)
            m.height.equalTo(188)
        }


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
            m.bottom.equalTo(view)
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


        
        showTransactionsButton.rx.tap.bind { [weak self] in
            var infoUrl = String.init(format: "https://ropsten.etherscan.io/address/%@", EtherWallet.account.address ?? "")
            guard let url = URL(string: infoUrl) else { return }
            let vc = WKWebViewController.init(url: url)
            self?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

        self.ethInfoCardView.receiveButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            }.disposed(by: rx.disposeBag)

        self.ethInfoCardView.sendButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let vc = EthSendTokenController(self.tokenInfo)
            self.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)
    }
}

