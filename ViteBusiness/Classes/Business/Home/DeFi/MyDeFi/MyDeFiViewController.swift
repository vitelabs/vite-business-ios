//
//  MyDeFiViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import UIKit

class MyDeFiViewController: BaseViewController {

    private let loanHeaderView = MyDeFiLoanHeaderView()
    private let subscribeHeaderView = MyDeFiSubscribeHeaderView()

    private let manager: DNSPageViewManager = {
        let pageStyle = DNSPageStyle()
        pageStyle.isShowBottomLine = true
        pageStyle.isTitleViewScrollEnabled = true
        pageStyle.titleViewBackgroundColor = .clear
        pageStyle.titleSelectedColor = Colors.titleGray
        pageStyle.titleColor = Colors.titleGray_61
        pageStyle.titleFont = Fonts.Font13
        pageStyle.bottomLineColor = Colors.blueBg
        pageStyle.bottomLineHeight = 2
        pageStyle.bottomLineWidth = 20

        let titles = [
            R.string.localizable.defiMyPageMyLoanTitle(),
            R.string.localizable.defiMyPageMySubscribeTitle()
        ]

        let viewControllers = [
            MyDeFiLoanViewController(),
            MyDeFiSubscribeViewController()
        ]

        return DNSPageViewManager(style: pageStyle, titles: titles, childViewControllers: viewControllers)
    }()

    let filtrateButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setImage(R.image.icon_defi_home_down_button(), for: .normal)
        $0.setImage(R.image.icon_defi_home_down_button()?.highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: -1)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 7)
        $0.backgroundColor = UIColor(netHex: 0x007AFF, alpha: 0.06)
        $0.setTitle("ffff", for: .normal)
    }

    lazy var filtrateView = UIView().then {
        
        $0.addSubview(self.manager.titleView)
        self.manager.titleView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24 - 15)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview()
            m.height.equalTo(35)
        }

        $0.addSubview(self.filtrateButton)
        self.filtrateButton.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.height.equalTo(28)
            m.right.equalToSuperview().offset(-24)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    private func setupView() {
        self.view.backgroundColor = .white
        navigationTitleView = NavigationTitleView(title: R.string.localizable.defiMyPageTitle())

        view.addSubview(loanHeaderView)
        loanHeaderView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalToSuperview().inset(24)
        }

        view.addSubview(subscribeHeaderView)
        subscribeHeaderView.snp.makeConstraints { (m) in
            m.edges.equalTo(loanHeaderView)
        }

        view.addSubview(filtrateView)
        filtrateView.snp.makeConstraints { (m) in
            m.top.equalTo(loanHeaderView.snp.bottom).offset(8)
            m.left.right.equalToSuperview()
        }

        view.addSubview(manager.contentView)
        manager.contentView.snp.makeConstraints { (make) in
            make.top.equalTo(filtrateView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }
    }

    private func bind() {
        pageChanged(index: 0)
        manager.contentView.delegate = self
        manager.titleView.clickHandler = { [weak self] (titleView, index) in
            self?.pageChanged(index: index)
        }
    }

    private func pageChanged(index: Int) {
        if index == 0 {
            loanHeaderView.isHidden = false
            subscribeHeaderView.isHidden = true
        } else {
            loanHeaderView.isHidden = true
            subscribeHeaderView.isHidden = false
        }
    }

}

extension MyDeFiViewController: DNSPageContentViewDelegate {
    func contentView(_ contentView: DNSPageContentView, didEndScrollAt index: Int) {
        self.manager.titleView.contentView(contentView, didEndScrollAt: index)
        for (i, label) in self.manager.titleView.titleLabels.enumerated() {
            if i == index {
                label.textColor = self.manager.titleView.style.titleSelectedColor
            } else {
                label.textColor = self.manager.titleView.style.titleColor
            }
        }
        self.pageChanged(index: index)
    }

    func contentView(_ contentView: DNSPageContentView, scrollingWith sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        self.manager.titleView.contentView(contentView, scrollingWith: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
}

extension DeFiAPI.ProductStatus {
    var name: String {
        switch self {
        case .all:
            return R.string.localizable.defiMyPageMyLoanSortAll()
        case .onSale:
            return R.string.localizable.defiMyPageMyLoanSortOnSale()
        case .failed:
            return R.string.localizable.defiMyPageMyLoanSortFailed()
        case .success:
            return R.string.localizable.defiMyPageMyLoanSortSuccess()
        case .cancel:
            return R.string.localizable.defiMyPageMyLoanSortCancel()
        }
    }
}
