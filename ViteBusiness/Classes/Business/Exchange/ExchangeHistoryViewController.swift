//
//  ExchangeHistoryViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/7/30.
//

import UIKit

class ExchangeHistoryViewController: BaseViewController {

    let tableView = UITableView.listView()

    let vm = ExchangeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleView = createNavigationTitleView()

        view.addSubview(tableView)

        tableView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.top.equalTo(navigationTitleView!.snp.bottom)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CrossChainHistoryCell.self, forCellReuseIdentifier: "CrossChainHistoryCell")
        tableView.separatorColor = UIColor.init(netHex: 0xD3DFEF)

        tableView.mj_header = RefreshHeader(refreshingBlock: { [unowned self] in
            self.vm.action.onNext(.refreshHistory)
        })
        tableView.mj_footer = RefreshFooter.init(refreshingBlock: { [unowned self] in
            self.vm.action.onNext(.getMoreHistory)
        })

        vm.txs.skip(1)
            .bind { [weak self] tx in
            guard let `self` = self else { return }
            self.tableView.set(empty: tx.isEmpty)
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
        }
        self.tableView.mj_header.beginRefreshing()

    }

    func createNavigationTitleView() -> UIView {
        let view = UIView().then {
            $0.backgroundColor = UIColor.white
        }

        let title = "lishi"
        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 24)
            $0.numberOfLines = 1
            $0.adjustsFontSizeToFitWidth = true
            $0.textColor = UIColor(netHex: 0x24272B)
            $0.text = title
        }

        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(view).offset(6)
            m.left.equalTo(view).offset(24)
            m.bottom.equalTo(view).offset(-20)
            m.height.equalTo(29)
        }
        return view
    }

}

extension ExchangeHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.txs.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let tx = self.vm.txs.value[indexPath.row]
        cell.textLabel?.text = tx.address
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }

}
