//
//  EthViteExchangeViteAddressView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/5/9.
//

import UIKit

class EthViteExchangeViteAddressView: UIView {

    let titleLabel = UILabel().then {
        $0.textColor = Colors.titleGray
        $0.font = AppStyle.formHeader.font
    }

    let textLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }

    var button: UIButton? = UIButton().then {
        $0.setTitle(R.string.localizable.ethViteExchangePageAddressChangeButtonTitle(), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)

        let lineImageView = UIImageView(image: R.image.blue_dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

        $0.addSubview(lineImageView)
        let titleLabel = $0.titleLabel!
        lineImageView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalTo(titleLabel).offset(2)
        }
    }

    init() {
        super.init(frame: CGRect.zero)

        titleLabel.text = R.string.localizable.ethViteExchangePageToAddressTitle()

        addSubview(titleLabel)
        addSubview(textLabel)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self).offset(24)
            m.left.equalTo(self)
        }

        textLabel.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(10)
            m.left.equalTo(self)
            m.right.equalTo(self)
            m.height.equalTo(50)
            m.bottom.equalTo(self).offset(-16)
        }

        let backView = UIView()
        backView.backgroundColor = UIColor(netHex: 0x007AFF).withAlphaComponent(0.06)
        backView.layer.borderColor = UIColor(netHex: 0x007AFF).withAlphaComponent(0.12).cgColor
        backView.layer.borderWidth = CGFloat.singleLineWidth
        insertSubview(backView, at: 0)
        backView.snp.makeConstraints { (m) in
            m.top.bottom.equalTo(self)
            m.left.equalTo(self).offset(-24)
            m.right.equalTo(self).offset(24)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EthViteExchangeViteAddressView {

    enum Style {
        case chouseAddressButton
        case copyButton
        case none
    }

    class func addressView(style: EthViteExchangeViteAddressView.Style) -> EthViteExchangeViteAddressView {
        let addressView = EthViteExchangeViteAddressView()

        if style == .none {

        } else if style == .copyButton {
            let button = UIButton()
            addressView.button = button

            addressView.addSubview(button)

            button.setImage(R.image.icon_button_paste_light_gray(), for: .normal)

            button.snp.makeConstraints { (m) in
                m.centerY.equalTo(addressView.titleLabel)
                m.right.equalTo(addressView)
                m.size.equalTo(CGSize.init(width: 20, height: 20))
            }

        } else if style == .chouseAddressButton {
            let button = UIButton().then {
                $0.setTitle(R.string.localizable.ethViteExchangePageAddressChangeButtonTitle(), for: .normal)
                $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
                $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)

                let lineImageView = UIImageView(image: R.image.blue_dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

                $0.addSubview(lineImageView)
                let titleLabel = $0.titleLabel!
                lineImageView.snp.makeConstraints { (m) in
                    m.left.right.equalToSuperview()
                    m.bottom.equalTo(titleLabel).offset(2)
                }
            }

            addressView.button = button
            addressView.addSubview(button)

            button.snp.makeConstraints { (m) in
                m.centerY.equalTo(addressView.titleLabel)
                m.right.equalTo(addressView)
            }
        }

        return addressView

    }
}
