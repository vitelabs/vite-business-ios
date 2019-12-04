//
//  SendItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/1.
//

import UIKit

class SendItemView: UIView {

    enum TextStyle {
        case text(string: String)
        case attributed(string: NSAttributedString)

        func createLabel() -> UILabel {
            return UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
                $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                switch self {
                case .text(let string):
                    $0.text = string
                case .attributed(let string):
                    $0.attributedText = string
                }
            }

        }
    }

    enum ButtonStyle {
        case tip(clicked: () -> ())
        case custom(image: UIImage, clicked: () -> ())

        func createButton() -> UIButton {

            return UIButton().then {
                switch self {
                case .tip(let clicked):
                    $0.setImage(R.image.icon_button_tip(), for: .normal)
                    $0.setImage(R.image.icon_button_tip()?.highlighted, for: .highlighted)
                    $0.rx.tap.bind { clicked() }.disposed(by: $0.rx.disposeBag)
                case .custom(let image, let clicked):
                    $0.setImage(image, for: .normal)
                    $0.setImage(image.highlighted, for: .highlighted)
                    $0.rx.tap.bind { clicked() }.disposed(by: $0.rx.disposeBag)
                }
            }
        }
    }

    enum RightViewStyle {
        case none
        case label(style: TextStyle)
        case button(style: ButtonStyle)
    }

    enum TitleTipButtonStyle {
        case none
        case button(style: ButtonStyle)
    }

    let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    let separatorLine = UIView().then {
        $0.backgroundColor = Colors.lineGray
    }

    var rightView: UIView?
    var tipButton: UIButton?

    let rightViewStyle: RightViewStyle
    let titleTipButtonStyle: TitleTipButtonStyle

    init(title: String, rightViewStyle: RightViewStyle = .none, titleTipButtonStyle: TitleTipButtonStyle = .none) {
        self.titleLabel.text = title
        self.rightViewStyle = rightViewStyle
        self.titleTipButtonStyle = titleTipButtonStyle
        super.init(frame: CGRect.zero)

        addSubview(titleLabel)
        addSubview(separatorLine)

        titleLabel.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
            m.bottom.equalToSuperview().offset(-22)
        }

        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.bottom.left.right.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
