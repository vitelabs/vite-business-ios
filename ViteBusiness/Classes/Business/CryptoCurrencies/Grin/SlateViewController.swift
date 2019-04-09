//
//  ShareSlateViewController.swift
//  Pods
//
//  Created by haoshenyang on 2019/3/12.
//

import UIKit
import Vite_GrinWallet
import ViteWallet
import BigInt
import RxSwift
import RxCocoa

class SlateViewController: UIViewController {

    enum OperateType: Int {
        case sent
        case receive
        case finalize
    }

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleView: GrinTransactionTitleView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var slateIdLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var operateButton: UIButton!
    @IBOutlet weak var slateIDLabel: UILabel!

    var opendSlate: Slate?
    var opendSlateUrl: URL?

    var type = OperateType.sent
    var document: UIDocumentInteractionController!

    let transferVM = GrinTransactVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var navigationBarStyle = NavigationBarStyle.custom(tintColor: UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45), backgroundColor: UIColor.init(netHex: 0xF9FCFF))
        NavigationBarStyle.configStyle(navigationBarStyle, viewController: self)
    }

    func setUpView() {

        titleView.tokenIconView.tokenInfo = GrinManager.tokenInfo
        titleView.symbolLabel.text = [
            R.string.localizable.grinSentTitle(),
            R.string.localizable.grinReceiveTitle(),
            R.string.localizable.grinFinalizeTitle()
            ][type.rawValue]

        descriptionLabel.text = [
            R.string.localizable.grinShareFileDesc(),
            R.string.localizable.grinShareFileDesc(),
            R.string.localizable.grinFinalizeDesc(),
        ][type.rawValue]

        slateIdLabel.text = opendSlate?.id
        tableView.reloadData()

        let title =  [R.string.localizable.grinShareFile(),
                      R.string.localizable.grinSignAndShare(),
                      R.string.localizable.grinFinalize()][type.rawValue]
        operateButton.setTitle(title, for: .normal)

        statusImageView.image = [
            R.image.grin_tx_file_init(),
            R.image.grin_tx_file_receive(),
            R.image.grin_tx_file_finalize()
            ][type.rawValue]

        statusLabel.text = [
            R.string.localizable.grinTxFileInitStatus(),
            R.string.localizable.grinTxTypeWaitToSign(),
            R.string.localizable.grinTxTypeReceived(),
        ][type.rawValue]

        slateIDLabel.text = R.string.localizable.grinTxidTitle()

        view.backgroundColor = UIColor.init(netHex: 0xF9FCFF)
        backgroundView.backgroundColor = UIColor.init(netHex: 0xffffff)
        backgroundView.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
        backgroundView.layer.shadowOpacity = 0.1
        backgroundView.layer.shadowOffset = CGSize(width: 5, height: 5)
        backgroundView.layer.shadowRadius = 5
    }

    func bind() {
        transferVM.receiveSlateCreated.asObserver()
            .bind { [weak self] (slate,url) in
                self?.operateButton.setTitle(R.string.localizable.grinShareFile(), for: .normal)
                self?.statusLabel.text = R.string.localizable.grinTxTypeReceived()
                self?.descriptionLabel.text = R.string.localizable.grinMakeSureToShare()
                self?.shareSlate(url: url)
        }
        .disposed(by: rx.disposeBag)

        transferVM.message.asObservable()
            .bind { message in
                Toast.show(message)
        }
        .disposed(by: rx.disposeBag)

        transferVM.finalizeTxSuccess.asObserver()
            .delay(1.5, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: rx.disposeBag)
    }

    @IBAction func handleSlate(_ sender: Any) {
        guard let slate = opendSlate ,let url = opendSlateUrl else { return }
        if type == .sent {
            shareSlate(url: url)
        } else if type == .receive {
            var slateId = url.lastPathComponent.components(separatedBy: ".").first ?? ""
            let receivedUrl = GrinManager.default.getSlateUrl(slateId: slateId, isResponse: true)
            if FileManager.default.fileExists(atPath: receivedUrl.path) {
                self.shareSlate(url: receivedUrl)
            } else {
                transferVM.action.onNext(.receiveTx(slateUrl: url))
            }
        } else if type == .finalize {
            let fee = Balance(value: BigInt(slate.fee)).amountFull(decimals: 9)
            let amount = Balance(value: BigInt(slate.amount)).amountFull(decimals: 9)
            let confirmType = ConfirmGrinTransactionViewModel(amountString: amount, feeString: fee)
            Workflow.confirmWorkflow(viewModel: confirmType, completion: { (result) in
            }) {
                self.transferVM.action.onNext(.finalizeTx(slateUrl: url))
            }
        }
    }

    func shareSlate(url: URL) {
        document = UIDocumentInteractionController(url: url)
        document.presentOpenInMenu(from: self.view.bounds, in: self.view, animated: true)
    }

}

extension SlateViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.textLabel?.textColor = UIColor(netHex: 0x3e4159, alpha:0.7)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.detailTextLabel?.textColor = UIColor(netHex: 0x3e4159)
        guard let slate = opendSlate else { fatalError() }
        var arr = [
            (R.string.localizable.grinSentAmount(), Balance(value: BigInt(slate.amount)).amount(decimals: 9, count: 9)),
            (R.string.localizable.grinSentFee(), Balance(value: BigInt(slate.fee)).amount(decimals: 9, count: 9))
        ]
        let attributeStr =
            NSMutableAttributedString(string: arr[indexPath.row].1,
                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3e4159, alpha:0.7),
                                                NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 13)
                ])
        attributeStr.append(NSAttributedString(string: " GRIN",
                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3e4159, alpha:0.6)
            ]))
        cell.detailTextLabel?.attributedText = attributeStr
        cell.textLabel?.text = arr[indexPath.row].0
        return cell
    }
}
