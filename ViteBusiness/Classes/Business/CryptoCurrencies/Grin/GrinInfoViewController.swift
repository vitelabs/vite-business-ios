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
import Moya
import SwiftyJSON
import ObjectMapper

func businessBundle() -> Bundle {
    let podBundle = Bundle(for: GrinInfoViewController.self)
    let url = podBundle.url(forResource: "ViteBusiness", withExtension: "bundle")
    return Bundle.init(url: url!)!
}

class GrinInfoViewController: BaseViewController {

    @IBOutlet weak var transcationTiTleLabel: UILabel!
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
    @IBOutlet weak var lineImageVIew: UIImageView!
    @IBOutlet weak var receiveBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var finalizationTitleLabel: UILabel!
    @IBOutlet weak var finalizationCountLabel: UILabel!
    let rightBatItemCustombutton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))

    let helpButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.grin_help(), for: .normal)
        return button
    }()

    lazy var emptyView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 130, height: 170))
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 130, height: 130))
        imageView.image = R.image.empty()
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        label.text = R.string.localizable.transactionListPageEmpty()
        view.addSubview(imageView)
        view.addSubview(label)
        imageView.snp.makeConstraints({ (m) in
            m.top.equalToSuperview()
            m.centerX.equalToSuperview()
            m.width.height.equalTo(130)
        })
        label.snp.makeConstraints({ (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(imageView.snp.bottom).offset(20)
        })
        return view
    }()

    let walletInfoVM = GrinWalletInfoVM()

    fileprivate let transactionProvider = MoyaProvider<GrinTransaction>(stubClosure: MoyaProvider.neverStub)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        walletInfoVM.action.onNext(.getBalance(manually: true))
        walletInfoVM.action.onNext(.getTxs(manually: true))
        GrinManager.default.handleSavedTx()
        GrinTxByViteService().reportViteAddress().done {_ in}
    }

    override func viewDidAppear(_ animated: Bool) {
        walletInfoVM.action.onNext(.getBalance(manually: true))
        walletInfoVM.action.onNext(.getTxs(manually: true))
    }

    func bind() {
        walletInfoVM.balanceDriver
            .drive(onNext:{ [weak self] info in
                self?.spendableAcountLabel.text = info.amountCurrentlySpendable
                self?.awaitingCountLable.text = info.amountAwaitingConfirmation
                self?.lockedCountLabel.text = info.amountLocked
                self?.totalCountLabel.text = info.total
                self?.spendableExchangeLalbe.text = info.legalTenderWorthed
                self?.finalizationCountLabel.text = info.amountAwaitingFinalization
            })
            .disposed(by: rx.disposeBag)

        walletInfoVM.txsDriver
            .drive(onNext:{  [weak self] txs in
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.reloadData()
                if txs.isEmpty {
                    self?.emptyView.isHidden = false
                } else  {
                    self?.emptyView.isHidden = true
                }
            })
            .disposed(by: rx.disposeBag)

        walletInfoVM.messageDriver
            .filterNil()
            .drive(onNext:{ Toast.show($0) })
            .disposed(by: rx.disposeBag)

        walletInfoVM.showLoadingDriver
            .drive(onNext:{ [weak self] showLoading in
                if showLoading {
                    self?.view.displayLoading()
                } else {
                    self?.view.hideLoading()
                }
            })
            .disposed(by: rx.disposeBag)

        walletInfoVM.fullInfoDetail
            .bind { [weak self] fullInfo in
                let detail = GrinTxDetailViewController()
                detail.fullInfo = fullInfo
                self?.navigationController?.pushViewController(detail, animated: true)
            }
            .disposed(by: rx.disposeBag)


        rightBatItemCustombutton.rx.tap.asObservable()
            .bind { [weak self] in
                guard let `self` = self,
                    let customView = self.navigationItem.rightBarButtonItem?.customView,
                    let spendableAcountLabel = self.spendableAcountLabel else {
                    return
                }
                FloatButtonsView(targetView: spendableAcountLabel, delegate: self, titles:
                    [R.string.localizable.grinNodeConfigNode(),
                     R.string.localizable.grinWalletCheck()]).show()
            }
            .disposed(by: rx.disposeBag)

        helpButton.rx.tap.bind { _ in
            var url: URL!
            if LocalizationService.sharedInstance.currentLanguage == .chinese {
                url = URL(string: "https://forum.vite.net/topic/1335/grin%E7%94%A8%E6%88%B7%E4%BD%BF%E7%94%A8vite%E9%92%B1%E5%8C%85%E6%94%B6%E8%BD%AC%E8%B4%A6%E6%95%99%E7%A8%8B")
            } else {
                url = URL(string: "https://forum.vite.net/topic/1334/a-tutorial-about-how-to-send-receive-a-grin-on-vite-mobile-wallet")
            }
            let webvc = WKWebViewController(url: url)
            UIViewController.current?.navigationController?.pushViewController(webvc, animated: true)
            }
            .disposed(by: rx.disposeBag)

        let tapGestureRecognizer = UITapGestureRecognizer()
        titleView.tokenIconView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] (r) in
            let vc =  GatewayTokenDetailViewController.init(tokenInfo: GrinManager.tokenInfo)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)

    }


    func setupView() {
        navigationBarStyle = .default

        rightBatItemCustombutton.setImage(R.image.icon_nav_more(), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBatItemCustombutton)

        self.titleView.bind(tokenInfo: GrinManager.tokenInfo)

        self.titleView.addSubview(helpButton)
        helpButton.snp.makeConstraints { (m) in
            m.width.height.equalTo(16)
            m.centerY.equalTo(self.titleView.symbolLabel)
            m.left.equalToSuperview().offset(86)
        }

        grinCardBgView.backgroundColor =
            UIColor.gradientColor(style: .leftTop2rightBottom,
                                  frame: CGRect.init(x: 0, y: 0, width: kScreenW - 48, height: 225),
                                  colors: [UIColor(netHex: 0xFF5C00),UIColor(netHex: 0xFFC800)])
        lineImageVIew.image =
            R.image.dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile)

        let nib = UINib.init(nibName: "GrinTransactionCell", bundle: businessBundle())
        tableView.register(nib, forCellReuseIdentifier: "GrinTransactionCell")
        tableView.mj_header = RefreshHeader(refreshingBlock: { [unowned self] in
            self.walletInfoVM.action.onNext(.getBalance(manually: true))
            self.walletInfoVM.action.onNext(.getTxs(manually: true))
        })

        spendableTitleLabel.text = " " + R.string.localizable.grinBalanceSpendable() + " "
        lockedTitleLabel.text = R.string.localizable.grinBalanceLocked()
        totalTitleLabel.text = R.string.localizable.grinBalanceTotal()
        waitingTitleLabel.text = R.string.localizable.grinBalanceAwaiting()
        sendBtn.setTitle(R.string.localizable.grinSentBtnTitle(), for: .normal)
        receiveBtn.setTitle(R.string.localizable.grinReceiveBtnTitle(), for: .normal)
        transcationTiTleLabel.text = R.string.localizable.transactionListPageTitle()
        finalizationTitleLabel.text = R.string.localizable.grinTxbyfileReceivedStatusSender() 
        tableView.tableFooterView = UIView()

        tableView.addSubview(emptyView)
        emptyView.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.width.equalTo(130)
            m.height.equalTo(170)
            m.centerY.equalToSuperview().offset(-5)
        }
    }

    @IBAction func sendAciton(_ sender: Any) {
        Statistics.log(eventId: String(format: Statistics.Page.WalletHome.tokenDetailsSendClicked.rawValue, "grin_grin"))
        let a0 = UIAlertAction.init(title: R.string.localizable.grinTxUseVite(), style: .default) { (_) in
          self.send(use: .vite)
        }
        let a1 = UIAlertAction.init(title: R.string.localizable.grinSentUseHttp(), style: .default) { (_) in
          self.send(use: .http)
        }
        let a2 = UIAlertAction.init(title:  R.string.localizable.grinSentUseFile(), style: .default) { (_) in
            self.send(use: .file)
        }
        let a3 = UIAlertAction.init(title: R.string.localizable.cancel(), style: .cancel) { _ in }
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(a0)
        alert.addAction(a1)
        alert.addAction(a2)
        alert.addAction(a3)
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.sendBtn;
            popover.sourceRect = self.sendBtn.bounds;
            popover.permittedArrowDirections = .any;
        }
        self.present(alert, animated: true, completion: nil)
    }

    func send(use method: TransferMethod) {
        let notTeach = UserDefaults.standard.bool(forKey: "grin_don't_show_\(method.rawValue)_teach")
        if notTeach {
            let resourceBundle = businessBundle()
            let storyboard = UIStoryboard.init(name: "GrinInfo", bundle: resourceBundle)
            let sendGrinViewController = storyboard
                .instantiateViewController(withIdentifier: "SendGrinViewController") as! SendGrinViewController
            sendGrinViewController.transferMethod = method
            self.navigationController?.pushViewController(sendGrinViewController, animated: true)
        } else {
            let vc = GrinTeachViewController.init(txType: .sent, channelType: method)
            self.navigationController?.pushViewController(vc, animated: true)
        }

        if method == .http {
            Statistics.log(eventId: "grin_tx_gotoSendPage_Http", attributes: ["uuid": UUID.stored])
        } else if method == .vite {
            Statistics.log(eventId: "grin_tx_gotoSendPage_Vite", attributes: ["uuid": UUID.stored])

        } else if method == .file {
            Statistics.log(eventId: "grin_tx_gotoSendPage_File", attributes: ["uuid": UUID.stored])
        }
    }

    @IBAction func receiveAction(_ sender: Any) {
        Statistics.log(eventId: String(format: Statistics.Page.WalletHome.tokenDetailsReceiveClicked.rawValue, "grin_grin"))
        let a0 = UIAlertAction(title: R.string.localizable.grinTxUseVite(), style: .default) { (_) in
            let notTeach = UserDefaults.standard.bool(forKey: "grin_don't_show_vite_teach")
            if notTeach {
                UIPasteboard.general.string = HDWalletManager.instance.accounts.first?.address
                Toast.show(R.string.localizable.grinReceiveByViteAddressCopyed())
            } else {
                let vc = GrinTeachViewController.init(txType: .receive, channelType: .vite)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

        let a1 = UIAlertAction(title: R.string.localizable.grinSentUseHttp(), style: .default) { (_) in
            let notTeach = UserDefaults.standard.bool(forKey: "grin_don't_show_http_teach")
            if notTeach {
                GrinTxByViteService().getGateWay()
                    .done({ (string)  in
                        UIPasteboard.general.string = string
                        Toast.show(R.string.localizable.grinReceiveByHttpAddressCopyed())
                    })
                    .catch({ (error) in
                        Toast.show(error.localizedDescription)
                    })
            } else {
                let vc = GrinTeachViewController.init(txType: .receive, channelType: .http)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

        let a2 = UIAlertAction.init(title:  R.string.localizable.grinSentUseFile(), style: .default) { (_) in
            let vc = GrinTeachViewController.init(txType: .receive, channelType: .file)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let a3 = UIAlertAction.init(title:  R.string.localizable.cancel(), style: .cancel) { _ in }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(a0)
        alert.addAction(a1)
        alert.addAction(a2)
        alert.addAction(a3)
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.receiveBtn;
            popover.sourceRect = self.receiveBtn.bounds;
            popover.permittedArrowDirections = .any;
        }
        self.present(alert, animated: true, completion: nil)
    }

    private var tapCount = 0
    @IBAction func uploadLog(_ sender: Any) {
        if tapCount <= 2 {
            tapCount += 1
            return
        }
        tapCount = 0
        let cachePath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let logURL = cachePath.appendingPathComponent("logger.log")
        let activityViewController = UIActivityViewController(activityItems: [logURL], applicationActivities: nil)
        UIViewController.current?.present(activityViewController, animated: true)
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
        return false
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let tx = self.walletInfoVM.txs.value[indexPath.row]
        var action = [UITableViewRowAction]()
        if let slateId = tx.txLogEntry?.txSlateId {
            let copyAction = UITableViewRowAction.init(style: .default, title:  R.string.localizable.grinTxCopyId()) { (_, _) in
                    UIPasteboard.general.string = slateId
                }
                .then { $0.backgroundColor = UIColor(netHex: 0x479FFF)}
            action.append(copyAction)
        }

        if tx.txLogEntry?.canRepost == true {
            let repostAction = UITableViewRowAction.init(style: .default, title: R.string.localizable.grinTxRepost()) { (_, _) in
                self.walletInfoVM.action.onNext(.repost(tx.txLogEntry!))
                }
                .then { $0.backgroundColor = UIColor(netHex: 0xFFC900)}
            action.append(repostAction)
        }

        if tx.txLogEntry?.canCancel == true {
            let cancleAction = UITableViewRowAction(style: .default, title:  R.string.localizable.cancel()) { (_, _) in
                self.walletInfoVM.action.onNext(.cancel(tx.txLogEntry!))
                }
                .then { $0.backgroundColor = UIColor(netHex: 0xDEDFE0)}
            action.append(cancleAction)
        }
        return action
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fullInfo = self.walletInfoVM.txs.value[indexPath.row]
        self.walletInfoVM.action.onNext(.getFullInfoDetail(fullInfo))
    }
}

extension GrinInfoViewController: FloatButtonsViewDelegate {

    func didClick(at index: Int) {
        if index == 0 {
            let selectVC = SelectGrinNodeViewController()
            self.navigationController?.pushViewController(selectVC, animated: true)
        } else if index == 1 {
            Alert.show(title: R.string.localizable.grinWalletCheck(),
                       message: R.string.localizable.grinWalletCheckDesc(),
                       actions: [
                        (.cancel, nil),
                        (.default(title: R.string.localizable.confirm()), {[weak self] _ in
                            self?.walletInfoVM.action.onNext(.checkWallet)
                        }),
                ])
        }
    }
}

