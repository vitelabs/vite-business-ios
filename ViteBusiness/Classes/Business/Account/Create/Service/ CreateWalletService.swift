//
//   CreateWalletService.swift
//  Vite
//
//  Created by Water on 2018/9/11.
//  Copyright © 2018年 vite labs. All rights reserved.
//
import Vite_HDWalletKit

class CreateWalletService {
    static let sharedInstance = CreateWalletService()

    var name: String = ""
    var mnemonic: String = ""
    var password: String = ""
    var needBackup = true

    func clearData() {
        name = ""
        mnemonic = ""
        password = ""
    }

    func createWallet(isBackedUp: Bool, completion: @escaping () -> () = {}) {
        needBackup = false
        DispatchQueue.main.async {
            HUD.show(R.string.localizable.mnemonicAffirmPageAddLoading())
            DispatchQueue.global().async {
                let uuid = UUID().uuidString
                let encryptKey = self.password.toEncryptKey(salt: uuid)
                KeychainService.instance.setCurrentWallet(uuid: uuid, encryptKey: encryptKey)
                HDWalletManager.instance.addAndLoginWallet(uuid: uuid, name: self.name, mnemonic: self.mnemonic, encryptKey: encryptKey, isBackedUp: isBackedUp)
                DispatchQueue.main.async {
                    HUD.hide()
                    NotificationCenter.default.post(name: .createAccountSuccess, object: nil)
                    completion()
                }
            }
        }
    }

    func showBackUpTipAlert(cancel: @escaping () -> Void = {}, ok: @escaping () -> Void = {}) {
        let controller = AlertControl(title: R.string.localizable.mnemonicBackupTipAlertTitle(), message: R.string.localizable.mnemonicBackupTipAlertMessage())
        let cancelAction = AlertAction(title: R.string.localizable.mnemonicBackupTipAlertCancelTitle(), style: .light) { _ in
            cancel()
        }
        let okAction = AlertAction(title: R.string.localizable.mnemonicBackupTipAlertOkTitle(), style: .light) { controller in
            let textField = (controller.textFields?.first)! as UITextField
            if HDWalletManager.instance.verifyPassword(textField.text ?? "") {
                let vc = BackupMnemonicViewController(forCreate: false)
                let nav = BaseNavigationController(rootViewController: vc)
                UIViewController.current?.present(nav, animated: true, completion: nil)
            } else {
                Toast.show(R.string.localizable.exportPageAlterPasswordError())
            }
            ok()
        }
        controller.addPwdTextField { (textfield) in
            textfield.keyboardType = .asciiCapable
            textfield.isSecureTextEntry = true
            textfield.placeholder = R.string.localizable.exportPageAlterTfPlaceholder()
        }
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        controller.show()
    }
}
