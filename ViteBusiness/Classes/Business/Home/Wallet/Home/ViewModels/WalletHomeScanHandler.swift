//
//  WalletHomeScanHandler.swift
//  Action
//
//  Created by haoshenyang on 2019/9/10.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources
import Vite_HDWalletKit
import ViteWallet
import BigInt

import Then

class WalletHomeScanHandler {

    var navigationController: UINavigationController? {
        return UIViewController.current?.navigationController
    }

    func scan() {
        let scanViewController = ScanViewController()
        _ = scanViewController.rx.result.bind { [weak scanViewController, self] result in
            if case .success(let uri) = ViteURI.parser(string: result), !uri.address.isDexAddress {
                self.handleScanResult(with: uri, scanViewController: scanViewController)
            } else if let url = URL.init(string: result), (result.hasPrefix("http://") || result.hasPrefix("https://")) {
                self.handleScanResult(with: url, scanViewController: scanViewController)
            } else if case .success(let uri) = BifrostURI.parser(string: result) {
                self.handleScanResultForBifrost(with: uri, scanViewController: scanViewController)
            } else {
                if let url = URL(string: result), ViteAppSchemeHandler.instance.handleViteScheme(url) {
                    // do nothing
                } else {
                    scanViewController?.showAlertMessage(result)
                }
            }
        }
        self.navigationController?.pushViewController(scanViewController, animated: true)
    }

    func handleScanResult(with uri: ViteURI, scanViewController: ScanViewController?) {
        scanViewController?.view.displayLoading(text: "")
        TokenInfoCacheService.instance.tokenInfo(forViteTokenId: uri.tokenId) {[weak scanViewController] (result) in
            scanViewController?.view.hideLoading()
            switch result {
            case .success(let tokenInfo):
                guard let amount = uri.amountForSmallestUnit(decimals: tokenInfo.decimals) else {
                    scanViewController?.showToast(string: R.string.localizable.viteUriAmountFormatError())
                    return
                }

                guard let fee = uri.feeForSmallestUnit(decimals: ViteWalletConst.viteToken.decimals) else {
                    scanViewController?.showToast(string: R.string.localizable.viteUriAmountFormatError())
                    return
                }

                if !tokenInfo.isContains {
                    MyTokenInfosService.instance.append(tokenInfo: tokenInfo)
                }

                let sendViewController = SendViewController(tokenInfo: tokenInfo, address: uri.address, amount: uri.amount != nil ? amount : nil, data: uri.data)
                UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            case .failure(let error):
                scanViewController?.showToast(string: error.viteErrorMessage)
            }
        }
    }

    func handleScanResult(with url: URL, scanViewController: ScanViewController?) {

        func goWeb() {
            let webvc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(webvc, animated: true)
        }

        if AppConfigService.instance.isInWhiteList(url: url) == false {
            Alert.show(title: R.string.localizable.walletHomeScanUrlAlertTitle(),
                       message: R.string.localizable.walletHomeScanUrlAlertMessage(),
                       actions: [
                        (.cancel, { _ in
                            scanViewController?.startCaptureSession()
                        }),
                        (.default(title: R.string.localizable.confirm()), { _ in
                            goWeb()
                        })
                ])
        } else {
            goWeb()
        }
    }

    func handleScanResultForBifrost(with uri: BifrostURI, scanViewController: ScanViewController?) {
        BifrostManager.instance.tryConnect(uri: uri)
    }
}
