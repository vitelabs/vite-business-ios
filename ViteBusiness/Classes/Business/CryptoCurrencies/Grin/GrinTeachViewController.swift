//
//  GrinTeachViewController.swift
//  Pods
//
//  Created by haoshenyang on 2019/3/25.
//

import UIKit

class GrinTeachViewController: UIViewController {

    init(txType: TxType, channelType: TransferMethod) {
        self.txType = txType
        self.channelType = channelType
        let bundle = businessBundle()
        super.init(nibName: "GrinTeachViewController", bundle: businessBundle())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    enum TxType {
        case sent
        case receive
    }

    var setting: [String: Bool] = [:]

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noiceDetailLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var notSeeLabel: UILabel!
    
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var noiceTitleLabel: UILabel!

    @IBOutlet weak var copyBtn: UIButton!
    var txType: TxType = .sent
    var channelType: TransferMethod = .vite


    override func viewDidLoad() {
        super.viewDidLoad()

        var desc = ""

        if channelType == .vite {
            titleLabel.text = R.string.localizable.grinTeachViteTitle()
            imageView.image = R.image.grin_tx_vite()
            if self.txType == .sent {
                desc =  R.string.localizable.grinSentUseViteDesc()
            } else if txType == .receive {
                desc = R.string.localizable.grinReceiveByViteDesc()
                addressLabel.text = "  \(HDWalletManager.instance.accounts.first?.address.description ?? "")  "
                addressTitleLabel.text = R.string.localizable.grinViteAddress()
            }
        } else if channelType == .http {
            titleLabel.text =  R.string.localizable.grinTeachHttpTitle()
            imageView.image = R.image.grin_tx_http()
            if self.txType == .sent {
                desc =  R.string.localizable.grinSentUseHttpDesc()
            } else if txType == .receive {
                desc = R.string.localizable.grinReceiveByHttpDesc()
                addressTitleLabel.text = R.string.localizable.grinHttpAddress()
                GrinTxByViteService().getGateWay().done { (string) in
                    self.addressLabel.text = "  \(string)  "
                }
                    .catch { (e) in
                        Toast.show(e.localizedDescription)
                }
            }
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        noiceDetailLabel.attributedText = NSAttributedString.init(string: desc, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])

        if self.txType == .sent {
            infoView.isHidden = true
        } else if txType == .receive {
            closeButton.isHidden = true
        }

        noiceTitleLabel.text = R.string.localizable.grinNoticeTitle()
        copyBtn.setTitle(R.string.localizable.grinTxCopyId(), for: .normal)
        notSeeLabel.text = R.string.localizable.grinNotSeeAgain()
        // Do any additional setup after loading the view.
    }

    @IBAction func closeAction(_ sender: Any) {
        let resourceBundle = businessBundle()
        let storyboard = UIStoryboard.init(name: "GrinInfo", bundle: resourceBundle)
        let sendGrinViewController = storyboard
            .instantiateViewController(withIdentifier: "SendGrinViewController") as! SendGrinViewController
        sendGrinViewController.transferMethod = self.channelType == .vite ? .vite : .http
        var viewControllers = self.navigationController?.viewControllers
        viewControllers?.popLast()
        viewControllers?.append(sendGrinViewController)
        if let viewControllers = viewControllers {
            self.navigationController?.setViewControllers(viewControllers, animated: true)
        }
    }

    @IBAction func copyAction(_ sender: Any) {
        if channelType == .vite {
            UIPasteboard.general.string = HDWalletManager.instance.accounts.first?.address.description
            Toast.show(R.string.localizable.grinThisIsFirstViteAddress())
        } else if channelType == .http {
            GrinTxByViteService().getGateWay().done { (string) in
                UIPasteboard.general.string = string
                Toast.show(R.string.localizable.grinReceiveByHttpAddressCopyed())
                }
                .catch { (e) in
                    Toast.show(e.localizedDescription)
            }
        }
    }

    @IBAction func settingAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            setting["grin_don't_show_\(channelType.rawValue)_teach"] = true
        } else {
            setting["grin_don't_show_\(channelType.rawValue)_teach"] = false
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        for (key, value) in setting {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
