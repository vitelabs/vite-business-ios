//
//  GetPowFloatView.swift
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

class GetPowFloatView: VisualEffectAnimationView {

    fileprivate let containerView: UIView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }

    fileprivate let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x242728)
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.text = R.string.localizable.quotaFloatViewTitle()
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    fileprivate let progressView = DACircularProgressView().then {
        $0.trackTintColor = UIColor(netHex: 0xefefef)
        $0.progressTintColor = UIColor(netHex: 0x00BEFF)
        $0.thicknessRatio = 0.1
        $0.roundedCorners = 1
    }

    fileprivate let progressLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x00BEFF)
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.text = "0%"
    }

    lazy fileprivate var tipLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = R.string.localizable.quotaFloatViewTip(self.utString)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    let cancelButton = UIButton().then {
        $0.setTitle(R.string.localizable.cancel(), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x00BEFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x00BEFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }

    let utString: String
    init(superview: UIView, utString: String, cancelClick: @escaping () -> Void) {
        self.utString = utString
        super.init(superview: superview)

        isEnableTapDismiss = false

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(tipLabel)
        containerView.addSubview(progressView)
        containerView.addSubview(progressLabel)
        containerView.addSubview(cancelButton)

        containerView.snp.makeConstraints { (m) in
            m.center.equalTo(contentView)
            m.width.equalTo(288)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(containerView).offset(24)
            m.left.equalToSuperview().offset(16)
            m.right.equalToSuperview().offset(-16)
        }

        tipLabel.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(11)
            m.left.equalToSuperview().offset(16)
            m.right.equalToSuperview().offset(-16)
        }

        progressView.snp.makeConstraints { (m) in
            m.top.equalTo(tipLabel.snp.bottom).offset(20)
            m.centerX.equalTo(containerView)
            m.size.equalTo(CGSize(width: 100, height: 100))
        }

        progressLabel.snp.makeConstraints { (m) in
            m.center.equalTo(progressView)
        }

        cancelButton.snp.makeConstraints { (m) in
            m.top.equalTo(progressView.snp.bottom).offset(20)
            m.height.equalTo(49)
            m.left.right.bottom.equalToSuperview()
        }

        let line = UIView().then {
            $0.backgroundColor = Colors.lineGray
        }

        containerView.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.right.equalToSuperview()
            m.bottom.equalTo(cancelButton.snp.top)
        }

        cancelButton.rx.tap.bind { [weak self] in
            self?.hide()
            cancelClick()
        }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var progress = 0
    override func show(animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        super.show(animations: animations, completion: completion)
        Observable<Int>.interval(.milliseconds(600), scheduler: MainScheduler.instance).bind { [weak self] _ in
            guard let `self` = self else { return }
            guard self.progress < 100 else { return }
            self.progress = min(self.progress + 1, 99)
            self.updateProgress()
        }.disposed(by: rx.disposeBag)
    }

    override func hide(animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        super.hide(animations: animations, completion: completion)
        removeFromSuperview()
    }

    func updateProgress(_ animated: Bool = true) {
        self.progressLabel.text = String(self.progress) + "%"
        self.progressView.setProgress(CGFloat(self.progress) / 100.0, animated: animated)
    }

    func finish(completion: @escaping () -> Void) {
        self.cancelButton.isUserInteractionEnabled = false
        self.progress = 100
        updateProgress(false)
        GCD.delay(0.25) { self.hide(animations: nil, completion: completion) }
    }

}
