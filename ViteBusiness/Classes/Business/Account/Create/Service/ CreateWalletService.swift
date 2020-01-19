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
import ObjectMapper

class CreateWalletService {
    static let sharedInstance = CreateWalletService()

    lazy var mnemonicDriver: Driver<String> = self.mnemonicBehaviorRelay.asDriver().filter { $0.count > 0 }
    private var mnemonicBehaviorRelay: BehaviorRelay<String> = BehaviorRelay(value: "")

    fileprivate(set) var name: String = ""
    fileprivate(set) var password: String = ""
    fileprivate(set) var needBackup = true
    fileprivate(set) var language: MnemonicCodeBook = .english
    fileprivate(set) var createFromScan = false

    fileprivate var _vitexInviteCode: String?

    var vitexInviteCode: String? {
        set {
            _vitexInviteCode = newValue
        }

        get {
            if let code = _vitexInviteCode {
                return code
            } else {
                if let text = UIPasteboard.general.string,
                    let url = URL(string: text),
                    let code = url.queryParameters["vitex_invite_code"], !code.isEmpty {
                    _vitexInviteCode = code
                    return code
                } else {
                    return nil
                }
            }
        }
    }

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
    }

    func setNeedBackup() {
        needBackup = true
    }

    func setCreateFromScan(password: String) {
        createFromScan = true
        self.password = password
    }

    func GoExportMnemonicIfNeeded() {
        guard createFromScan else { return }
        createFromScan = false
        let vc = ExportMnemonicViewController(password: password)
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
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
                let vc = BackupMnemonicViewController(password: textField.text ?? "")
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

extension CreateWalletService {
    struct BackupWalletURI {
        let name: String
        let entropy: String
        let languageString: String
        let password: String

        let mnemonic: String

        init?(name: String, mnemonic: String, language: MnemonicCodeBook, password: String) {
            switch language {
            case .english:
                self.languageString = "en"
            case .simplifiedChinese:
                self.languageString = "zh-Hans"
            default:
                return nil
            }

            guard let entropy = Mnemonic.mnemonicsToEntropy(mnemonic, language: language) else { return nil }

            self.name = name
            self.entropy = entropy.toHexString()
            self.password = password
            self.mnemonic = mnemonic
        }

        init?(name: String, entropy: String, languageString: String, password: String) {
            let language: MnemonicCodeBook = {
                if languageString == "zh-Hans" {
                    return .simplifiedChinese
                } else {
                    return .english
                }
            }()
            guard languageString == "en" || languageString == "zh-Hans" else { return nil }
            let mnemonic = Mnemonic.generator(entropy: Data(bytes: entropy.hex2Bytes), language: language)
            guard mnemonic.count > 0 else { return nil}
            self.name = name
            self.entropy = entropy
            self.languageString = languageString
            self.password = password
            self.mnemonic = mnemonic
        }

        var language: MnemonicCodeBook {
            if languageString == "zh-Hans" {
                return .simplifiedChinese
            } else {
                return .english
            }
        }

        var uri: String {
            return ViteAppSchemeHandler.AppScheme.makeURI(action: .backupWallet,
                                                          keyAndValue: [
                                                            ("name", name),
                                                            ("entropy", entropy),
                                                            ("language", languageString),
                                                            ("password", password)])
        }
    }
}
