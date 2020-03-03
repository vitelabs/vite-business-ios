//
//  WechatQRCodeView.swift
//  Vite
//
//  Created by Stone on 2020/3/2.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import DACircularProgress

class WechatQRCodeView: VisualEffectAnimationView {

    fileprivate let containerView: UIView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }

    fileprivate let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x242728)
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.text = R.string.localizable.myPageAboutUsWechatAlertTitle()
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    fileprivate let imageView = UIImageView(image: R.image.image_wechat_qrcode())

    let okButton = UIButton().then {
        $0.setTitle(R.string.localizable.confirmButtonTitle(), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }

    init(superview: UIView) {
        super.init(superview: superview)

        isEnableTapDismiss = false

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(imageView)
        containerView.addSubview(okButton)

        containerView.snp.makeConstraints { (m) in
            m.center.equalTo(contentView)
            m.width.equalTo(270)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(24)
            m.left.equalToSuperview().offset(16)
            m.right.equalToSuperview().offset(-16)
        }

        imageView.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(12)
            m.centerX.equalToSuperview()
            m.size.equalTo(CGSize(width: 90, height: 90))
        }



        okButton.snp.makeConstraints { (m) in
            m.top.equalTo(imageView.snp.bottom).offset(12)
            m.height.equalTo(44)
            m.left.right.bottom.equalToSuperview()
        }

        let line = UIView().then {
            $0.backgroundColor = Colors.lineGray
        }

        containerView.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.right.equalToSuperview()
            m.bottom.equalTo(okButton.snp.top)
        }

        okButton.rx.tap.bind { [weak self] in
            self?.hide()
            }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
