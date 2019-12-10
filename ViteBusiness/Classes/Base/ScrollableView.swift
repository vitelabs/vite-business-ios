//
//  ScrollableView.swift
//  Vite
//
//  Created by Stone on 2018/9/25.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit

class ScrollableView: UIScrollView {

    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }

    init(insets: UIEdgeInsets = UIEdgeInsets.zero) {
        super.init(frame: CGRect.zero)

        addSubview(stackView)
        stackView.snp.makeConstraints { (m) in
            m.top.equalTo(self).offset(insets.top)
            m.left.equalTo(self).offset(insets.left)
            m.right.equalTo(self).offset(-insets.right)
            m.bottom.equalTo(self).offset(-insets.bottom)
            m.width.equalTo(self).offset(-(insets.left + insets.right))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: frame.width, height: contentSize.height)
    }
}

extension UIStackView {
    func addPlaceholder(height: CGFloat) {
        addArrangedSubview(UIView.placeholderView(height: height))
    }
}

extension UIView {
    static func placeholderView(height: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.snp.makeConstraints { $0.height.equalTo(height) }
        return view
    }

    func padding(_ insets: UIEdgeInsets) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(self)
        self.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(insets.top)
            m.left.equalToSuperview().offset(insets.left)
            m.right.equalToSuperview().offset(-insets.right)
            m.bottom.equalToSuperview().offset(-insets.bottom)
        }

        return view
    }

    func centerX() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(self)
        self.snp.makeConstraints { (m) in
            m.top.bottom.centerX.equalToSuperview()
        }
        return view
    }

    func padding(horizontal: CGFloat) -> UIView {
        return padding(UIEdgeInsets(top: 0, left: horizontal, bottom: 0, right: horizontal))
    }
}
