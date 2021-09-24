//
//  SpotHistoryFilterView.swift
//  ViteBusiness
//
//  Created by stone on 2021/9/22.
//

import UIKit
import ActiveLabel

class SpotHistoryFilterView: BottomPopView {

    public init(superview: UIView, filter: SpotHistoryViewController.Filter, completion: @escaping (SpotHistoryViewController.Filter) -> ()) {
        
        super.init(title: R.string.localizable.spotHistoryPageFilterTitle(), buttons: [], superview: superview)

        let dataTitleView = TitleVeiw(title: R.string.localizable.spotHistoryPageFilterDateTitle())
        let pairTitleView = TitleVeiw(title: R.string.localizable.spotHistoryPageFilterTokenTitle())
        let sideTitleView = TitleVeiw(title: R.string.localizable.spotHistoryPageFilterSideTitle())
        let statusTitleView = TitleVeiw(title: R.string.localizable.spotHistoryPageFilterStatusTitle())
        
        let dataView = SegmentVeiw(titles: [
            R.string.localizable.spotHistoryPageFilterAll(),
            R.string.localizable.spotHistoryPageFilterDate3m(),
            R.string.localizable.spotHistoryPageFilterDate1m(),
            R.string.localizable.spotHistoryPageFilterDate1w(),
            R.string.localizable.spotHistoryPageFilterDate1d()
        ], index: filter.dataIndex)
        
        let pairView = PairVeiw(quoteTokenSymbol: filter.quoteTokenSymbol, tradeTokenSymbol: filter.tradeTokenSymbol)
        
        let sideView = SegmentVeiw(titles: [
            R.string.localizable.spotHistoryPageFilterAll(),
            R.string.localizable.spotHistoryPageFilterSideBuy(),
            R.string.localizable.spotHistoryPageFilterSideSell()
        ], index: filter.sideIndex)
        
        let statusView = SegmentVeiw(titles: [
            R.string.localizable.spotHistoryPageFilterAll(),
            R.string.localizable.spotHistoryPageFilterStatusOpen(),
            R.string.localizable.spotHistoryPageFilterStatusCompleted(),
            R.string.localizable.spotHistoryPageFilterStatusCanceled(),
            R.string.localizable.spotHistoryPageFilterStatusFailed()
        ], index: filter.statusIndex)
        
        let buttonView = ButtonVeiw()
        
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }

        stackView.addArrangedSubview(dataTitleView)
        stackView.addArrangedSubview(dataView)
        stackView.addArrangedSubview(pairTitleView)
        stackView.addArrangedSubview(pairView)
        stackView.addArrangedSubview(sideTitleView)
        stackView.addArrangedSubview(sideView)
        stackView.addArrangedSubview(statusTitleView)
        stackView.addArrangedSubview(statusView)
        stackView.addPlaceholder(height: 24)
        stackView.addArrangedSubview(buttonView)
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(-27)
            m.left.right.bottom.equalToSuperview()
        }
        
        buttonView.clearButton.rx.tap.bind {
            dataView.updateIndex(0)
            pairView.update(quoteTokenSymbol: nil, tradeTokenSymbol: nil)
            sideView.updateIndex(0)
            statusView.updateIndex(0)
        }.disposed(by: rx.disposeBag)
        
        buttonView.okButton.rx.tap.bind { [weak self] in
            var filter = SpotHistoryViewController.Filter()
            filter.quoteTokenSymbol = pairView.quoteTokenSymbol
            filter.tradeTokenSymbol = pairView.tradeTokenSymbol
            filter.updateData(dataView.index)
            filter.updateSide(sideView.index)
            filter.updateStatus(statusView.index)
            self?.hide()
            completion(filter)
        }.disposed(by: rx.disposeBag)
        
        pairView.button.rx.tap.bind { [weak self] in
            let vc = SpotHistorySelectPairViewController() { [weak self] ret in
                guard let `self` = self else { return }
                pairView.update(quoteTokenSymbol: ret.quoteTokenSymbol, tradeTokenSymbol: ret.tradeTokenSymbol)
            }
            vc.modalPresentationStyle = .fullScreen
            UIViewController.current?.navigationController?.present(vc, animated: true, completion: nil)
        }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SpotHistoryFilterView {
    class TitleVeiw: UIView {
        let label = UILabel().then {
            $0.numberOfLines = 0
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        }
        
        init(title: String) {
            super.init(frame: .zero)
            
            label.text = title
            addSubview(label)
            label.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(20)
                m.left.equalToSuperview()
                m.bottom.equalToSuperview().offset(-16)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class SegmentVeiw: UIView {
        
        fileprivate(set) var index: Int = 0
        fileprivate var buttons: [UIButton] = []
        
        func updateIndex(_ index: Int) {
            self.index = index
            for (i, button) in buttons.enumerated() {
                button.isEnabled = i != index
            }
        }
        
        init(titles: [String], index: Int) {
            super.init(frame: .zero)
            self.index = index
            var last: UIView? = nil
            for (i, title) in titles.enumerated() {
                let button = makeButton(title: title, tag: i)
                button.isEnabled = i != index
                addSubview(button)
                buttons.append(button)
                button.snp.makeConstraints { (m) in
                    m.top.bottom.equalToSuperview()
                    m.height.equalTo(26)
                    m.width.equalTo(58)
                    if let l = last {
                        m.left.equalTo(l.snp.right).offset(9)
//                        m.width.equalTo(l)
                    } else {
                        m.left.equalToSuperview()
                    }
                    
//                    if i == titles.count - 1 {
//                        m.right.equalToSuperview()
//                    }
                }
                last = button
                
                button.addTarget(self, action: #selector(onClicked(_:)), for: .touchUpInside)
            }
        }
        
        @objc private func onClicked(_ sender: UIButton) {
            sender.isEnabled = false
            buttons[index].isEnabled = true
            index = sender.tag
        }
        
        func makeButton(title: String, tag: Int) -> UIButton {
            let button =  UIButton()
            button.tag = tag
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            
            button.setBackgroundImage(R.image.background_button_blue()?.resizable, for: .disabled)
            button.setTitleColor(.white, for: .disabled)
                
            button.setBackgroundImage(R.image.background_button_gray()?.resizable, for: .normal)
            button.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            return button
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class PairVeiw: UIView {
        let label = UILabel().then {
            $0.numberOfLines = 0
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
        
        let button = UIButton(style: .gray, title: "")
        
        private(set) var quoteTokenSymbol: String? = nil
        private(set) var tradeTokenSymbol: String? = nil
        
        func update(quoteTokenSymbol: String?, tradeTokenSymbol: String?) {
            self.quoteTokenSymbol = quoteTokenSymbol
            self.tradeTokenSymbol = tradeTokenSymbol
            
            if let q = quoteTokenSymbol, let t = tradeTokenSymbol {
                label.text = "\(t)/\(q)"
            } else {
                label.text = R.string.localizable.spotHistoryPageFilterAll()
            }
        }
        
        init(quoteTokenSymbol: String?, tradeTokenSymbol: String?) {
            super.init(frame: .zero)
            
            
            button.backgroundColor = UIColor(netHex: 0x3E4A59, alpha: 0.05)
            let imageView = UIImageView(image: R.image.icon_dex_home_address_arrows())
            
            update(quoteTokenSymbol: quoteTokenSymbol, tradeTokenSymbol: tradeTokenSymbol)
            addSubview(button)
            addSubview(label)
            addSubview(imageView)
            button.snp.makeConstraints { (m) in
                m.top.equalToSuperview()
                m.left.equalToSuperview()
                m.right.equalToSuperview()
                m.bottom.equalToSuperview()
                m.height.equalTo(50)
            }
            label.snp.makeConstraints { (m) in
                m.left.equalTo(button).offset(15)
                m.centerY.equalTo(button)
            }
            imageView.snp.makeConstraints { (m) in
                m.right.equalTo(button).offset(-15)
                m.centerY.equalTo(button)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class ButtonVeiw: UIView {
        let clearButton = UIButton(style: .gray, title: R.string.localizable.spotHistoryPageFilterButtonClear())
        let okButton = UIButton(style: .blue, title: R.string.localizable.confirmButtonTitle())
        
        init() {
            super.init(frame: .zero)
        
            addSubview(clearButton)
            addSubview(okButton)
            clearButton.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.equalToSuperview()
                m.height.equalTo(40)
            }
            okButton.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.equalTo(clearButton.snp.right).offset(21)
                m.right.equalToSuperview()
                m.width.equalTo(clearButton)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
