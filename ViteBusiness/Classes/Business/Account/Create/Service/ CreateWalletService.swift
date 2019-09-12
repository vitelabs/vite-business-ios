//
//   CreateWalletService.swift
//  Vite
//
//  Created by Water on 2018/9/11.
//  Copyright © 2018年 vite labs. All rights reserved.
//
import Vite_HDWalletKit
import RxSwift
import RxCocoa

class CreateWalletService {
    static let sharedInstance = CreateWalletService()

    lazy var mnemonicDriver: Driver<String> = self.mnemonicBehaviorRelay.asDriver().filter { $0.count > 0 }
    private var mnemonicBehaviorRelay: BehaviorRelay<String> = BehaviorRelay(value: "")

    fileprivate(set) var name: String = ""
    fileprivate(set) var password: String = ""
    fileprivate(set) var needBackup = true
    fileprivate(set) var language: MnemonicCodeBook = .english

    var mnemonic: String {
        return mnemonicBehaviorRelay.value
    }

    func set(name: String, password: String) {
        self.name = name
        self.password = password
    }

    func generateMnemonic(strength: Mnemonic.Strength = .weak, language: MnemonicCodeBook = .english) {
        self.language = language
        mnemonicBehaviorRelay.accept(Mnemonic.randomGenerator(strength: strength, language: language))
        plog(level: .debug, log: "nnnnnn: \(self.mnemonicBehaviorRelay.value)")
    }

    func setNeedBackup() {
        needBackup = true
    }

    func clearData() {
        name = ""
        password = ""
        mnemonicBehaviorRelay.accept("")
    }

    func createWallet(isBackedUp: Bool, completion: @escaping () -> () = {}) {
        needBackup = false
        DispatchQueue.main.async {
            HUD.show(R.string.localizable.mnemonicAffirmPageAddLoading())
            DispatchQueue.global().async {
                let uuid = UUID().uuidString
                let encryptKey = self.password.toEncryptKey(salt: uuid)
                KeychainService.instance.setCurrentWallet(uuid: uuid, encryptKey: encryptKey)
                HDWalletManager.instance.addAndLoginWallet(uuid: uuid, name: self.name, mnemonic: self.mnemonic, language: self.language, encryptKey: encryptKey, isBackedUp: isBackedUp)
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
