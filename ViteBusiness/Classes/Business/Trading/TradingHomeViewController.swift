//
//  TradingHomeViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit

class TradingHomeViewController: BaseViewController {

    let segmentView = SegmentView()
    let containerView = UIView()

    #if DEBUG || TEST
    let spotVC = SpotViewController(symbol: DebugService.instance.config == DebugService.Config.test ? "VTT-000_VITE" : "VITE_BTC-000")
    #else
    let spotVC = SpotViewController(symbol: "VITE_BTC-000")
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    func setupView() {
        view.addSubview(segmentView)
        view.addSubview(containerView)

        segmentView.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
            m.left.right.equalToSuperview()
        }

        containerView.snp.makeConstraints { (m) in
            m.top.equalTo(segmentView.snp.bottom)
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }

        containerView.addSubview(spotVC.view)
        spotVC.view.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        addChild(spotVC)
        spotVC.didMove(toParent: self)
    }

    func bind() {
        segmentView.changed = { index in
            plog(level: .debug, log: index)
            if index == 1 {
                WebHandler.openMarketMining()
            } else if index == 2 {
                WebHandler.openMarketDividend()
            }

            DispatchQueue.main.async {
                self.segmentView.index = 0
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ViteBalanceInfoManager.instance.registerFetch()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ViteBalanceInfoManager.instance.unregisterFetch()
    }
}

extension TradingHomeViewController {

    class SegmentView: UIView {

        let buttons = [
            makeSegmentButton(title: R.string.localizable.tradingHomePageSegmentSpot()),
            makeSegmentButton(title: R.string.localizable.tradingHomePageSegmentMining()),
            makeSegmentButton(title: R.string.localizable.tradingHomePageSegmentBonus())
        ]

        var changed: ((Int) -> Void)?

        var index: Int = 0 {
            didSet {
                self.updateState()
            }
        }


        override init(frame: CGRect) {
            super.init(frame: frame)

            for (index, button) in buttons.enumerated() {
                addSubview(button)
                button.snp.makeConstraints { (m) in
                    m.top.equalToSuperview().offset(17)
                    m.bottom.equalToSuperview().offset(-10)
                    if index == 0 {
                        m.left.equalToSuperview().offset(24)
                    } else {
                        m.left.equalTo(buttons[index - 1].snp.right).offset(10)
                        m.width.equalTo(buttons[index - 1])
                    }

                    if index == buttons.count - 1 {
                        m.right.equalToSuperview().offset(-24)
                    }
                }

                button.rx.tap.bind { [weak self] in
                    guard let `self` = self else { return }
                    self.index = index
                    self.changed?(index)
                }.disposed(by: rx.disposeBag)
            }
            updateState()
        }

        func updateState() {
            for (i, b) in self.buttons.enumerated() {
                b.isEnabled = (self.index != i)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        static func makeSegmentButton(title: String) -> UIButton {
            let ret = UIButton()
            ret.setTitle(title, for: .normal)
            ret.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            ret.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.7), for: .normal)
            ret.setTitleColor(UIColor(netHex: 0x007AFF), for: .disabled)
            ret.setBackgroundImage(R.image.icon_trading_segment_unselected_fram()?.resizable, for: .normal)
            ret.setBackgroundImage(R.image.icon_trading_segment_selected_fram()?.resizable, for: .disabled)
            return ret
        }
    }


}
