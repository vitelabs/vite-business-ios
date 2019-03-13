//
//  GrinInfoViewController.swift
//  Pods
//
//  Created by haoshenyang on 2019/3/5.
//

import Foundation
import ViteWallet
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Vite_GrinWallet
import RxDataSources
import BigInt

func businessBundle() -> Bundle {
    let podBundle = Bundle(for: GrinInfoViewController.self)
    let url = podBundle.url(forResource: "ViteBusiness", withExtension: "bundle")
    return Bundle.init(url: url!)!
}

class GrinInfoViewController: BaseViewController {

    @IBOutlet weak var titleView: BalanceInfoNavView!
    @IBOutlet weak var grinCardBgView: UIImageView!
    @IBOutlet weak var spendableTitleLabel: UILabel!
    @IBOutlet weak var waitingTitleLabel: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var lockedTitleLabel: UILabel!
    @IBOutlet weak var spendableAcountLabel: UILabel!
    @IBOutlet weak var spendableExchangeLalbe: UILabel!
    @IBOutlet weak var awaitingCountLable: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var lockedCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let walletInfoVM = GrinWalletInfoVM()
    
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    func bind() {
        walletInfoVM.balanceDriver
            .drive(onNext:{ info in
                self.spendableAcountLabel.text = info.amountCurrentlySpendable
                self.awaitingCountLable.text = info.amountAwaitingConfirmation
                self.lockedCountLabel.text = info.amountLocked
                self.totalCountLabel.text = info.total
            })
            .disposed(by: rx.disposeBag)

        walletInfoVM.txsDriver
            .drive(onNext:{ _ in
                self.tableView.mj_header.endRefreshing()
                self.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)

        walletInfoVM.errorMessageDriver
            .filterNil()
            .drive(onNext:{ Toast.show($0) })
            .disposed(by: rx.disposeBag)

        navigationItem.rightBarButtonItem?.rx.tap.asObservable()
            .bind {
                Alert.show(title: "Check",
                           message: "Wallet check will scan the chain and cancel all pending transactions, unlock any locked outputs, restore any missing outputs, and ensure your wallet's content is consistent with the chain's version",
                           actions: [
                            (.cancel, nil),
                            (.default(title: R.string.localizable.confirm()), { [weak self] _ in
                                self?.walletInfoVM.action.onNext(.checkWallet)
                            }),
                    ])
                }
    }


    func setupView() {
        navigationBarStyle = .default

        navigationItem.rightBarButtonItem =
            UIBarButtonItem.init(image: R.image.icon_nav_more(), style: .plain, target: nil, action: nil)

        MyTokenInfosService.instance.tokenInfo(for: "Grin") { [weak self] (reslut) in
            if case .success (let info) = reslut {
                self?.titleView.bind(tokenInfo: info)
            }
            let tokenInfo: TokenInfo = TokenInfo(tokenCode: "Grin", coinType: .grin, name: "Grin", symbol: "Grin", decimals: 9, icon: "https://s2.coinmarketcap.com/static/img/coins/64x64/2937.png", id: "")
            self?.titleView.bind(tokenInfo: tokenInfo)
        }

        grinCardBgView.backgroundColor =
            UIColor.gradientColor(style: .leftTop2rightBottom,
                                  frame: CGRect.init(x: 0, y: 0, width: kScreenW - 48, height: 201),
                                  colors: [UIColor(netHex: 0xFF5C00),UIColor(netHex: 0xFFC800)])

        let nib = UINib.init(nibName: "GrinTransactionCell", bundle: businessBundle())
        tableView.register(nib, forCellReuseIdentifier: "GrinTransactionCell")
        tableView.mj_header = RefreshHeader(refreshingBlock: { [unowned self] in
            self.walletInfoVM.action.onNext(.getBalance(manually: true))
            self.walletInfoVM.action.onNext(.getTxs(manually: true))
        })
    }

    @IBAction func sendAciton(_ sender: Any) {
        let a0 = UIAlertAction.init(title: "通过Vite地址", style: .default) { (_) in

        }
        let a1 = UIAlertAction.init(title: "通过Http地址", style: .default) { (_) in

        }
        let a2 = UIAlertAction.init(title: "通过交易文件", style: .default) { (_) in
            let podBundle = Bundle(for: GrinInfoViewController.self)
            let url = podBundle.url(forResource: "ViteBusiness", withExtension: "bundle")
            let resourceBundle = Bundle.init(url: url!)
            let storyboard = UIStoryboard.init(name: "GrinInfo", bundle: resourceBundle)
            let sendGrinViewController = storyboard
                .instantiateViewController(withIdentifier: "SendGrinViewController") as! SendGrinViewController
            self.navigationController?.pushViewController(sendGrinViewController, animated: true)

        }
        let a3 = UIAlertAction.init(title: "取消", style: .cancel) { _ in }

        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(a0)
        alert.addAction(a1)
        alert.addAction(a2)
        alert.addAction(a3)
        self.present(alert, animated: true, completion: nil)

    }

    @IBAction func receiveAction(_ sender: Any) {

    }
}

extension GrinInfoViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.walletInfoVM.txs.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GrinTransactionCell", for: indexPath) as! GrinTransactionCell
        let tx = self.walletInfoVM.txs.value[indexPath.row]
        cell.bind(tx)
        return cell
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        let tx = self.walletInfoVM.txs.value[indexPath.row]
        if tx.txSlateId == nil {

        }
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let tx = self.walletInfoVM.txs.value[indexPath.row]
        var action = [UITableViewRowAction]()
        if tx.txSlateId != nil {
            let copyAction = UITableViewRowAction.init(style: .default, title: "复制ID") { (_, _) in
                    Toast.show(tx.txSlateId ?? "复制ID")
                }
                .then { $0.backgroundColor = UIColor(netHex: 0x479FFF)}
            action.append(copyAction)
        }

        let canRespost = tx.txType == .txSent && !tx.confirmed
        if  canRespost {
            let reSendAction = UITableViewRowAction.init(style: .default, title: "重发") { (_, _) in
                    self.walletInfoVM.action.onNext(.repost(tx))
                }
                .then { $0.backgroundColor = UIColor(netHex: 0xFFC900)}
            action.append(reSendAction)
        }

        let canCancle = (tx.txType == .txSent || tx.txType == .txReceived) && !tx.confirmed
        if  canCancle {
            let cancleAction = UITableViewRowAction(style: .default, title: "取消") { (_, _) in
                    self.walletInfoVM.action.onNext(.cancel(tx))
                }
                .then { $0.backgroundColor = UIColor(netHex: 0xDEDFE0)}
            action.append(cancleAction)
        }
        return action
    }


}
