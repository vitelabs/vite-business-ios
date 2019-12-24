//
//  BuyDefiDetaolViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/12/10.
//

import UIKit
import ViteWallet
import RxSwift
import RxCocoa
import NSObject_Rx

class DeFiSubscriptionDetailViewController: BaseScrollableViewController {

    let productHash: String
    var loan: DeFiSubscription? {
        didSet {
            self.reloadView()
        }
    }

    init(productHash: String) {
        self.productHash = productHash
        super.init()
    }

    init(loan: DeFiSubscription) {
        self.productHash = loan.productHash
        self.loan = loan
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        refresh()
        bind()
    }

    func refresh() {
        if self.loan == nil {
            self.dataStatus = .loading
        }
        UnifyProvider.defi.getSubscriptionDetail(address: HDWalletManager.instance.account!.address, productHash: productHash).done { [weak self] (loan) in
            guard let `self` = self else { return }
            self.loan = loan
            self.dataStatus = .normal
        }.catch { [weak self] (error) in
            guard let `self` = self else { return }
            if self.loan == nil {
                self.dataStatus = .networkError(error, {[weak self] in
                    guard let `self` = self else { return }
                    self.refresh()
                })
            } else {
                Toast.show(error.localizedDescription)
            }
        }
    }

    // failed
    let token = ViteWalletConst.viteToken
    let titleView = NavigationTitleView(title: R.string.localizable.defiSubscriptionDetailTitle(), horizontal: 0)
    let header = DeFiProductInfoCard.init(title: R.string.localizable.defiCardSlogan(),
                                          status: .none,
                                          porgressDesc: "\(R.string.localizable.defiCardProgress())--%", progress: 0)

    //产品Hash
    lazy var idView = SendStaticItemView(title: R.string.localizable.defiItemIdTitle(), rightViewStyle: .label(style: .text(string: "--")))
    //认购金额
    lazy var mySubscribedAmountView = SendStaticItemView(title:R.string.localizable.defiSubscriptionDetailSubscriptionAmount(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var loanAmountView = SendStaticItemView(title:R.string.localizable.defiSubscriptionDetailTotalAmount(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    //借币总金额
    lazy var totalAmountView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailTotalAmount(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    //每份金额
    lazy var eachAmountView = SendStaticItemView(title: R.string.localizable.defiItemEachAmountTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    //预计总收益/每日收益”
    lazy var earningsView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailEstimatedTotalRevenuet(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    //借币期限”，“约***
    lazy var loanDurationView = SendStaticItemView(title: R.string.localizable.defiItemLoanDurationTitle(), rightViewStyle: .labels(topStyle: .attributed(string: DeFiFormater.loanDuration(text: "--")), bottomStyle: .text(string: R.string.localizable.defiSubscriptionPageDurationBlock("--"))))
    //年化收益率
    lazy var yearRateView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailRate(), rightViewStyle: .label(style: .text(string: "--%")))
    lazy var paidInterestView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailPaied(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var subscriptionDurationView = SendStaticItemView(title: R.string.localizable.defiItemSubscriptionDurationTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.subscriptionDuration(text: "--"))))
    lazy var subscribeAmountView = SendStaticItemView(title: R.string.localizable.defiItemSubscribeAmountTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var refundPaidInterestView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailAmountShallRefunded(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
        lazy var  remainingUnsoldView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailRemainingUnsold(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var publishTimeView = SendStaticItemView(title: R.string.localizable.defiItemPublishTimeTitle(), rightViewStyle: .label(style: .text(string: "--")))

    let refundButton = UIButton(style: .whiteWithShadow, title: R.string.localizable.defiSubscriptionDetailRefunding())


    // on sale
    lazy var leftCopiesView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailRemainingCopies(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit:R.string.localizable.defiItemCopysUnit()))))
    let buyButton = UIButton(style: .blueWithShadow, title: R.string.localizable.defiSubscriptionDetailBuy())

    let onSaleTip1 = TipTextView(text: R.string.localizable.defiSubscriptionDetailOnSaleTip1())
    let onSaleTip2 = TipTextView(text: R.string.localizable.defiSubscriptionDetailOnSaleTip2())
    let onSaleTip3 = TipTextView(text: R.string.localizable.defiSubscriptionDetailOnSaleTip3())
    let onSaleTip4 = TipTextView(text: R.string.localizable.defiSubscriptionDetailOnSaleTip4())

    // success
    lazy var usedAmountView = SendStaticItemView(title: R.string.localizable.defiItemUsedAmountTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var canUseAmountView = SendStaticItemView(title: R.string.localizable.defiItemCanUseAmountTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))

    lazy var successHeightView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailSuccessHeight(), rightViewStyle: .label(style: .text(string: "--")))
       lazy var successTimeView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailSuccessTime(), rightViewStyle: .label(style: .text(string: "--")))
    lazy var endHeightView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailEndTime(), rightViewStyle: .label(style: .text(string: "--")))
    lazy var estimatedEndTimeView = SendStaticItemView(title: R.string.localizable.defiSubscriptionDetailEstimatedEndTime(), rightViewStyle: .label(style: .text(string: "--")))


    lazy var successButton = UIButton(style: .blueWithShadow, title: R.string.localizable.defiSubscriptionDetailCheckTheYield())

    let successTip1 = TipTextView(text: R.string.localizable.defiSubscriptionDetailSuccessTip1())
    let successTip2 = TipTextView(text: R.string.localizable.defiSubscriptionDetailSuccessTip2())

    func setupView() {

        setNavTitle(title: R.string.localizable.defiSubscriptionDetailTitle(), bindTo: scrollView)
        scrollView.mj_header = RefreshHeader(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }

            UnifyProvider.defi.getSubscriptionDetail(address: HDWalletManager.instance.account!.address, productHash: self.productHash).done { [weak self] (loan) in
                       guard let `self` = self else { return }
                       self.scrollView.mj_header.endRefreshing()
                   }.catch { [weak self] (error) in
                      Toast.show(error.localizedDescription)
                   }
        })

        scrollView.alwaysBounceVertical = true
        reloadView()
        Observable<Int>.interval(1, scheduler: MainScheduler.instance).bind { [weak self] (_) in
            guard let loan = self?.loan else { return }
            guard loan.productStatus == .onSale else { return }
            self?.updateHeader()

        }.disposed(by: rx.disposeBag)
    }

    func updateHeader() {
        guard let loan = self.loan else { return }
        let attributedString: NSMutableAttributedString = {
            let (day, time) = loan.countDown(for: Date())
            let string = R.string.localizable.defiCardEndTime(day, time)
            let ret = NSMutableAttributedString(string: string)

            ret.addAttributes(
                text: string,
                attrs: [
                    NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x000000),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ])

            ret.addAttributes(
                text: day,
                attrs: [
                    NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x007AFF),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ])

            ret.addAttributes(
                text: time,
                attrs: [
                    NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x007AFF),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ])

            return ret
        }()

        let status: DeFiProductInfoCard.Status
        switch loan.productStatus {
        case .onSale:
            status = .onSale
        case .failed:
            status = .failed
        case .success:
            status = .success
        case .cancel:
            status = .cancel
        }
        header.config(
            title: R.string.localizable.defiCardSlogan(),
            status: status,
            progressDesc: "\(R.string.localizable.defiCardProgress())\(loan.loanCompletenessString)",
            progress: CGFloat(loan.loanCompleteness),
            deadLineDesc: loan.productStatus == .onSale ? attributedString : nil)
    }

    func reloadView() {

        let views = scrollView.stackView.arrangedSubviews
        views.forEach { $0.removeFromSuperview() }

        guard var loan = self.loan else { return }
        updateHeader()
        switch loan.productStatus {
        case .onSale:
            header.snp.remakeConstraints { $0.height.equalTo(header.size.height) }
            scrollView.stackView.addArrangedSubview(titleView)
            scrollView.stackView.addArrangedSubview(header)
            //产品Hash
            scrollView.stackView.addArrangedSubview(idView, topInset: 20)
            idView.rightLabel?.text = loan.productHash
            //认购金额
            scrollView.stackView.addArrangedSubview(mySubscribedAmountView, topInset: 20)
            mySubscribedAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.mySubscribedAmount, token: token)
//            //认购金额
//            scrollView.stackView.addArrangedSubview(loanAmountView, topInset: 20)
//            loanAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.loanAmount, token: token)
            //年化收益率
            scrollView.stackView.addArrangedSubview(yearRateView, topInset: 20)
            yearRateView.rightLabel?.text = loan.yearRateString
            //借币期限
            loanDurationView = SendStaticItemView(title: R.string.localizable.defiItemLoanDurationTitle(), rightViewStyle: .labels(topStyle: .attributed(string: DeFiFormater.loanDuration(text: "\(loan.loanDuration)")), bottomStyle: .text(string: R.string.localizable.defiSubscriptionPageDurationBlock("\(loan.loanDuration*24*60*60)"))))
            scrollView.stackView.addArrangedSubview(loanDurationView, topInset: 20)
            //预计收益
            scrollView.stackView.addArrangedSubview(earningsView, topInset: 20)
            earningsView.rightLabel?.attributedText = DeFiFormater.value(loan.totalProfits.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals) + "/" + loan.dayProfits.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals), unit: "VITE")
            //借币总金额”
            scrollView.stackView.addArrangedSubview(totalAmountView, topInset: 20)
            totalAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.loanAmount, token: token)
            //每份金额”
            scrollView.stackView.addArrangedSubview(eachAmountView, topInset: 20)
            eachAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.singleCopyAmount, token: token)
            //剩余份数
            scrollView.stackView.addArrangedSubview(leftCopiesView, topInset: 20)
            leftCopiesView.rightLabel?.attributedText = DeFiFormater.value(String(loan.leftCopies), unit: "VITE")

            scrollView.stackView.addArrangedSubview(buyButton, topInset: 26)

            scrollView.stackView.addArrangedSubview(onSaleTip1, topInset: 14)
            scrollView.stackView.addArrangedSubview(onSaleTip2, topInset: 4)
            scrollView.stackView.addArrangedSubview(onSaleTip3, topInset: 4)
            scrollView.stackView.addArrangedSubview(onSaleTip4, topInset: 4)
            scrollView.stackView.addPlaceholder(height: 26)
        case .failed, .cancel:
            header.snp.remakeConstraints { $0.height.equalTo(header.size.height) }
            scrollView.stackView.addArrangedSubview(titleView)
            scrollView.stackView.addArrangedSubview(header)

            //产品Hash
              scrollView.stackView.addArrangedSubview(idView, topInset: 20)
            idView.rightLabel?.text = loan.productHash
            //认购金额
            scrollView.stackView.addArrangedSubview(mySubscribedAmountView, topInset: 20)
            mySubscribedAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.mySubscribedAmount, token: token)
//              //认购金额
//              scrollView.stackView.addArrangedSubview(loanAmountView, topInset: 20)
//            loanAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.loanAmount, token: token)
              //年化收益率
              scrollView.stackView.addArrangedSubview(yearRateView, topInset: 20)
            yearRateView.rightLabel?.text = loan.yearRateString
              //借币期限
            loanDurationView = SendStaticItemView(title: R.string.localizable.defiItemLoanDurationTitle(), rightViewStyle: .labels(topStyle: .attributed(string: DeFiFormater.loanDuration(text: "\(loan.loanDuration)")), bottomStyle: .text(string: R.string.localizable.defiSubscriptionPageDurationBlock("\(loan.loanDuration*24*60*60)"))))
              scrollView.stackView.addArrangedSubview(loanDurationView, topInset: 20)
            //预计总收益/每日收益”
               scrollView.stackView.addArrangedSubview(earningsView, topInset: 20)
            earningsView.rightLabel?.attributedText = DeFiFormater.value(loan.totalProfits.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals) + "/" + loan.dayProfits.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals), unit: "VITE")

            //借币总金额”
            scrollView.stackView.addArrangedSubview(totalAmountView, topInset: 20)
            totalAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.loanAmount, token: token)
            //剩余未售出
            scrollView.stackView.addArrangedSubview(remainingUnsoldView, topInset: 20)
            remainingUnsoldView.rightLabel?.attributedText = DeFiFormater.value(String(loan.leftCopies), unit: "VITE")
            //应退认购金额
            scrollView.stackView.addArrangedSubview(refundPaidInterestView, topInset: 20)
            refundPaidInterestView.rightLabel?.attributedText = DeFiFormater.amount(loan.mySubscribedAmount, token: token)

            scrollView.stackView.addArrangedSubview(refundButton, topInset: 26)
            refundButton.isEnabled = loan.refundStatus == .refunded
            scrollView.stackView.addPlaceholder(height: 26)
        case .success:
            header.snp.remakeConstraints { $0.height.equalTo(header.size.height) }
            scrollView.stackView.addArrangedSubview(titleView)
            scrollView.stackView.addArrangedSubview(header)

            //产品Hash
           scrollView.stackView.addArrangedSubview(idView, topInset: 20)
            idView.rightLabel?.text = loan.productHash
            //认购金额
            scrollView.stackView.addArrangedSubview(mySubscribedAmountView, topInset: 20)
            mySubscribedAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.mySubscribedAmount, token: token)
//           //认购金额
//           scrollView.stackView.addArrangedSubview(loanAmountView, topInset: 20)
//            loanAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.loanAmount, token: token)
           //年化收益率
           scrollView.stackView.addArrangedSubview(yearRateView, topInset: 20)
            yearRateView.rightLabel?.text = loan.yearRateString
           //借币期限
            loanDurationView = SendStaticItemView(title: R.string.localizable.defiItemLoanDurationTitle(), rightViewStyle: .labels(topStyle: .attributed(string: DeFiFormater.loanDuration(text: "\(loan.loanDuration)")), bottomStyle: .text(string: R.string.localizable.defiSubscriptionPageDurationBlock("\(loan.loanDuration*24*60*60)"))))
           scrollView.stackView.addArrangedSubview(loanDurationView, topInset: 20)
            //“售罄快照块高度”
            scrollView.stackView.addArrangedSubview(successHeightView, topInset: 20)
            successHeightView.rightLabel?.text = String(loan.subscriptionFinishHeight)
            //售罄时间”
            scrollView.stackView.addArrangedSubview(successTimeView, topInset: 20)
            successTimeView.rightLabel?.text = loan.subscriptionFinishTimeString
            //到期快照块高度
            scrollView.stackView.addArrangedSubview(endHeightView, topInset: 20)
            endHeightView.rightLabel?.text = String(loan.loanEndSnapshotHeight)

            //预计到期时间
            scrollView.stackView.addArrangedSubview(estimatedEndTimeView, topInset: 20)
            estimatedEndTimeView.rightLabel?.text = loan.subscriptionFinishTimeString
            //预计总收益/每日收益”
            scrollView.stackView.addArrangedSubview(earningsView, topInset: 20)
            earningsView.rightLabel?.attributedText = DeFiFormater.value(loan.totalProfits.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals) + "/" + loan.dayProfits.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals), unit: "VITE")

            //已发放收益”
            scrollView.stackView.addArrangedSubview(paidInterestView, topInset: 20)
            paidInterestView.rightLabel?.attributedText = DeFiFormater.amount(loan.earnProfits, token: token)

            scrollView.stackView.addArrangedSubview(successButton, topInset: 26)
            scrollView.stackView.addArrangedSubview(successTip1, topInset: 14)
            scrollView.stackView.addArrangedSubview(successTip2, topInset: 14)

            scrollView.stackView.addPlaceholder(height: 26)
        }
    }

    func bind() {
        buyButton.rx.tap.bind {[weak self] (_)  in
            guard let hash = self?.loan?.productHash else { return }
            let vc = DeFiSubscriptionViewController.init(productHash: hash)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        refundButton.rx.tap.bind { (_)  in
            let vc = MyDeFiBillViewController.init()
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            vc.initStatus = .认购金额退款
        }.disposed(by: rx.disposeBag)

        successButton.rx.tap.bind { (_)  in
            let vc = MyDeFiBillViewController.init()
            vc.initStatus = .认购收益
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)
    }
}

extension DeFiSubscriptionDetailViewController: ViewControllerDataStatusable {
    public func networkErrorView(error: Error, retry: @escaping () -> Void) -> UIView {
        return UIView.defaultNetworkErrorView(error: error) {
            retry()
        }
    }
}
