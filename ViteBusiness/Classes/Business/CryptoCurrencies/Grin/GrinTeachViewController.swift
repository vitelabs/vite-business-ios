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

    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    var txType: TxType = .sent
    var channelType: TransferMethod = .vite


    override func viewDidLoad() {
        super.viewDidLoad()

        if channelType == .vite {
            titleLabel.text = "Transfer through Vite Address Flow Graph"
            imageView.image = R.image.grin_tx_vite()
            if self.txType == .sent {
                noiceDetailLabel.text = "Sending GRIN through Vite Address is sharing transaction file encrypted by Vite through Vite Address,which ensures only the real recipient can decrypt the file.Please note that only the first Vite Address in your Vite Address Book can be used to send or receive GRIN."
            } else if txType == .receive {
                noiceDetailLabel.text = "Please share your first Vite address to the sender. Please note that only when you are online with the first Vite address can you receive GRIN tokens."
                addressTitleLabel.text = "Vite Address"
                addressLabel.text = HDWalletManager.instance.accounts.first?.address.description
            }

        } else if channelType == .http {
            titleLabel.text = "Transfer through Http Address Flow Graph"
            imageView.image = R.image.grin_tx_http()
            if self.txType == .sent {
                noiceDetailLabel.text = "Please note there would be transaction fees in both steps above,the first one is payed by the sender and the second one is payed by the recipient."
            } else if txType == .receive {
                noiceDetailLabel.text = "Please share the http address on the bottom to the sender. Please note there would be transaction fee in both steps above(one is payed by the sender and the other one is payed by the recipient), and only when you are online with your first Vite address can you receive GRIN tokens."
                addressTitleLabel.text = "Http Address"
                GrinTxByViteService().getGateWay().done { (string) in
                    self.addressLabel.text = string
                }
                    .catch { (e) in
                        Toast.show(e.localizedDescription)
                }
            }
        }

        if self.txType == .sent {
            infoView.isHidden = true
        } else if txType == .receive {
            closeButton.isHidden = true
        }

        // Do any additional setup after loading the view.
    }

    @IBAction func closeAction(_ sender: Any) {
        let resourceBundle = businessBundle()
        let storyboard = UIStoryboard.init(name: "GrinInfo", bundle: resourceBundle)
        let sendGrinViewController = storyboard
            .instantiateViewController(withIdentifier: "SendGrinViewController") as! SendGrinViewController
        sendGrinViewController.transferMethod = self.channelType == .vite ? .vite : .http
        self.navigationController?.pushViewController(sendGrinViewController, animated: true)
    }

    @IBAction func copyAction(_ sender: Any) {
        if channelType == .vite {
            UIPasteboard.general.string = HDWalletManager.instance.accounts.first?.address.description
            Toast.show("Copyed")
        } else if channelType == .http {
            GrinTxByViteService().getGateWay().done { (string) in
                UIPasteboard.general.string = string
                Toast.show("Copyed")
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
            setting["grin_don't_show_\(channelType.rawValue)_tehch"] = false
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
