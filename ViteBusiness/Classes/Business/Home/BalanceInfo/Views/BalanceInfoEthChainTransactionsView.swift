//
//  BalanceInfoEthChainTransactionsView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/2/28.
//

import UIKit

class BalanceInfoEthChainTransactionsView: UIView {

    init(tokenInfo: TokenInfo) {
        super.init(frame: CGRect.zero)

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.numberOfLines = 1
            $0.text = R.string.localizable.transactionListPageTitle()
        }

        let placeholderView: UIView = {
            let view = UIView()
            let layoutGuide = UILayoutGuide()
            let imageView = UIImageView(image: R.image.empty())
            let button = UIButton(type: .system).then {
                $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                $0.titleLabel?.numberOfLines = 0
                $0.titleLabel?.textAlignment = .center
                $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
                $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
                $0.setTitle(R.string.localizable.balanceInfoDetailShowTransactionsButtonTitle(), for: .normal)
            }

            button.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                var infoUrl = "\(ViteConst.instance.eth.explorer)/address/\(ETHWalletManager.instance.account?.address ?? "")"
                guard let url = URL(string: infoUrl) else { return }
                let vc = WKWebViewController.init(url: url)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                }.disposed(by: self.rx.disposeBag)

            view.addLayoutGuide(layoutGuide)
            view.addSubview(imageView)
            view.addSubview(button)

            layoutGuide.snp.makeConstraints { (m) in
                m.centerY.left.right.equalTo(view)
            }

            let showImage = UIScreen.main.bounds.size != CGSize(width: 320, height: 568)
            if showImage {
                imageView.snp.makeConstraints { (m) in
                    m.top.centerX.equalTo(layoutGuide)
                    m.size.equalTo(CGSize(width: 130, height: 130))
                }
                button.snp.makeConstraints { (m) in
                    m.top.equalTo(imageView.snp.bottom).offset(20)
                    m.left.right.bottom.equalTo(layoutGuide)
                }
            } else {
                imageView.isHidden = true
                button.snp.makeConstraints { (m) in
                    m.top.left.right.bottom.equalTo(layoutGuide)
                }
            }

            return view
        }()

        addSubview(titleLabel)
        addSubview(placeholderView)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(20)
        }

        placeholderView.snp.makeConstraints { (m) in
            m.left.bottom.equalToSuperview().offset(24)
            m.right.bottom.equalToSuperview().offset(-24)
            m.top.equalTo(titleLabel.snp.bottom)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
