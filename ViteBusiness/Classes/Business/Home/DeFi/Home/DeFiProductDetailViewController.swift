//
//  DeFiProductDetailViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/12/3.
//

import UIKit
import PromiseKit
import RxSwift
import RxCocoa

class DeFiProductDetailViewController: BaseViewController {

    var productHash: String!
    var detail: DeFiLoan?
    lazy var tableView = UITableView.listView()

    let bigNavTitleView = PageTitleView.onlyTitle(title: R.string.localizable.defiProductDetailTitle())

    let cardView = DeFiProductInfoCard.init(title: R.string.localizable.defiCardSlogan(), status: .none, porgressDesc:  R.string.localizable.defiCardProgress() + "--", progress: 0, deadLineDesc: NSAttributedString.init(string: R.string.localizable.defiCardEndTime("-", "-")))

    let buyButton = UIButton.init(style: .blue).then {
        $0.setTitle(R.string.localizable.defiProductDetailBuy(), for: .normal)
    }

    lazy var tableHeaderView: UIView = {
        let view = UIView()
        view.addSubview(self.bigNavTitleView)

        self.bigNavTitleView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.height.equalTo(64)
        }
        view.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: 60)
        return view
    }()

    let tableFooterView: UIView = {
        let view = UIView()
        view.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: 110)

        let label0 = PointLabel()
        label0.font = UIFont.systemFont(ofSize: 12)
        label0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        label0.text = R.string.localizable.defiProductDetailDesc0()

        let label1 = PointLabel()
        label1.font = UIFont.systemFont(ofSize: 12)
        label1.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        label1.text = R.string.localizable.defiProductDetailDesc1()

        view.addSubview(label0)
        view.addSubview(label1)

        label0.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalToSuperview()
        }

        label1.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(label0.snp.bottom).offset(3)
        }

        return view
    }()

    var content: [(String,String,String?)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview()
            m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
            m.bottom.equalTo(view.snp.bottom)
        }
        tableView.tableHeaderView = self.tableHeaderView
        tableView.tableFooterView = self.tableFooterView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DefiProductItemCell.self, forCellReuseIdentifier: "DefiProductItemCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cardCell")
        tableView.register(DefiProductItemWithUnitCell.self, forCellReuseIdentifier: "DefiProductItemWithUnitCell")
        tableView.mj_header = RefreshHeader.init(refreshingBlock: { [unowned self] in
            self.refresh()
        })

        view.addSubview(buyButton)
        buyButton.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.height.equalTo(50)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }

        buyButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let vc = DeFiSubscriptionViewController(productHash: self.productHash)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)
        self.setNavTitle(title: R.string.localizable.defiProductDetailTitle(), bindTo: tableView)

        self.refresh()

        Observable<Int>.interval(1, scheduler: MainScheduler.instance).bind { [weak self] (_) in
            self?.updateHeader()
        }.disposed(by: rx.disposeBag)
    }

    func refresh() {
        UnifyProvider.defi.getProductDetail(hash: self.productHash)
            .done { [weak self] (detail) in
                self?.updateInfo(detail: detail)
        }
        .catch { (e) in
            Toast.show(e.localizedDescription)
        }
        .finally {
            self.tableView.mj_header.endRefreshing()
        }
    }

    func updateInfo(detail: DeFiLoan) {
        self.detail = detail
        self.updateHeader()

         content = [
            (R.string.localizable.defiProductDetailTitleHash(),detail.productHash,nil),
            (R.string.localizable.defiProductDetailTitleAmount(),detail.loanAmount.amountFull(decimals: 13),"VITE"),
            (R.string.localizable.defiProductDetailTitlePearamount(),detail.singleCopyAmount.amountFull(decimals: 13),"VITE"),
            (R.string.localizable.defiProductDetailTitleCount(),String(detail.subscriptionCopies),R.string.localizable.defiProductDetailUntilPear()),
            (R.string.localizable.defiProductDetailTitleRate(),detail.yearRateString,nil),
            (R.string.localizable.defiProductDetailTitleBorrowdeadline(),String(detail.loanDuration),R.string.localizable.defiProductDetailUntilPear()),
            (R.string.localizable.defiProductDetailTitleBeginTime(),detail.subscriptionBeginTimeString,nil),
            (R.string.localizable.defiProductDetailTitleBuydeadline(),String(detail.subscriptionDuration),R.string.localizable.defiProductDetailUntilPear()),
        ]
        tableView.reloadData()
        self.buyButton.isEnabled = detail.productStatus == .onSale
    }

    func updateHeader() {
        guard let loan = self.detail else { return }
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
        cardView.config(
            title: R.string.localizable.defiCardSlogan(),
            status: status,
            progressDesc: "\(R.string.localizable.defiCardProgress())\(loan.loanCompletenessString)",
            progress: CGFloat(loan.loanCompleteness),
            deadLineDesc: loan.productStatus == .onSale ? attributedString : nil)
    }

}

extension DeFiProductDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell") as! UITableViewCell
            if self.cardView.superview == nil {
                cell.contentView.addSubview(self.cardView)
                cardView.snp.makeConstraints { (m) in
                    m.left.right.equalToSuperview().inset(24)
                    m.top.bottom.equalToSuperview().inset(5)
                }
            }
            return cell
        }
        let info = self.content[indexPath.row]
        if info.2 != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefiProductItemWithUnitCell") as! DefiProductItemWithUnitCell
            cell.titleLabel.text = info.0
            cell.contentLabel.text = info.1
            cell.unitLabel.text = info.2
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefiProductItemCell") as! DefiProductItemCell
            cell.titleLabel.text = info.0
            cell.contentLabel.text = info.1
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.cardView.size.height + 10
        }
        return 60
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}


extension UIViewController {

    func setNavTitle(title: String, bindTo scrollView: UIScrollView) {

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.textColor = UIColor(netHex: 0x24272B)
            $0.alpha = 0
            $0.textAlignment = .center
            $0.frame = CGRect.init(x: 0, y: 0, width: kScreenW/2.5, height: 44)
            $0.text = " "
        }
        self.navigationItem.titleView = titleLabel

        scrollView.rx.contentOffset
            .map { max(min($0.y, 64.0), 0.001) / 64.0 }
            .skip(1)
            .bind { [weak titleLabel] alpha in
                titleLabel?.text = title
                titleLabel?.alpha = alpha
            }
            .disposed(by: rx.disposeBag)
    }
}

