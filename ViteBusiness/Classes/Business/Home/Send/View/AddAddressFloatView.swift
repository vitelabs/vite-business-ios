//
//  AddAddressFloatView.swift
//  Vite
//
//  Created by Stone on 2018/10/26.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import pop
import RxSwift
import RxCocoa
import NSObject_Rx

protocol FloatButtonsViewDelegate: class {
    func didClick(at index: Int, targetView: UIView)
}

class FloatButtonsView: VisualEffectAnimationView {

    enum Direction {
        case leftTop
        case leftBottom
    }

    fileprivate func createButton(title: String) -> UIButton {
        return UIButton().then {
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            $0.setTitle(title, for: .normal)
            $0.setBackgroundImage(R.image.background_address_add_button_white()?.resizable, for: .normal)
            $0.setBackgroundImage(R.image.background_address_add_button_white()?.tintColor(UIColor(netHex: 0xefefef)).resizable, for: .highlighted)
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowRadius = 3
            $0.layer.shadowOffset = CGSize(width: 0, height: 0)
            $0.layer.cornerRadius = 2
        }
    }


    fileprivate let containerView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 10
    }

    fileprivate weak var delegate: FloatButtonsViewDelegate?
    init(targetView: UIView, delegate: FloatButtonsViewDelegate, titles: [String], direction: Direction = .leftTop, offset: CGPoint = .zero) {

        self.delegate = delegate
        let superView: UIView
        if let s = targetView.ofViewController?.navigationController?.view {
            superView = s
        } else if let s = targetView.ofViewController?.view {
            superView = s
        } else {
            fatalError()
        }
//        guard let superView = targetView.ofViewController?.navigationController?.view else { fatalError() }
        super.init(superview: superView, style: .color(color: UIColor.clear))

        contentView.addSubview(containerView)

        for (index, title) in titles.enumerated() {
            let button = createButton(title: title)
            containerView.addArrangedSubview(button)

            button.rx.tap.bind { [weak self] in
                self?.hide()
                self?.delegate?.didClick(at: index, targetView: targetView)
                }.disposed(by: rx.disposeBag)
        }

        let layoutGuide = UILayoutGuide()
        contentView.addLayoutGuide(layoutGuide)
        guard let targetSuperView = targetView.superview else { fatalError() }
        let frame = targetSuperView.convert(targetView.frame, to: superView)

        let gaps: CGFloat = 5.0

        switch direction {
        case .leftTop:
            containerView.layer.anchorPoint = CGPoint(x: 1, y: 1)
            containerView.snp.makeConstraints { (m) in
                m.size.equalTo(layoutGuide)
                m.centerX.equalTo(layoutGuide.snp.right).offset(offset.x)
                m.centerY.equalTo(layoutGuide.snp.bottom).offset(offset.y)
            }

            layoutGuide.snp.makeConstraints { (m) in
                m.right.equalTo(contentView).offset(frame.maxX - superView.frame.width)
                m.bottom.equalTo(contentView).offset(frame.minY - superView.frame.height - gaps)
            }
        case .leftBottom:
            containerView.layer.anchorPoint = CGPoint(x: 1, y: 0)
            containerView.snp.makeConstraints { (m) in
                m.size.equalTo(layoutGuide)
                m.centerX.equalTo(layoutGuide.snp.right).offset(offset.x)
                m.centerY.equalTo(layoutGuide.snp.top).offset(offset.y)
            }

            layoutGuide.snp.makeConstraints { (m) in
                m.right.equalTo(contentView).offset(frame.maxX - superView.frame.width)
                m.top.equalTo(contentView).offset(frame.maxY + gaps)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate var isInteractivePopGestureRecognizerEnabled: Bool?

    override func show(animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        super.show(animations: animations, completion: completion)
        let animation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)!
        animation.fromValue = NSValue(cgSize: CGSize(width: 0, height: 0))
        animation.toValue = NSValue(cgSize: CGSize(width: 1, height: 1))
        animation.springBounciness = 10
        containerView.layer.pop_add(animation, forKey: "layerScaleSmallSpringAnimation")

        isInteractivePopGestureRecognizerEnabled = UIViewController.current?.navigationController?.interactivePopGestureRecognizer?.isEnabled
        UIViewController.current?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func hide(animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        super.hide(animations: animations, completion: completion)
        let animation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)!
        animation.fromValue = NSValue(cgSize: CGSize(width: 1, height: 1))
        animation.toValue = NSValue(cgSize: CGSize(width: 0, height: 0))
        animation.springBounciness = 10
        containerView.layer.pop_add(animation, forKey: "layerScaleSmallSpringAnimation")

        if let isEnabled = isInteractivePopGestureRecognizerEnabled {
            UIViewController.current?.navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
            isInteractivePopGestureRecognizerEnabled = nil
        }
    }
}
