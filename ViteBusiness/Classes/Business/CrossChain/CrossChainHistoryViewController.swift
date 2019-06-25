//
//  CrossChainHisttoryViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/6/17.
//

import Foundation

class CrossChainHistoryViewController: BaseViewController {

    enum Style {
        case desposit
        case withdraw
    }

    let tableView = UITableView.listView()

    var style: (CrossChainHistoryViewController.Style)!
    var gatewayInfoService: CrossChainGatewayInfoService!

    var currentpageNum = 1
    let pageSize = 20

    var depositRecords: [DepositRecord] = []
    var withdrawRecord: [WithdrawRecord] = []

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
            self.getRecords()
        })
        tableView.mj_footer = RefreshFooter.init(refreshingBlock: { [unowned self] in
            self.getMoreRecords()
        })

        tableView.mj_header.beginRefreshing()
    }

    func createNavigationTitleView() -> UIView {
        let view = UIView().then {
            $0.backgroundColor = UIColor.white
        }

        let title = style == .desposit ? R.string.localizable.crosschainDepositHistory() : R.string.localizable.crosschainWithdrawHistory()
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

    func getRecords()  {
        guard let address = HDWalletManager.instance.account?.address else {
            return
        }
        if self.style == .desposit {
            self.gatewayInfoService.depositRecords(viteAddress: address, pageNum: currentpageNum, pageSize: pageSize)
                .done { [weak self](info) in
                    self?.depositRecords.removeAll()
                    self?.depositRecords.append(contentsOf: info.depositRecords)
                    self?.currentpageNum = 1
                    self?.tableView.reloadData()
                }.catch { (error) in
                    Toast.show(error.localizedDescription)
                }.finally { [weak self] in
                    self?.tableView.mj_header.endRefreshing()
            }

        } else if self.style == .withdraw  {
            self.gatewayInfoService.withdrawRecords(viteAddress: address, pageNum: currentpageNum, pageSize: pageSize)
                .done { [weak self] (info) in
                    self?.withdrawRecord.removeAll()
                    self?.withdrawRecord.append(contentsOf: info.withdrawRecords)
                    self?.tableView.mj_header.endRefreshing()
                    self?.currentpageNum = 1
                    self?.tableView.reloadData()
                }.catch { (error) in
                    Toast.show(error.localizedDescription)
                }.finally { [weak self] in
                    self?.tableView.mj_header.endRefreshing()
            }
        }

    }


    func getMoreRecords() {
        guard let address = HDWalletManager.instance.account?.address else {
            return
        }
        if self.style == .desposit {
            self.gatewayInfoService.depositRecords(viteAddress: address, pageNum: currentpageNum + 1, pageSize: pageSize)
                .done { [weak self](info) in
                    self?.depositRecords.append(contentsOf: info.depositRecords)
                    self?.currentpageNum = self?.currentpageNum ?? 0 + 1
                    self?.tableView.reloadData()
                }.catch { (error) in
                    Toast.show(error.localizedDescription)
            }
                .finally { [weak self] in
                    self?.tableView.mj_footer.endRefreshing()
            }

        } else if self.style == .withdraw  {
            self.gatewayInfoService.withdrawRecords(viteAddress: address, pageNum: currentpageNum + 1, pageSize: pageSize)
                .done { [weak self] (info) in
                    self?.withdrawRecord.append(contentsOf: info.withdrawRecords)
                    self?.tableView.mj_footer.endRefreshing()
                    self?.currentpageNum = self?.currentpageNum ?? 0 + 1
                    self?.tableView.reloadData()
                }.catch { (error) in
                    Toast.show(error.localizedDescription)
                }
                .finally { [weak self] in
                    self?.tableView.mj_footer.endRefreshing()
            }
        }
    }

}

extension CrossChainHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.style == .desposit {
            return self.depositRecords.count
        } else if self.style == .withdraw  {
            return self.withdrawRecord.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CrossChainHistoryCell") as! CrossChainHistoryCell
        if self.style == .desposit {
            let desposit = self.depositRecords[indexPath.row]
            cell.bind(tokenInfo:gatewayInfoService.tokenInfo, depositRecord: desposit)
        } else if self.style == .withdraw  {
            let withdrawRecord = self.withdrawRecord[indexPath.row]
            cell.bind(tokenInfo:gatewayInfoService.tokenInfo, withdrawRecord: withdrawRecord)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }


}


