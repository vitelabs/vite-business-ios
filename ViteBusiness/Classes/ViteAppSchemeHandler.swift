//
//  ViteAppSchemeHandler.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/30.
//

import ViteWallet
import RxSwift
import RxCocoa

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
        guard let account = HDWalletManager.instance.account else {
            self.url = url
            return
        }

        if handleViteScheme(url) == false {
            GrinManager.default.handle(url: url)
        }
    }

    func handleViteScheme(_ url: URL) -> Bool {
        guard url.scheme == AppScheme.value else { return false }
        guard let ret = AppScheme(rawValue: url.host ?? "") else { return false }

        switch ret {
        case .open:
            if let urlString = url.queryParameters["url"]?.removingPercentEncoding,
                let url = URL(string: urlString) {
                NavigatorManager.instance.push(url)
            }
        case .sendTx:
            if let uriString = url.queryParameters["uri"]?.removingPercentEncoding {
                if case .success(let uri) = ViteURI.parser(string: uriString) {
                    // not support dex contract now
                    if uri.address == ViteWalletConst.ContractAddress.dexFund.address ||
                        uri.address == ViteWalletConst.ContractAddress.dexTrade.address {
                        return true
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
        }

        return true
    }
}

extension ViteAppSchemeHandler {
    enum AppScheme: String {
        static let value = "viteapp"

        case open
        case sendTx = "send-tx"
        case vote
    }
}
