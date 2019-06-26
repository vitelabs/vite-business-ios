//
//  CrossChainETHExchange.swift
//  Action
//
//  Created by haoshenyang on 2019/6/13.
//

import ViteWallet
import PromiseKit

class CrossChainDepositETH {

    init(gatewayInfoService: CrossChainGatewayInfoService) {
        self.gatewayInfoService = gatewayInfoService
    }

    let gatewayInfoService: CrossChainGatewayInfoService

    //Send rival Tx

//    关于跨链转入流程
//    网关建立 用户VITE地址 与 对手链转入地址 的绑定关系。
//    网关监听对手链交易，如果交易和绑定的转入地址相匹配，等待合适的确认数。
//    网关确认对手链交易后，发起 VITE 上的 TOT 转出交易，交易目标地址为绑定的用户 VITE 地址。
//    网关监听 VITE 上的该笔 TOT 转出交易，如果交易没有最终被确认，需要重试发送。
//    #

    func deposit(to viteAddress: String, totId: String, amount: String, gasPrice: Float ) {

        let metalInfo = gatewayInfoService.getMetaInfo()
        let withdrawInfo = gatewayInfoService.depositInfo(viteAddress: viteAddress)
        UIViewController.current?.view.displayLoading()
        when(fulfilled: metalInfo, withdrawInfo)
            .done { (metalInfo, withdrawInfo) in
                UIViewController.current?.view.hideLoading()
                guard metalInfo.depositState == .open else {
                    Toast.show("deposit state is not open")
                    return
                }

                guard let amount = Amount(amount) else {
                    Toast.show("wrong amount")
                    return
                }

                if let minimumDepositAmount = Amount(withdrawInfo.minimumDepositAmount), amount < minimumDepositAmount {
                    let minStr = minimumDepositAmount.amountShort(decimals: self.gatewayInfoService.tokenInfo.gatewayInfo?.mappedToken.decimals ?? 0)
                    let minSymbol = self.gatewayInfoService.tokenInfo.gatewayInfo?.mappedToken.symbol ?? ""
                    Toast.show(R.string.localizable.crosschainDepositMinAlert() + minStr + minSymbol)
                    return
                }

                guard let tokenInfo = self.gatewayInfoService.tokenInfo.gatewayInfo?.mappedToken else {
                    Toast.show("wrong gateway Info")
                    return
                }

                Workflow.sendEthTransactionWithConfirm(toAddress: withdrawInfo.depositAddress, tokenInfo: tokenInfo, amount: amount, gasPrice: gasPrice, completion: { (result) in
                    switch result {
                    case .success(let string):
                        break
                    case .failure(let e):
                        Toast.show(e.localizedDescription)
                    }
                })
        }
            .catch { (error) in
                UIViewController.current?.view.hideLoading()
                Toast.show(error.localizedDescription)
        }

    }

}
