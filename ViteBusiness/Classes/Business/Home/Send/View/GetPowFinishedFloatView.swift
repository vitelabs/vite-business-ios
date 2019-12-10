//
//  GetPowFinishedFloatView.swift
//  Vite
//
//  Created by Stone on 2018/10/26.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import DACircularProgress

class GetPowFinishedFloatView: VisualEffectAnimationView {

    fileprivate let containerView: UIView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }

    fileprivate let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x242728)
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.text = R.string.localizable.quotaPowFinishedFloatViewTitle()
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    fileprivate let imageView = UIImageView(image: R.image.icon_quota_time())

    lazy fileprivate var h1Label = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.text = R.string.localizable.quotaPowFinishedFloatViewH1(self.timeString, self.utString)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    fileprivate let h2Label = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.text = R.string.localizable.quotaPowFinishedFloatViewH2()
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    let pledgeButton = UIButton().then {
        $0.setTitle(R.string.localizable.quotaPowFinishedFloatViewPledgeButtonTitle(), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }

    let cancelButton = UIButton().then {
        $0.setImage(R.image.icon_quota_close(), for: .normal)
        $0.setImage(R.image.icon_quota_close()?.highlighted, for: .highlighted)
    }

    let timeString: String
    let utString: String
    init(superview: UIView, timeString: String, utString: String, pledgeClick: @escaping () -> Void, cancelClick: @escaping () -> Void) {
        self.timeString = timeString
        self.utString = utString
        super.init(superview: superview)

        isEnableTapDismiss = false

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(imageView)
        containerView.addSubview(h1Label)
        containerView.addSubview(h2Label)
        containerView.addSubview(cancelButton)
        containerView.addSubview(pledgeButton)

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
            m.top.equalTo(titleLabel.snp.bottom).offset(20)
            m.centerX.equalToSuperview()
            m.size.equalTo(CGSize(width: 50, height: 50))
        }

        h1Label.snp.makeConstraints { (m) in
            m.top.equalTo(imageView.snp.bottom).offset(20)
            m.left.right.equalTo(titleLabel)
        }

        h2Label.snp.makeConstraints { (m) in
            m.top.equalTo(h1Label.snp.bottom).offset(14)
            m.left.right.equalTo(titleLabel)
        }

        pledgeButton.snp.makeConstraints { (m) in
            m.top.equalTo(h2Label.snp.bottom).offset(12)
            m.height.equalTo(49)
            m.left.right.bottom.equalToSuperview()
        }

        cancelButton.snp.makeConstraints { (m) in
            m.top.right.equalToSuperview()
            m.size.equalTo(CGSize(width: 39, height: 39))
        }

        let line = UIView().then {
            $0.backgroundColor = Colors.lineGray
        }

        containerView.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.right.equalToSuperview()
            m.bottom.equalTo(pledgeButton.snp.top)
        }

        pledgeButton.rx.tap.bind { [weak self] in
            self?.hide()
            pledgeClick()
            }.disposed(by: rx.disposeBag)
        cancelButton.rx.tap.bind { [weak self] in
            self?.hide()
            cancelClick()
            }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
