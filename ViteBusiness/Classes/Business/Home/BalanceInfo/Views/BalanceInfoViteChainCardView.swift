//
//  BalanceInfoViteChainCardView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/2/28.
//

import UIKit

class BalanceInfoViteChainCardView: UIView {

    let receiveButton = UIButton(style: .blue, title: R.string.localizable.balanceInfoDetailReveiceButtonTitle())
    let sendButton = UIButton(style: .white, title: R.string.localizable.balanceInfoDetailSendButtonTitle())

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 188)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        layer.cornerRadius = 2

        addSubview(receiveButton)
        addSubview(sendButton)

        receiveButton.snp.makeConstraints { (m) in
            m.left.bottom.equalToSuperview()
            m.height.equalTo(44)
        }

        sendButton.snp.makeConstraints { (m) in
            m.right.bottom.equalToSuperview()
            m.height.equalTo(44)
            m.left.equalTo(receiveButton.snp.right)
            m.width.equalTo(receiveButton)
        }

        receiveButton.rx.tap.bind { [weak self] in
            guard let token = self?.tokenInfo?.toViteToken() else { return }
            UIViewController.current?.navigationController?.pushViewController(ReceiveViewController(token: token), animated: true)
            }.disposed(by: rx.disposeBag)

        sendButton.rx.tap.bind { [weak self] in
            guard let token = self?.tokenInfo?.toViteToken() else { return }
            let sendViewController = SendViewController(token: token, address: nil, amount: nil, note: nil)
            UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    var tokenInfo: TokenInfo?
    func bind(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        DispatchQueue.main.async {
            self.backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: self.frame, colors: tokenInfo.chainBackgroundGradientColors)
        }
    }
}
