//
//  DexAssetsHomeViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/7/14.
//

import Foundation

class DexAssetsHomeViewController: BaseViewController {

    enum PType {
        case wallet
        case vitex
    }

    let walletVC = DexAssetsHomeTableViewController(type: .wallet)
    let dexVC = DexAssetsHomeTableViewController(type: .vitex)

    let navView = NavView()

    lazy var contentView: LTSimpleManager = {
        let titles = [
            R.string.localizable.dexHomePageSegmentWallet(),
            R.string.localizable.dexHomePageSegmentDex()
        ]

        let viewControllers = [
            self.walletVC,
            self.dexVC
        ]

        let layout: LTLayout = {
            let layout = LTLayout()
            layout.sliderHeight = 38

            layout.bottomLineHeight = 2
            layout.bottomLineCornerRadius = 0
            layout.bottomLineColor = UIColor.init(netHex: 0xffffff)

            layout.scale = 1
            layout.lrMargin = 24
            layout.titleMargin = 30
            layout.titleFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
            layout.titleViewBgColor = .clear
            layout.titleColor = UIColor.init(netHex: 0xffffff, alpha: 0.7)
            layout.titleSelectColor = UIColor.init(netHex: 0xffffff)
            layout.isColorAnimation = false

            layout.pageBottomLineColor = .clear
            layout.pageBottomLineHeight = CGFloat.singleLineWidth

            layout.showsHorizontalScrollIndicator = false

            return layout
        }()

        let frame: CGRect =  {
            let statusBarH = UIApplication.shared.statusBarFrame.size.height
            let navH: CGFloat = 44
            let bottomSafeH: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
            var H: CGFloat = kScreenH - statusBarH - navH - bottomSafeH
            return CGRect(x: 0, y: statusBarH + navH, width: kScreenW, height: H)
        }()

        let contentView = LTSimpleManager(frame: frame, viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout)

        contentView.configHeaderView {[weak self] in
            guard let strongSelf = self else { return nil }
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
            headerView.backgroundColor = .clear
            return headerView
        }

        contentView.scrollToIndex(index: 0)
        contentView.backgroundColor = .clear
        contentView.tableView.backgroundColor = .clear
        contentView.tableView.bounces = false
        return contentView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    func setupView() {

        let navBgView = UIImageView(image: R.image.dex_nav_bg())

        view.addSubview(navBgView)
        view.addSubview(contentView)
        view.addSubview(navView)

        navBgView.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(142)
        }

        contentView.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuideSnpTop).offset(44)
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }
    }

    func bind() {
        contentView.tableView.rx.contentOffset.bind { [weak self] contentOffset in
            guard let `self` = self else { return }
            plog(level: .debug, log: "fdsfsd \(contentOffset)")
            let statusBarH = UIApplication.shared.statusBarFrame.size.height
            let height = statusBarH + 104 - contentOffset.y
            self.navView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: height)
            let titleAlpha = max(min(contentOffset.y / 60.0, 1.0), 0.0)
            let otherAlpha = 1 - titleAlpha
            self.navView.titleLabel.alpha = titleAlpha
            self.navView.valuationTitleLabel.alpha = otherAlpha
            self.navView.btcLabel.alpha = otherAlpha
            self.navView.legalLabel.alpha = otherAlpha
        }.disposed(by: rx.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


extension DexAssetsHomeViewController {

    class NavView: UIView {

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            $0.textColor = UIColor(netHex: 0xffffff)
            $0.text = R.string.localizable.dexHomePageNavTitle()
        }

        let valuationTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(netHex: 0xffffff)
            $0.text = R.string.localizable.dexHomePageNavBtcValuationTitle()
        }

        let btcLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            $0.textColor = UIColor(netHex: 0xffffff)
            $0.text = "dfsafdsafsda"
        }

        let legalLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(netHex: 0xffffff, alpha: 0.7)
            $0.text = "≈¥496,947,904,51fdsfsdfs"
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            backgroundColor = .clear

            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (m) in
                m.top.equalTo(self.safeAreaLayoutGuideSnpTop).offset(11)
                m.centerX.equalToSuperview()
            }

            addSubview(valuationTitleLabel)
            addSubview(btcLabel)
            addSubview(legalLabel)

            valuationTitleLabel.snp.makeConstraints { (m) in
                m.top.equalTo(self.safeAreaLayoutGuideSnpTop).offset(14)
                m.left.right.equalToSuperview().inset(24)
            }

            btcLabel.snp.makeConstraints { (m) in
                m.top.equalTo(valuationTitleLabel.snp.bottom).offset(12)
                m.left.right.equalToSuperview().inset(24)
            }

            legalLabel.snp.makeConstraints { (m) in
                m.top.equalTo(btcLabel.snp.bottom).offset(4)
                m.left.right.equalToSuperview().inset(24)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }
}
