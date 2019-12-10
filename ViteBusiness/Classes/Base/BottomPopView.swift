//
//  BottomPopView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/5.
//

import UIKit

public class BottomPopView: VisualEffectAnimationView {

    fileprivate let whiteView = UIView().then {
        $0.backgroundColor = UIColor.white
    }

    fileprivate let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }

    fileprivate let dismissButton = UIButton().then {
        $0.setImage(R.image.icon_nav_close_black()?.tintColor(UIColor(netHex: 0x3E4A59, alpha: 0.45)), for: .normal)
        $0.setImage(R.image.icon_nav_close_black()?.tintColor(UIColor(netHex: 0x3E4A59, alpha: 0.45)).highlighted, for: .highlighted)
    }

    fileprivate let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.textAlignment = .center
    }

    public let containerView = UIView()

    public fileprivate(set) var buttons = [UIButton]()

    public var dismissed: ((BottomPopView) -> ())?
    public var dismissButtonClicked: ((BottomPopView) -> ())?

    fileprivate func initView(title: String, buttons: [UIButton]) {
        isEnableTapDismiss = false

        let animationView = UIView().then {
            $0.backgroundColor = whiteView.backgroundColor
        }

        contentView.addSubview(animationView)
        contentView.addSubview(whiteView)

        animationView.snp.makeConstraints { (m) in
            m.top.equalTo(whiteView)
            m.left.right.bottom.equalToSuperview()
        }

        whiteView.snp.makeConstraints { (m) in
            m.top.equalTo(contentView.snp.bottom)
            m.left.right.equalToSuperview()
        }

        whiteView.addSubview(dismissButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(stackView)

        dismissButton.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize(width: 28, height: 28))
            m.top.equalToSuperview().offset(17)
            m.left.equalToSuperview().offset(24)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(dismissButton)
            m.centerX.equalToSuperview().priority(.high)
            m.left.greaterThanOrEqualTo(dismissButton.snp.right).offset(10).priority(.required)
            m.right.lessThanOrEqualToSuperview().offset(-24).priority(.required)
        }

        stackView.snp.makeConstraints { (m) in
            m.top.equalTo(dismissButton.snp.bottom).offset(27)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview().offset(-24)
        }

        containerView.snp.makeConstraints { (m) in
            m.height.equalTo(44).priority(.low)
        }

        stackView.addArrangedSubview(containerView)

        // init
        self.titleLabel.text = title
        self.buttons = buttons
        for button in buttons {
            if button == self.buttons.first {
                stackView.addPlaceholder(height: 24)
            } else {
                stackView.addPlaceholder(height: 12)
            }
            stackView.addArrangedSubview(button)
        }

        dismissButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.dismissButtonClicked?(self)
            self.hide()
            }.disposed(by: rx.disposeBag)
    }

    public init(title: String, confirmed: ((BottomPopView) -> ())? = nil, canceled: ((BottomPopView) -> ())? = nil) {
        super.init(superview: UIApplication.shared.keyWindow!)
        let confirmButton = UIButton(style: .blue, title: R.string.localizable.confirm())
        let cancelButton = UIButton(style: .whiteWithShadow, title: R.string.localizable.cancel())
        initView(title: title, buttons: [confirmButton, cancelButton])

        confirmButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            if let c = confirmed { c(self) }
            }.disposed(by: rx.disposeBag)
        cancelButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.hide()
            if let c = canceled { c(self) }
            }.disposed(by: rx.disposeBag)
    }

    public init(title: String, buttons: [UIButton]) {
        super.init(superview: UIApplication.shared.keyWindow!)
        initView(title: title, buttons: buttons)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func show(animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        contentView.layoutIfNeeded()
        whiteView.snp.remakeConstraints { (m) in
            m.bottom.equalTo(contentView.safeAreaLayoutGuideSnpBottom)
            m.left.right.equalToSuperview()
        }
        super.show(animations: { [weak self] in
            guard let `self` = self else { return }
            self.contentView.layoutIfNeeded()
            if let a = animations { a() }
            }, completion: completion)
    }

    public override func hide(animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        contentView.layoutIfNeeded()
        whiteView.snp.remakeConstraints { (m) in
            m.top.equalTo(contentView.snp.bottom)
            m.left.right.equalToSuperview()
        }
        super.hide(animations: { [weak self] in
            guard let `self` = self else { return }
            self.contentView.layoutIfNeeded()
            if let a = animations { a() }
            }, completion: { [weak self] in
                guard let `self` = self else { return }
                if let c = completion { c() }
                if let d = self.dismissed { d(self) }
        })
    }
}
