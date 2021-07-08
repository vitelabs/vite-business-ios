//
//  ChainSelectView.swift
//  ViteBusiness
//
//  Created by stone on 2021/3/25.
//

import UIKit

class ChainSelectView: UIView {
    fileprivate let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.text = R.string.localizable.crosschainChainSelectTitle()
    }
    
    fileprivate let scrollableView = HorizontalScrollableView().then {
        $0.stackView.spacing = 19
    }
    
    fileprivate var buttons: [UIButton] = []
    
    var clicked: ((Int) -> ())? = nil
    
    func select(_ index: Int) {
        guard index < buttons.count else { return }
        for i in 0..<buttons.count {
            buttons[i].isSelected = (index == i)
        }
    }
    
    init(mappedTokenExtraInfos: [MappedTokenExtraInfo]) {
        
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(scrollableView)
        
        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.right.equalToSuperview()
        }
        
        scrollableView.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(9)
            m.left.right.equalToSuperview()
            m.bottom.equalToSuperview()
            m.height.equalTo(24)
        }
        
        for i in 0..<mappedTokenExtraInfos.count {
            let info = mappedTokenExtraInfos[i]
            
            let button = type(of: self).makeSegmentButton(title: info.chainName)
            buttons.append(button)
            scrollableView.stackView.addArrangedSubview(button)
            
            if i == 0 {
                button.isSelected = true
            }
            
            button.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                guard !self.buttons[i].isSelected else { return }
                self.clicked?(i)
            }.disposed(by: rx.disposeBag)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func makeSegmentButton(title: String) -> UIButton {
        let ret = UIButton()
        ret.backgroundColor = UIColor(netHex: 0x007AFF, alpha: 0.05)
        ret.setTitle(title, for: .normal)
        ret.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        ret.setTitleColor(UIColor(netHex: 0x5E6875), for: .normal)
        ret.setTitleColor(UIColor(netHex: 0x007AFF), for: .selected)
        ret.setTitleColor(UIColor(netHex: 0x007AFF), for: .highlighted)
        ret.setBackgroundImage(R.image.icon_trading_segment_unselected_fram()?.resizable, for: .normal)
        ret.setBackgroundImage(R.image.icon_trading_segment_selected_fram()?.resizable, for: .selected)
        ret.setBackgroundImage(R.image.icon_trading_segment_selected_fram()?.resizable, for: .highlighted)
        ret.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        return ret
    }
    
    class HorizontalScrollableView: UIScrollView {

        let stackView = UIStackView().then {
            $0.axis = .horizontal
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
                m.height.equalTo(self).offset(-(insets.top + insets.bottom))
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override var intrinsicContentSize: CGSize {
            layoutIfNeeded()
            return CGSize(width: contentSize.width, height: frame.height)
        }
    }
}

