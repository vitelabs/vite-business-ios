//
//  BuildInContractDexMarketConfig.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit
import BigInt

struct BuildInContractDexMarketConfig: BuildInContractProtocol {

    let abi = ABI.BuildIn.dexMarketConfig

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }

        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let operationCodeValue = values[0] as? ABIUnsignedIntegerValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let tradeTokenIdValue = values[1] as? ABITokenIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let quoteTokenIdValue = values[2] as? ABITokenIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let ownerAddressValue = values[3] as? ABIAddressValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let takerFeeRateValue = values[4] as? ABISignedIntegerValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let makerFeeRateValue = values[5] as? ABISignedIntegerValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let stopMarketValue = values[6] as? ABIBoolValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let account = HDWalletManager.instance.account else {
                return Promise(error: ConfirmError.unknown("not logon"))
            }

            return when(fulfilled: ViteNode.mintage.getToken(tokenId: tradeTokenIdValue.toString()),
                        ViteNode.mintage.getToken(tokenId: quoteTokenIdValue.toString())).then { (tradeToken, quoteToken) -> Promise<BifrostConfirmInfo> in

                            let code = operationCodeValue.toBigUInt()
                            let market = "\(tradeToken.uniqueSymbol)/\(quoteToken.uniqueSymbol)"

                            if code == 1 {
                                return self.transferPairConfirmInfo(market: market, ownerAddress: ownerAddressValue.toString())
                            } else if code == 2 || code == 4 || code == 6 {
                                return self.adjustFeesConfirmInfo(market: market,
                                                                  currentAddress: account.address,
                                                                  code: code,
                                                                  takerFeeRate: takerFeeRateValue.toBigInt(),
                                                                  makerFeeRate: makerFeeRateValue.toBigInt())
                            } else if code == 8 {
                                return self.stopMarketConfirmInfo(market: market, currentAddress: account.address, isStop: stopMarketValue.toBool())
                            } else {
                                return Promise(error: ConfirmError.InvalidData)
                            }
            }
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }

    }

    func transferPairConfirmInfo(market: String, ownerAddress: ViteAddress) -> Promise<BifrostConfirmInfo> {

        let description = VBViteSendTx.Description(
            function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexTransferPairFunctionTitle()),
            inputs: [
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexTransferPairItem0Title()),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexTransferPairItem1Title()),
            ])
        let title = description.function.title ?? ""

        let items = [
            description.inputs[0].confirmItemInfo(text: market),
            description.inputs[1].confirmItemInfo(text: ownerAddress),
        ]
        return Promise.value(BifrostConfirmInfo(title: title, items: items))
    }

    func adjustFeesConfirmInfo(market: String, currentAddress: ViteAddress, code: BigUInt, takerFeeRate: BigInt, makerFeeRate: BigInt) -> Promise<BifrostConfirmInfo> {

        var inputs = [
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexAdjustFeesItem0Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexAdjustFeesItem1Title()),
        ]

        let tr = String(format: "%.3f%%", Double(takerFeeRate)/1000)
        let mr = String(format: "%.3f%%", Double(makerFeeRate)/1000)

        let items: [BifrostConfirmItemInfo]
        if code == 2 {
            items = [
                inputs[0].confirmItemInfo(text: market),
                inputs[1].confirmItemInfo(text: currentAddress),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexAdjustFeesItemTakerTitle(),
                                              style: VBViteSendTx.InputDescription.Style.blue).confirmItemInfo(text: tr),
            ]

        } else if code == 4 {
            items = [
                inputs[0].confirmItemInfo(text: market),
                inputs[1].confirmItemInfo(text: currentAddress),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexAdjustFeesItemMakerTitle(),
                                              style: VBViteSendTx.InputDescription.Style.blue).confirmItemInfo(text: mr),
            ]
        } else if code == 6 {
            items = [
                inputs[0].confirmItemInfo(text: market),
                inputs[1].confirmItemInfo(text: currentAddress),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexAdjustFeesItemTakerTitle(),
                                              style: VBViteSendTx.InputDescription.Style.blue).confirmItemInfo(text: tr),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexAdjustFeesItemMakerTitle(),
                                              style: VBViteSendTx.InputDescription.Style.blue).confirmItemInfo(text: mr),
            ]
        } else {
            return Promise(error: ConfirmError.InvalidData)
        }

        return Promise.value(BifrostConfirmInfo(title: R.string.localizable.buildinDexAdjustFeesFunctionTitle(),
                                                items: items))
    }

    func stopMarketConfirmInfo(market: String, currentAddress: ViteAddress, isStop: Bool) -> Promise<BifrostConfirmInfo> {

        let title: String
        let inputs: [VBViteSendTx.InputDescription]
        if isStop {
            title = R.string.localizable.buildinDexSuspendTradingPairFunctionTitle()
            inputs = [
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexSuspendTradingPairItem0Title()),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexSuspendTradingPairItem1Title()),
            ]
        } else {
            title = R.string.localizable.buildinDexRecoverTradingPairFunctionTitle()
            inputs = [
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexRecoverTradingPairItem0Title()),
                VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexRecoverTradingPairItem1Title()),
            ]
        }

        let items = [
            inputs[0].confirmItemInfo(text: market),
            inputs[1].confirmItemInfo(text: currentAddress),
        ]
        return Promise.value(BifrostConfirmInfo(title: title, items: items))
    }
}
