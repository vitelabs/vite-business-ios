//
//  MiningColorfulView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/3.
//

import Foundation

class MiningColorfulView: UIView {

    static let height: CGFloat = 78

    let leftButton = UIButton().then {
        $0.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .normal)
        $0.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
    }

    let rightButton = UIButton().then {
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.setTitleColor(UIColor.white.highlighted, for: .highlighted)
        $0.setImage(R.image.icon_mining_trading_right_white(), for: .normal)
        $0.setImage(R.image.icon_mining_trading_right_white()?.highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2)
    }

    let valueLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.numberOfLines = 1
        $0.text = "--.--"
    }


    init(leftText: String, leftClicked: (() -> Void)?, rightText: String, rightClicked: @escaping () -> Void) {
        super.init(frame: .zero)

        leftButton.setTitle(leftText, for: .normal)
        rightButton.setTitle(rightText, for: .normal)

        layer.masksToBounds = true
        layer.cornerRadius = 2
        backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: CGRect(x: 0, y: 0, width: kScreenW - 24, height: type(of: self).height), colors: TokenInfo.BuildIn.vite.value.coinBackgroundGradientColors)

        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(valueLabel)

        leftButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(12)
            m.left.equalToSuperview().offset(12)
        }

        rightButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(12)
            m.right.equalToSuperview().offset(-12)
        }

        valueLabel.snp.makeConstraints { (m) in
            m.top.equalTo(leftButton.snp.bottom).offset(10)
            m.left.right.equalToSuperview().inset(12)
        }

        snp.makeConstraints { (m) in
            m.height.equalTo(type(of: self).height)
        }

        if let leftClicked = leftClicked {
            leftButton.setImage(R.image.icon_mining_trading_infor(), for: .normal)
            leftButton.setImage(R.image.icon_mining_trading_infor()?.highlighted, for: .highlighted)
            leftButton.rx.tap.bind {
                leftClicked()
            }.disposed(by: rx.disposeBag)
        }

        rightButton.rx.tap.bind {
            rightClicked()
        }.disposed(by: rx.disposeBag)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
