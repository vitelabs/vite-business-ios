//
//  MiningViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/1.
//

import Foundation
import Then

class MiningViewController: BaseViewController {


    let manager: DNSPageViewManager = {

        let titles = [
            R.string.localizable.miningPageSegmentTrading(),
            R.string.localizable.miningPageSegmentStaking(),
            R.string.localizable.miningPageSegmentInvite(),
            R.string.localizable.miningPageSegmentMaking()
        ]

        let viewControllers = [
            MiningTradingViewController(),
            MiningStakingViewController(),
            MiningInviteViewController(),
            MiningMakingViewController()
        ]

        let pageStyle = DNSPageStyle()
        pageStyle.isShowBottomLine = true
        pageStyle.bottomLineRadius = 0
        pageStyle.isTitleViewScrollEnabled = true
        pageStyle.titleViewBackgroundColor = UIColor.clear
        pageStyle.titleSelectedColor = UIColor.init(netHex: 0x3E4A59)
        pageStyle.titleColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
        pageStyle.titleFont = UIFont.boldSystemFont(ofSize: 13)
        pageStyle.bottomLineColor = Colors.blueBg
        pageStyle.bottomLineHeight = 2
        pageStyle.bottomLineWidth = 20

        return DNSPageViewManager(style: pageStyle, titles: titles, childViewControllers: viewControllers)
    }()




    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    fileprivate func setupView() {

        let hLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
        }

        view.addSubview(manager.titleView)
        view.addSubview(manager.contentView)
        view.addSubview(hLine)

        manager.contentView.delegate = self

        manager.titleView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(9)
            make.right.equalToSuperview().offset(-9)
            make.height.equalTo(36)
        }

        manager.contentView.snp.makeConstraints { (make) in
            make.top.equalTo(manager.titleView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }

        hLine.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(12)
            m.top.equalTo(manager.titleView.snp.bottom)
            m.height.equalTo(CGFloat.singleLineWidth)
        }
    }

    fileprivate func bind() {


    }
}

extension MiningViewController: DNSPageContentViewDelegate {
    func contentView(_ contentView: DNSPageContentView, didEndScrollAt index: Int) {
        self.manager.titleView.contentView(contentView, didEndScrollAt: index)
        for (i, label) in self.manager.titleView.titleLabels.enumerated() {
            if i == index {
                label.textColor = self.manager.titleView.style.titleSelectedColor
            } else {
                label.textColor = self.manager.titleView.style.titleColor
            }
        }
    }

    func contentView(_ contentView: DNSPageContentView, scrollingWith sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        self.manager.titleView.contentView(contentView, scrollingWith: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
}
