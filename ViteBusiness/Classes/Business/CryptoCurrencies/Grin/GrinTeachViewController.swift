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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noiceDetailLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var notSeeLabel: UILabel!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var noiceTitleLabel: UILabel!
    @IBOutlet weak var addressLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var infoViewTopConstraint: NSLayoutConstraint!
    var setting: [String: Bool] = [:]
    var txType: TxType = .sent
    var channelType: TransferMethod = .vite

    @IBOutlet weak var actionButton: UIButton!

    var fromSendVC = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var desc = ""
        if channelType == .vite {
            imageView.image = LocalizationService.sharedInstance.currentLanguage == .chinese ? R.image.grin_teach_vite_cn() :R.image.grin_teach_vite()
            if self.txType == .sent {
                titleLabel.text = R.string.localizable.grinTeachViteSentTitle()
                desc =  R.string.localizable.grinSentUseViteDesc()
                actionButton.setTitle(R.string.localizable.grinTeachViteSendStartSend(), for: .normal)
            } else if txType == .receive {
                actionButton.setTitle(R.string.localizable.grinTeachViteReceiveCopyViteAddress(), for: .normal)
                titleLabel.text = R.string.localizable.grinTeachViteReceiveTitle()
                desc = R.string.localizable.grinReceiveByViteDesc()
                let viteAddress = HDWalletManager.instance.account?.address.description ?? ""
                addressLabel.text = viteAddress
                addressTitleLabel.text = R.string.localizable.grinViteAddress()
                QRCodeHelper.createQRCode(string: viteAddress) { [weak qrCodeImageView](image) in
                    qrCodeImageView?.image = image
                }

            }
        } else if channelType == .http {
            if self.txType == .sent {
                imageView.image = LocalizationService.sharedInstance.currentLanguage == .chinese ? R.image.grin_teach_http_send_cn() : R.image.grin_teach_http_send()
                titleLabel.text = R.string.localizable.grinTeachHttpSentTitle()
                desc =  R.string.localizable.grinSentUseHttpDesc()
                actionButton.setTitle(R.string.localizable.grinTeachViteSendStartSend(), for: .normal)
            } else if txType == .receive {
                imageView.image = LocalizationService.sharedInstance.currentLanguage == .chinese ? R.image.grin_teach_http_receive_cn() :R.image.grin_teach_http_receive()
                titleLabel.text = R.string.localizable.grinTeachHttpReceiveTitle()
                desc = R.string.localizable.grinReceiveByHttpDesc()
                addressTitleLabel.text = R.string.localizable.grinHttpAddress()
                addressLabelLeftConstraint.constant = -62
                view.layoutIfNeeded()
                actionButton.setTitle(R.string.localizable.grinTeachHttpReceiveCopyHttpAddress(), for: .normal)
                GrinTxByViteService().getGateWay().done { (string) in
                    self.addressLabel.text = string
                }
                    .catch { (e) in
                        Toast.show(e.localizedDescription)
                }
            }
        } else if channelType == .file {
            imageView.image = LocalizationService.sharedInstance.currentLanguage == .chinese ? R.image.grin_teach_file_cn() : R.image.grin_teach_file()
            if self.txType == .sent {
                actionButton.setTitle(R.string.localizable.grinTeachViteSendStartSend(), for: .normal)
                titleLabel.text = R.string.localizable.grinTeachFileSendTitle()
                desc = R.string.localizable.grinTeachFileSendDesc()
            } else if txType == .receive {
                actionButton.isHidden = true
                titleLabel.text = R.string.localizable.grinTeachFileReceiveTitle()
                desc = R.string.localizable.grinTeachFileReceiveDesc()
            }
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        noiceDetailLabel.attributedText = NSAttributedString.init(string: desc, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])

        if txType == .receive {
            settingButton.isHidden = true
            notSeeLabel.isHidden = true
        }
        if fromSendVC {
            settingButton.isHidden = true
            notSeeLabel.isHidden = true
            actionButton.isHidden = true
        }

        if self.txType == .sent || self.channelType == .file {
            infoView.isHidden = true
        } else {
            if notSeeLabel.isHidden == true {
                infoViewTopConstraint.constant = -10
                view.layoutIfNeeded()
            }
        }

        noiceTitleLabel.text = R.string.localizable.grinNoticeTitle()
        notSeeLabel.text = R.string.localizable.grinNotSeeAgain()

    }

    @IBAction func actionButtonDidClick(_ sender: Any) {
        if self.txType == .sent {
            let resourceBundle = businessBundle()
            let storyboard = UIStoryboard.init(name: "GrinInfo", bundle: resourceBundle)
            let sendGrinViewController = storyboard
                .instantiateViewController(withIdentifier: "SendGrinViewController") as! SendGrinViewController
            sendGrinViewController.transferMethod = self.channelType
            var viewControllers = self.navigationController?.viewControllers
            viewControllers?.popLast()
            viewControllers?.append(sendGrinViewController)
            if let viewControllers = viewControllers {
                self.navigationController?.setViewControllers(viewControllers, animated: true)
            }
        } else if self.txType == .receive {
            if channelType == .vite {
                UIPasteboard.general.string = HDWalletManager.instance.accounts.first?.address
                Toast.show(R.string.localizable.grinReceiveByViteAddressCopyed())
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
