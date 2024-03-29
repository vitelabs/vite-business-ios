//
//  BifrostBusyView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import UIKit

class BifrostBusyView: UIView {

    let headerLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    let contentLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x24272B, alpha: 0.6)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let cancelButton = UIButton(style: .whiteWithShadow, title: R.string.localizable.cancel())
    let confirmButton = UIButton(style: .blueWithShadow, title: R.string.localizable.confirm())

    let scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)).then {
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
    }

    init(showButton: Bool) {
        super.init(frame: CGRect.zero)

        let imageView = UIImageView(image: R.image.icon_vb_placeholder_busy())

        let whiteView = UIImageView(image: R.image.background_button_white()?.resizable).then {
            $0.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowOffset = CGSize(width: 0, height: 5)
            $0.layer.shadowRadius = 20
        }

        headerLabel.text = R.string.localizable.bifrostHomePageBusyHeader()
        contentLabel.text = R.string.localizable.bifrostHomePageBusyContent()

        addSubview(imageView)
        addSubview(headerLabel)
        addSubview(contentLabel)

        addSubview(whiteView)
        addSubview(scrollView)

        imageView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(26)
            m.centerX.equalToSuperview()
        }

        headerLabel.snp.makeConstraints { (m) in
            m.top.equalTo(imageView.snp.bottom).offset(20)
            m.left.equalToSuperview().offset(15)
            m.right.equalToSuperview().offset(-15)
        }

        contentLabel.snp.makeConstraints { (m) in
            m.top.equalTo(headerLabel.snp.bottom).offset(10)
            m.left.equalToSuperview().offset(15)
            m.right.equalToSuperview().offset(-15)
        }

        whiteView.snp.makeConstraints { (m) in
            m.edges.equalTo(scrollView)
        }

        imageView.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        headerLabel.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        contentLabel.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)

        imageView.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        headerLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        contentLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)

        if showButton {
            scrollView.snp.makeConstraints { (m) in
                m.top.equalTo(contentLabel.snp.bottom).offset(20)
                m.left.equalToSuperview().offset(24)
                m.right.equalToSuperview().offset(-24)
            }

            addSubview(cancelButton)
            addSubview(confirmButton)

            cancelButton.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(scrollView.snp.bottom).offset(24)
                make.left.equalToSuperview().offset(24)
                make.height.equalTo(50)
                make.bottom.equalToSuperview().offset(-24)
            }

            confirmButton.snp.makeConstraints { (make) -> Void in
                make.top.bottom.width.height.equalTo(cancelButton)
                make.left.equalTo(cancelButton.snp.right).offset(23)
                make.right.equalToSuperview().offset(-24)
            }
        } else {
            scrollView.snp.makeConstraints { (m) in
                m.top.equalTo(contentLabel.snp.bottom).offset(20)
                m.left.equalToSuperview().offset(24)
                m.right.equalToSuperview().offset(-24)
                m.bottom.equalToSuperview().offset(-24)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(_ info: BifrostConfirmInfo) {

        scrollView.stackView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }

        let titleView = BifrostConfirmTitleView(title: info.title)
        scrollView.stackView.addArrangedSubview(titleView)

        var previousIsUnderscored: Bool?
        for itemInfo in info.items {
            if let p = previousIsUnderscored, !(p && itemInfo.isUnderscored) {
                scrollView.stackView.addPlaceholder(height: 16)
            }
            let itemView = BifrostConfirmItemView(info: itemInfo)
            scrollView.stackView.addArrangedSubview(itemView)
            previousIsUnderscored = itemInfo.isUnderscored
        }

        if let p = previousIsUnderscored, !p {
            scrollView.stackView.addPlaceholder(height: 16)
        }
    }

}
