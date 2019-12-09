//
//  SendItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/1.
//

import UIKit

class TopBottomLabelsView : UIView {

    let topLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.textAlignment = .right
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    let bottomLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.textAlignment = .right
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topLabel)
        addSubview(bottomLabel)

        topLabel.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
        }

        bottomLabel.snp.makeConstraints { (m) in
            m.top.equalTo(topLabel.snp.bottom).offset(4)
            m.bottom.left.right.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
        case labels(topStyle: TextStyle, bottomStyle: TextStyle)
        case button(style: ButtonStyle)

        func createRightView() -> UIView? {
            switch self {
            case .none:
                return nil
            case .label(let style):
                return style.createLabel()
            case .labels(let topStyle, let bottomStyle):
                let view = TopBottomLabelsView()
                switch topStyle {
                case .text(let string):
                    view.topLabel.text = string
                case .attributed(let string):
                    view.topLabel.attributedText = string
                }
                switch bottomStyle {
                case .text(let string):
                    view.bottomLabel.text = string
                case .attributed(let string):
                    view.bottomLabel.attributedText = string
                }
                return view
            case .button(let style):
                return style.createButton()
            }
        }
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
