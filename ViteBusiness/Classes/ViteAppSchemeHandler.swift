//
//  ViteAppSchemeHandler.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/30.
//

import ViteWallet
import RxSwift
import RxCocoa
import Vite_HDWalletKit

class ViteAppSchemeHandler {
    static let  instance = ViteAppSchemeHandler()

    private let disposeBag = DisposeBag()

    private init() {
        NotificationCenter.default.rx.notification(NSNotification.Name.homePageDidAppear)
            .bind { [weak self] _ in self?.handleSavedURLIfHas() }
            .disposed(by: self.disposeBag)
    }

    var url: URL?

    func handleSavedURLIfHas() {
        guard let _ = HDWalletManager.instance.account else { return }
        guard let url = self.url else { return }
        self.url = nil
        handle(url)
    }

    func handle(_ url: URL) {
        if let code = url.queryParameters["vitex_invite_code"], !code.isEmpty {
            CreateWalletService.sharedInstance.vitexInviteCode = code
        }

        guard let account = HDWalletManager.instance.account else {
            self.url = url
            return
        }

        if url.scheme == "http" || url.scheme == "https" {
            NavigatorManager.instance.route(url: url)
        } else if handleViteScheme(url) == false {
            GrinManager.default.handle(url: url)
        }
    }

    func handleViteScheme(_ url: URL, allowActions: [AppScheme] = AppScheme.allCases) -> Bool {
        guard url.scheme == AppScheme.value else { return false }
        guard let ret = AppScheme(rawValue: url.host ?? "") else { return false }
        guard allowActions.contains(ret) else { return false }

        switch ret {
        case .open:
            if let urlString = url.queryParameters["url"]?.removingPercentEncoding,
                let url = URL(string: urlString) {
                NavigatorManager.instance.route(url: url)
            }
        case .sendTx:
            if let uriString = url.queryParameters["uri"]?.removingPercentEncoding {
                if case .success(let uri) = ViteURI.parser(string: uriString) {
                    // not support dex contract now
                    if uri.address.isDexAddress {
                        return false
                    }
                    let vc = SignAndSendConfirmViewController(uri: uri)
                    UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        case .vote:
            if let name = url.queryParameters["name"]?.removingPercentEncoding {
                let gid = url.queryParameters["gid"]?.removingPercentEncoding ?? ViteWalletConst.ConsensusGroup.snapshot.id
                let uri = SASConfirmViewModelContractVote.makeURIBy(name: name, gid: gid)
                let vc = SignAndSendConfirmViewController(uri: uri)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }
        case .backupWallet:
            // only allow in logout status
            guard HDWalletManager.instance.account == nil else {
                return false
            }

            if let name = url.queryParameters["name"]?.removingPercentEncoding,
                let entropy = url.queryParameters["entropy"]?.removingPercentEncoding,
                let language = url.queryParameters["language"]?.removingPercentEncoding,
                let password = url.queryParameters["password"]?.removingPercentEncoding,
                let uri = CreateWalletService.BackupWalletURI(name: name, entropy: entropy, languageString: language, password: password) {

                Alert.show(title: R.string.localizable.mnemonicBackupScanAlertTitle(), message: R.string.localizable.mnemonicBackupScanAlertMessage(), actions: [
                    (.default(title: R.string.localizable.mnemonicBackupScanAlertCancelTitle()), nil),
                    (.default(title: R.string.localizable.mnemonicBackupScanAlertOkTitle()), {[weak self] _ in
                        HDWalletManager.instance.importAndLoginWallet(name: uri.name, mnemonic: uri.mnemonic, language: uri.language, password: uri.password, completion: { success in
                            if success {
                                CreateWalletService.sharedInstance.setCreateFromScan(password: uri.password)
                            }
                        })
                    }),
                    ])
            }
        }

        return true
    }
}

extension ViteAppSchemeHandler {
    enum AppScheme: String, CaseIterable {
        static let value = "viteapp"

        case open
        case sendTx = "send-tx"
        case vote
        case backupWallet = "backup-wallet"

        static func makeURI(action: AppScheme, keyAndValue: [(String, String)]) -> String {
            var uri = "\(AppScheme.value)://\(action.rawValue)?"
            for (key, value) in keyAndValue {
                uri = "\(uri)\(key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)=\(value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)&"
            }
            if uri.hasSuffix("?") || uri.hasSuffix("&") {
                uri = String(uri.dropLast())
            }
            return uri
        }
    }
}
