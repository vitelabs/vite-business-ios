//
//  DeFiProductDetailViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/12/3.
//

import UIKit
import PromiseKit

class DeFiProductDetailViewController: BaseViewController {

    var productHash: String!
    var detail: DeFiLoan?
    var timer: Timer?
    lazy var tableView = UITableView.listView()

    let bigNavTitleView = PageTitleView.onlyTitle(title: "产品详情")

    let cardView = DeFiProductInfoCard.init(title: "去中心化智能合约安全保障", status: .无, porgressDesc: "认购进度：--%", progress: 0, deadLineDesc: NSAttributedString.init(string: "--后结束认购"))

    let buyButton = UIButton.init(style: .blue).then {
        $0.setTitle("立即抢购", for: .normal)
    }

    lazy var tableHeaderView: UIView = {
        let view = UIView()
        view.addSubview(self.bigNavTitleView)
        view.addSubview(self.cardView)

        self.bigNavTitleView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.height.equalTo(64)
        }
        self.cardView.snp.makeConstraints { (m) in
            m.top.equalTo(self.bigNavTitleView.snp.bottom)
            m.left.right.equalToSuperview().inset(24)
            m.height.equalTo(132)
        }
        view.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: 200)
        return view
    }()

    let tableFooterView: UIView = {
        let view = UIView()
        view.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: 76)

        let label0 = PointLabel()
        label0.font = UIFont.systemFont(ofSize: 12)
        label0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        label0.text = "准确的借币期限以快照块为准。"

        let label1 = PointLabel()
        label1.font = UIFont.systemFont(ofSize: 12)
        label1.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        label1.text = "认购期内，若成功售罄，自动结束认购，开始计息。"

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
        self.setNavTitle(title: "产品详情", bindTo: tableView)

        self.refresh()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            guard let detail = self?.detail else { return }
            self?.cardView.deadLineDescLabel.text = detail.countDownString
        }
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
         content = [
            ("产品Hash",detail.productHash,nil),
            ("借币金额",detail.loanAmount.amountFull(decimals: 13),"VITE"),
            ("每份金额",detail.singleCopyAmount.amountFull(decimals: 13),"VITE"),
            ("总份数",String(detail.subscriptionCopies),"份"),
            ("年化收益率",detail.yearRateString,nil),
            ("借币期限",String(detail.loanDuration),"天"),
            ("认购开始时间",detail.subscriptionBeginTimeString,nil),
            ("认购期限",String(detail.subscriptionDuration),"天"),
        ]
        tableView.reloadData()

        self.cardView.progressLabel.text = "认购进度：\(detail.loanCompletenessString)"
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

}

extension DeFiProductDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        return 60
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

