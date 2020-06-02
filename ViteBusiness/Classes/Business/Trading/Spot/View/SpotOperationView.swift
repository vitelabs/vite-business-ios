//
//  SpotOperationView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/30.
//

import Foundation
import RxSwift
import RxCocoa
import ViteWallet
import BigInt
import PromiseKit
import ActiveLabel

class SpotOperationView: UIView {

    static let height: CGFloat = 303

    var lastSymbol = ""
    let segmentView = SegmentView()
    let priceTextField = TextFieldView()
    let priceLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.text = "≈--"
    }
    let volTextField = TextFieldView()
    let percentView = PercentView()

    let transferButton = UIButton().then {
        $0.setImage(R.image.icon_spot_transfer(), for: .normal)
        $0.setImage(R.image.icon_spot_transfer()?.highlighted, for: .highlighted)
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 0)
    }

    let amountLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.text = R.string.localizable.spotPageAvailable("--")
    }

    let volLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.text = R.string.localizable.spotPageBuyable("--")
    }

    let vipButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setImage(R.image.icon_spot_vip_close(), for: .normal)
        $0.setImage(R.image.icon_spot_vip_close()?.highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        $0.setTitle(R.string.localizable.spotPageOpenVip(), for: .normal)
    }

    let buyButton = UIButton().then {
        $0.setTitle(R.string.localizable.spotPageButtonBuyTitle(), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        $0.setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0x01D764)).resizable, for: .normal)
        $0.setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0x01D764)).highlighted.resizable, for: .highlighted)
    }
    let sellButton = UIButton().then {
        $0.setTitle(R.string.localizable.spotPageButtonSellTitle(), for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        $0.setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xE5494D)).resizable, for: .normal)
        $0.setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xE5494D)).highlighted.resizable, for: .highlighted)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let limitBuyTitle = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.text = R.string.localizable.spotPageButtonLimitBuyTitle()
        }


        priceTextField.textField.kas_setReturnAction(.resignFirstResponder, delegate: self)
        volTextField.textField.kas_setReturnAction(.resignFirstResponder, delegate: self)


        addSubview(segmentView)
        addSubview(limitBuyTitle)
        addSubview(priceTextField)
        addSubview(priceLabel)
        addSubview(volTextField)
        addSubview(percentView)
        addSubview(transferButton)
        addSubview(amountLabel)
        addSubview(volLabel)

        addSubview(vipButton)
        addSubview(buyButton)
        addSubview(sellButton)

        segmentView.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
        }

        limitBuyTitle.snp.makeConstraints { (m) in
            m.top.equalTo(segmentView.snp.bottom).offset(12)
            m.left.equalToSuperview()
        }

        priceTextField.snp.makeConstraints { (m) in
            m.top.equalTo(limitBuyTitle.snp.bottom).offset(12)
            m.left.right.equalToSuperview()
        }

        priceLabel.snp.makeConstraints { (m) in
            m.top.equalTo(priceTextField.snp.bottom).offset(6)
            m.left.right.equalToSuperview()
        }

        volTextField.snp.makeConstraints { (m) in
            m.top.equalTo(priceLabel.snp.bottom).offset(6)
            m.left.right.equalToSuperview()
        }

        percentView.snp.makeConstraints { (m) in
            m.top.equalTo(volTextField.snp.bottom).offset(6)
            m.left.right.equalToSuperview()
        }

        transferButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(volLabel)
            m.right.equalTo(percentView)
            m.width.equalTo(37)
        }

        volLabel.snp.makeConstraints { (m) in
            m.top.equalTo(percentView.snp.bottom).offset(12)
            m.left.equalToSuperview()
            m.right.equalTo(transferButton.snp.left).offset(15)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.top.equalTo(volLabel.snp.bottom).offset(4)
            m.left.right.equalToSuperview()
        }

        vipButton.snp.makeConstraints { (m) in
            m.top.equalTo(amountLabel.snp.bottom).offset(4)
            m.left.equalToSuperview()
        }

        buyButton.snp.makeConstraints { (m) in
            m.top.equalTo(vipButton.snp.bottom).offset(12)
            m.left.right.equalToSuperview()
            m.bottom.equalToSuperview()
            m.height.equalTo(34)
        }

        sellButton.snp.makeConstraints { (m) in
            m.edges.equalTo(buyButton).priorityHigh()
        }

        priceTextField.subButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            guard let info = self.marketInfoBehaviorRelay.value else { return }
            let step: Double = pow(10, -Double(info.statistic.pricePrecision))

            guard let text = self.priceTextField.textField.text,
                let value = Double(text),
                value - step > 0 else {
                    return
            }
            let new = String(format: "%0.\(info.statistic.pricePrecision)f", value - step)
            self.setPrice(new)
        }.disposed(by: rx.disposeBag)

        priceTextField.addButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            guard let info = self.marketInfoBehaviorRelay.value else { return }
            let step: Double = pow(10, -Double(info.statistic.pricePrecision))

            guard let text = self.priceTextField.textField.text,
                let value = Double(text) else {
                    return
            }
            let new = String(format: "%0.\(info.statistic.pricePrecision)f", value + step)
            self.setPrice(new)
        }.disposed(by: rx.disposeBag)


        volTextField.subButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            guard let info = self.marketInfoBehaviorRelay.value else { return }
            let step: Double = pow(10, -Double(info.statistic.quantityPrecision))

            guard let text = self.volTextField.textField.text,
                let value = Double(text),
                value - step > 0 else {
                    return
            }
            let new = String(format: "%0.\(info.statistic.quantityPrecision)f", value - step)
            self.setVol(new)
        }.disposed(by: rx.disposeBag)

        volTextField.addButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            guard let info = self.marketInfoBehaviorRelay.value else { return }
            let step: Double = pow(10, -Double(info.statistic.quantityPrecision))

            guard let text = self.volTextField.textField.text,
                let value = Double(text) else {
                    return
            }
            let new = String(format: "%0.\(info.statistic.quantityPrecision)f", value + step)
            self.setVol(new)
        }.disposed(by: rx.disposeBag)

        segmentView.isBuyBehaviorRelay.bind { [weak self] isBuy in
            guard let `self` = self else { return }
            if isBuy {
                self.buyButton.isHidden = false
                self.sellButton.isHidden = true
                self.priceTextField.textField.placeholder = R.string.localizable.spotPagePriceBuyPlaceholder()
                self.volTextField.textField.placeholder = R.string.localizable.spotPageVolBuyPlaceholder()
            } else {
                self.buyButton.isHidden = true
                self.sellButton.isHidden = false
                self.priceTextField.textField.placeholder = R.string.localizable.spotPagePriceSellPlaceholder()
                self.volTextField.textField.placeholder = R.string.localizable.spotPageVolSellPlaceholder()
            }
            self.setVol("")
            self.percentView.index = nil
        }.disposed(by: rx.disposeBag)

        spotViewModelBehaviorRelay.map { $0?.vipState }.bind { [weak self] in
            guard let `self` = self else { return }
            if $0 ?? false {
                self.vipButton.setImage(R.image.icon_spot_vip_open(), for: .normal)
                self.vipButton.setImage(R.image.icon_spot_vip_open()?.highlighted, for: .highlighted)
                self.vipButton.setTitle(R.string.localizable.spotPageCloseVip(), for: .normal)
            } else {
                self.vipButton.setImage(R.image.icon_spot_vip_close(), for: .normal)
                self.vipButton.setImage(R.image.icon_spot_vip_close()?.highlighted, for: .highlighted)
                self.vipButton.setTitle(R.string.localizable.spotPageOpenVip(), for: .normal)
            }
        }.disposed(by: rx.disposeBag)

        Driver.combineLatest(ViteBalanceInfoManager.instance.dexBalanceInfosDriver,
                             marketInfoBehaviorRelay.asDriver().filterNil(),
                             spotViewModelBehaviorRelay.asDriver().filterNil(),
                             priceTextField.textField.rx.text.asDriver(),
                             volTextField.textField.rx.text.asDriver(),
                             segmentView.isBuyBehaviorRelay.asDriver()).drive(onNext: { [weak self] (balanceMap, info, spotViewModel, priceText, volText, isBuy) in
                                guard let `self` = self else { return }

                                let quoteTokenInfo = spotViewModel.quoteTokenInfo
                                let tradeTokenInfo = spotViewModel.tradeTokenInfo
                                let sourceTokenInfo = isBuy ? quoteTokenInfo : tradeTokenInfo

                                let sourceToken = sourceTokenInfo.toViteToken()!
                                let balance = balanceMap[sourceToken.id]?.available ?? Amount()
                                self.amountLabel.text = R.string.localizable.spotPageAvailable(balance.amountFullWithGroupSeparator(decimals: sourceToken.decimals)) + " \(sourceTokenInfo.symbol)"

                                if let priceText = priceText, let price = BigDecimal(priceText), price != BigDecimal(0) {
                                    self.priceLabel.text = "≈" + MarketInfoService.shared.legalPrice(quoteTokenSymbol: quoteTokenInfo.uniqueSymbol, price: priceText)

                                    if let amount = type(of: self).calcAmount(vm: spotViewModel, priceText: priceText, volText: volText) {
                                        let totalBigInt = isBuy ? (amount + type(of: self).calcFee(vm: spotViewModel, amount: amount)) : amount
                                        let total = totalBigInt.amount(decimals: quoteTokenInfo.decimals, count: Int(info.statistic.pricePrecision)) + " " + quoteTokenInfo.symbol
                                        self.volLabel.text = R.string.localizable.spotPageTotal(total)
                                    } else {
                                        if isBuy {
                                            let text = type(of: self).calcVol(vm: spotViewModel, info: info, priceText: priceText, isBuy: isBuy, p: 1) ?? "--"
                                            self.volLabel.text = R.string.localizable.spotPageBuyable(text) + " \(tradeTokenInfo.symbol)"
                                        } else {
                                            let vol = BigDecimal(balance.amountFull(decimals: sourceToken.decimals))! * price
                                            self.volLabel.text = R.string.localizable.spotPageSellable(BigDecimalFormatter.format(bigDecimal: vol, style: .decimalTruncation(Int(info.statistic.quantityPrecision)), padding: .none, options: [])) + " \(quoteTokenInfo.symbol)"
                                        }
                                    }
                                } else {
                                    self.priceLabel.text = "≈--"
                                    if isBuy {
                                        self.volLabel.text = R.string.localizable.spotPageBuyable("--")
                                    } else {
                                        self.volLabel.text = R.string.localizable.spotPageSellable("--")
                                    }
                                }

        }).disposed(by: rx.disposeBag)


        Driver.combineLatest(priceTextField.textField.rx.text.asDriver(),
                             volTextField.textField.rx.text.asDriver()).drive(onNext: { [weak self] (price, vol) in
                                guard let `self` = self else { return }
                                let isBuy = self.segmentView.isBuyBehaviorRelay.value

                                var index: Int? = nil
                                if let vm = self.spotViewModelBehaviorRelay.value, let info = self.marketInfoBehaviorRelay.value {

                                    for (i, value) in PercentView.values.enumerated() {
                                        if let v = vol, v != "0", v == type(of: self).calcVol(vm: vm, info: info, priceText: price, isBuy: isBuy, p: value) {
                                            index = i
                                            break
                                        }
                                    }
                                }
                                self.percentView.index = index

                                guard !(price ?? "").isEmpty && !(vol ?? "").isEmpty else {
                                    return
                                }

                                plog(level: .debug, log: "checkAmount price: \(price), vol: \(vol)", tag: .market)

                                if let vm = self.spotViewModelBehaviorRelay.value {
                                    _ = type(of: self).checkAmount(vm: vm, isBuy: isBuy, priceText: price, volText: vol, isShowToast: true)
                                }
        }).disposed(by: rx.disposeBag)

        percentView.changed = { [weak self] index in
            guard let `self` = self else { return }
            guard let text = self.priceTextField.textField.text, let price = BigDecimal(text), price > BigDecimal(0) else {
                self.percentView.index = nil
                return
            }
            let isBuy = self.segmentView.isBuyBehaviorRelay.value

            if let vm = self.spotViewModelBehaviorRelay.value,
                let info = self.marketInfoBehaviorRelay.value,
                let vol = type(of: self).calcVol(vm: vm, info: info, priceText: text, isBuy: isBuy, p: PercentView.values[index]) {
                self.setVol(vol)
            }
        }

        transferButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let isBuy = self.segmentView.isBuyBehaviorRelay.value
            if isBuy {
                guard let tokenInfo = self.spotViewModelBehaviorRelay.value?.quoteTokenInfo else { return }
                let vc = ManageViteXBanlaceViewController(tokenInfo: tokenInfo, autoDismiss: true)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let tokenInfo = self.spotViewModelBehaviorRelay.value?.tradeTokenInfo else { return }
                let vc = ManageViteXBanlaceViewController(tokenInfo: tokenInfo, autoDismiss: true)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }
        }.disposed(by: rx.disposeBag)

        vipButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            if self.spotViewModelBehaviorRelay.value?.vipState ?? false {

                HUD.show()
                self.getDexVipPledge().done {[weak self] (pledge) in
                    guard let `self` = self else { return }

                    if let pledge = pledge {
                        guard Date() > pledge.timestamp else {
                            Toast.show(R.string.localizable.spotPageCloseVipUnExpireErrorToast())
                            return
                        }

                        Workflow.dexCancelVipWithConfirm(account: HDWalletManager.instance.account!, id: pledge.id) { [weak self] (r) in
                            if case .success = r {
                                GCD.delay(3) { [weak self] in
                                    self?.needReFreshVIPStateBehaviorRelay.accept(Void())
                                }
                            }
                        }

                    } else {
                        Toast.show(R.string.localizable.spotPageCloseVipErrorToast())
                        self.needReFreshVIPStateBehaviorRelay.accept(Void())
                    }
                }.catch { (error) in
                    Toast.show(error.localizedDescription)
                }.finally {
                    HUD.hide()
                }

            } else {
                let balance = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: ViteWalletConst.viteToken.id)?.available ?? Amount(0)
                guard balance >= "10000".toAmount(decimals: ViteWalletConst.viteToken.decimals)! else {
                    Toast.show(R.string.localizable.spotPageOpenVipErrorToast())
                    return
                }
                Workflow.dexVipWithConfirm(account: HDWalletManager.instance.account!) { [weak self] (r) in
                    if case .success = r {
                        GCD.delay(3) { [weak self] in
                            self?.needReFreshVIPStateBehaviorRelay.accept(Void())
                        }
                    }
                }
            }
        }.disposed(by: rx.disposeBag)

        buyButton.rx.tap.bind { [weak self] in
            self?.placeOrderAndShowConfirmIfNeeded(isBuy: true)
        }.disposed(by: rx.disposeBag)

        sellButton.rx.tap.bind { [weak self] in
            self?.placeOrderAndShowConfirmIfNeeded(isBuy: false)
        }.disposed(by: rx.disposeBag)
    }


    static func calcAmount(vm: SpotViewModel, priceText: String?, volText: String?) -> BigInt? {
        guard let priceText = priceText, !priceText.isEmpty, let price = BigDecimal(priceText), price > BigDecimal(BigInt(0)) else {
            return nil
        }

        guard let volText = volText, !volText.isEmpty, let vol = BigDecimal(volText), vol > BigDecimal(BigInt(0)) else {
            return nil
        }

        let bigDecimal = (price * vol) * BigDecimal(BigInt(10).power(vm.quoteTokenInfo.decimals))
        let amount = bigDecimal.round()
        return amount
    }

    static func calcFeeRate(vm: SpotViewModel) -> BigDecimal {
        let vipReduceFeeRate: BigDecimal
        if vm.svipState {
            vipReduceFeeRate = BigDecimal("0.002")!
        } else if vm.vipState {
            vipReduceFeeRate = BigDecimal("0.001")!
        } else {
            vipReduceFeeRate = BigDecimal(BigInt(0))
        }

        let baseFeeRate = BigDecimal("0.002")! - vipReduceFeeRate
        let operatorFeeRate = BigDecimal(BigInt(max(vm.dexMarketInfo.takerBrokerFeeRate, vm.dexMarketInfo.makerBrokerFeeRate))) / BigDecimal(BigInt(100000))
        var lockFeeRate = baseFeeRate + operatorFeeRate

        if vm.invited {
            lockFeeRate = lockFeeRate * BigDecimal(BigInt(9)) / BigDecimal(BigInt(10))
        }

        return lockFeeRate
    }

    static func calcFee(vm: SpotViewModel, amount: Amount) -> Amount {
        let feeRate = calcFeeRate(vm: vm)
        let feeBigDecimal = BigDecimal(amount) * feeRate
        let fee = feeBigDecimal.round()
        plog(level: .debug, log: "calcFee amount: \(amount.description), rate: \(feeRate.description), fee: \(fee.description)", tag: .market)
        return fee
    }

    static func calcVol(vm: SpotViewModel, info: MarketInfo, priceText: String?, isBuy: Bool, p: Double) -> String? {
        guard p >= 0, p <= 1 else { return nil }
        let quoteTokenInfo = vm.quoteTokenInfo
        let tradeTokenInfo = vm.tradeTokenInfo
        let tradeToken = tradeTokenInfo.toViteToken()!
        let quoteToken = quoteTokenInfo.toViteToken()!
        let percent = BigDecimal("\(p)")!
        let decimals = min(Int(info.statistic.quantityPrecision), tradeTokenInfo.decimals)

        if isBuy {
            guard let priceText = priceText, let price = BigDecimal(priceText), price > BigDecimal(0) else {
                return nil
            }
            let feeRate = calcFeeRate(vm: vm)
            let multiple = BigDecimal(BigInt(1)) + feeRate
            let balance = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: quoteToken.id)?.available ?? Amount()

            guard balance > 0 else {
                return "0"
            }

            let allVol = BigDecimal(balance.amount(decimals: quoteToken.decimals, count: quoteToken.decimals, groupSeparator: false))! / (multiple * price)
            let vol = allVol * percent

            var volText = BigDecimalFormatter.format(bigDecimal: vol, style: .decimalTruncation(decimals), padding: .none, options: [])

            while checkAmount(vm: vm, isBuy: true, priceText: priceText, volText: volText, isShowToast: false).isBalanceInsufficient {
                let newVol = BigDecimal(volText)! - BigDecimal(number: BigInt(1), digits: Int(info.statistic.quantityPrecision))
                guard newVol > BigDecimal(BigInt(0)) else {
                    return "0"
                }
                volText = BigDecimalFormatter.format(bigDecimal: newVol, style: .decimalTruncation(decimals), padding: .none, options: [])
            }

            return volText
        } else {
            let balance = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: tradeToken.id)?.available ?? Amount()
            let volText = BigDecimalFormatter.format(bigDecimal: BigDecimal(balance) * percent / BigDecimal(BigInt(10).power(tradeTokenInfo.decimals)), style: .decimalTruncation(decimals), padding: .none, options: [])
            return volText
        }
    }

    enum CheckAmountResult {
        case success
        case calcAmountFailed
        case volError
        case totalInsufficient
        case balanceInsufficient

        var isSuccess: Bool {
            switch self {
            case .success:
                return true
            case .calcAmountFailed, .volError, .totalInsufficient, .balanceInsufficient:
                return false
            }
        }

        var isBalanceInsufficient: Bool {
            switch self {
            case .balanceInsufficient:
                return true
            case .success, .calcAmountFailed, .volError, .totalInsufficient:
                return false
            }
        }
    }

    static func checkAmount(vm: SpotViewModel, isBuy: Bool, priceText: String?, volText: String?, isShowToast: Bool) -> CheckAmountResult {
        plog(level: .debug, log: "price: \(priceText ?? "") vol: \(volText ?? "")", tag: .market)
        guard let amount = calcAmount(vm: vm, priceText: priceText, volText: volText) else { return .calcAmountFailed }
        let fee = calcFee(vm: vm, amount: amount)

        let minAmount = MarketInfoService.shared.marketLimit.getMinAmount(quoteTokenSymbol: vm.quoteTokenInfo.uniqueSymbol)

        if isBuy {
            let total = amount + fee
            guard total >= minAmount else {
                let text = minAmount.amount(decimals: vm.quoteTokenInfo.decimals, count: vm.quoteTokenInfo.decimals, groupSeparator: true) + " " + vm.quoteTokenInfo.symbol
                if isShowToast { Toast.show(R.string.localizable.spotPagePostToastAmountMin(text)) }
                return .totalInsufficient
            }

            let balance = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: vm.quoteTokenInfo.viteTokenId)?.available ?? Amount()

            guard total <= balance else {
                if isShowToast { Toast.show(R.string.localizable.sendPageToastAmountError()) }
                return .balanceInsufficient
            }

            return .success
        } else {
            let total = amount
            guard total >= minAmount else {
                let text = minAmount.amount(decimals: vm.quoteTokenInfo.decimals, count: vm.quoteTokenInfo.decimals, groupSeparator: true) + " " + vm.quoteTokenInfo.symbol
                if isShowToast { Toast.show(R.string.localizable.spotPagePostToastAmountMin(text)) }
                return .totalInsufficient
            }

            guard let volText = volText, !volText.isEmpty, let vol = volText.toAmount(decimals: vm.tradeTokenInfo.decimals) else {
                return .volError
            }

            let balance = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: vm.tradeTokenInfo.viteTokenId)?.available ?? Amount()

            guard vol <= balance else {
                if isShowToast { Toast.show(R.string.localizable.sendPageToastAmountError()) }
                return .balanceInsufficient
            }

            return .success
        }
    }

    func getDexVipPledge() ->Promise<Pledge?> {
        let address = HDWalletManager.instance.account!.address
        return ViteNode.dex.info.getDexVIPStakeInfoList(address: address, index: 0, count: 100)
            .then { pledgeDetail -> Promise<Pledge?> in
                for pledge in pledgeDetail.list where pledge.bid == 2 {
                    return Promise.value(pledge)
                }
                return ViteNode.dex.info.getDexVIPStakeInfoList(address: address, index: 0, count: Int(pledgeDetail.totalCount))
                    .then { pledgeDetail -> Promise<Pledge?> in
                        for pledge in pledgeDetail.list where pledge.bid == 2 {
                            return Promise.value(pledge)
                        }
                        return Promise.value(nil)
                }
        }
    }

    func setPrice(_ text: String) {
        priceTextField.textField.text = text
        priceTextField.textField.sendActions(for: .valueChanged)
    }

    func setVol(_ text: String) {
        volTextField.textField.text = text
        volTextField.textField.sendActions(for: .valueChanged)
    }

    func setVol(_ num: Double) {
        guard let info = self.marketInfoBehaviorRelay.value else { return }
        guard let vm = self.spotViewModelBehaviorRelay.value else { return }
        let tradeTokenInfo = vm.tradeTokenInfo
        let decimals = min(Int(info.statistic.quantityPrecision), tradeTokenInfo.decimals)
        let text = String(format: "%.\(decimals)f", num)

        if let vm = self.spotViewModelBehaviorRelay.value,
            let info = self.marketInfoBehaviorRelay.value,
            let priceText = self.priceTextField.textField.text,
            let maxString = type(of: self).calcVol(vm: vm, info: info, priceText: priceText, isBuy: self.segmentView.isBuyBehaviorRelay.value, p: 1),
            let max = Double(maxString),
            num > max {
            setVol(maxString)
        } else {
            setVol(text)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    let marketInfoBehaviorRelay: BehaviorRelay<MarketInfo?> = BehaviorRelay(value: nil)
    let spotViewModelBehaviorRelay: BehaviorRelay<SpotViewModel?> = BehaviorRelay(value: nil)
    let needReFreshVIPStateBehaviorRelay: BehaviorRelay<Void?> = BehaviorRelay(value: nil)

    func bind(marketInfo: MarketInfo?) {
        marketInfoBehaviorRelay.accept(marketInfo)
        self.setVol("")
        self.setPrice(marketInfo?.statistic.closePrice ?? "")
    }

    func bind(spotViewModel: SpotViewModel?) {
        let showAlertIfNeeded = self.lastSymbol != spotViewModel?.dexMarketInfo.marketSymbol
        if let symbol = spotViewModel?.dexMarketInfo.marketSymbol, !symbol.isEmpty {
            self.lastSymbol = symbol
        }

        self.spotViewModelBehaviorRelay.accept(spotViewModel)

        if let vm = spotViewModel, vm.level <= 0, showAlertIfNeeded {
            Alert.show(title: R.string.localizable.spotPageAlertTitle(),
                       message: R.string.localizable.spotPageAlertMessage("\(vm.tradeTokenInfo.uniqueSymbol)/\(vm.quoteTokenInfo.uniqueSymbol)"),
                       actions: [(.default(title: R.string.localizable.spotPageAlertOk()), nil)]
            )
        }
    }
}

extension SpotOperationView: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let info = marketInfoBehaviorRelay.value else {
            return false
        }

        if textField == priceTextField.textField {
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: Int(info.statistic.pricePrecision))
            textField.text = text
            return ret
        } else if textField == volTextField.textField {
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: Int(info.statistic.quantityPrecision))
            textField.text = text
            return ret
        } else {
            return true
        }
    }
}


extension SpotOperationView {

    class SegmentView: UIView {

        let buyButton = UIButton().then {
            $0.setTitle(R.string.localizable.spotPageButtonBuyTitle(), for: .normal)
            $0.layer.cornerRadius = 2
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            $0.setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0x01D764)).resizable, for: .disabled)
            $0.setTitleColor(.white, for: .disabled)
            $0.setBackgroundImage(nil, for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.7), for: .normal)
        }

        let sellButton = UIButton().then {
            $0.setTitle(R.string.localizable.spotPageButtonSellTitle(), for: .normal)
            $0.layer.cornerRadius = 2
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            $0.setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xE5494D)).resizable, for: .disabled)
            $0.setTitleColor(.white, for: .disabled)
            $0.setBackgroundImage(nil, for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.7), for: .normal)
        }

        let isBuyBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: true)

        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.cornerRadius = 2
            backgroundColor = UIColor(netHex: 0xF3F5F9)

            addSubview(buyButton)
            addSubview(sellButton)

            buyButton.snp.makeConstraints { (m) in
                m.top.bottom.left.equalToSuperview()
                m.height.equalTo(30)
            }

            sellButton.snp.makeConstraints { (m) in
                m.top.bottom.right.equalToSuperview()
                m.left.equalTo(buyButton.snp.right)
                m.width.equalTo(buyButton)
            }

            isBuyBehaviorRelay.bind { [weak self] isBuy in
                guard let `self` = self else { return }
                self.buyButton.isEnabled = !isBuy
                self.sellButton.isEnabled = isBuy
            }.disposed(by: rx.disposeBag)

            buyButton.rx.tap.bind { [weak self] in
                self?.isBuyBehaviorRelay.accept(true)
            }.disposed(by: rx.disposeBag)

            sellButton.rx.tap.bind { [weak self] in
                self?.isBuyBehaviorRelay.accept(false)
            }.disposed(by: rx.disposeBag)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class TextFieldView: UIView {

        let textField = UITextField().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(netHex: 0x24272B)
            $0.keyboardType = .decimalPad
        }

        let subButton = UIButton().then {
            $0.setImage(R.image.icon_spot_sub(), for: .normal)
        }

        let addButton = UIButton().then {
            $0.setImage(R.image.icon_spot_add(), for: .normal)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.cornerRadius = 2
            layer.borderColor = UIColor(netHex: 0xD3DFEF).cgColor
            layer.borderWidth = CGFloat.singleLineWidth

            let sline = UIView().then {
                $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
            }

            let aline = UIView().then {
                $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
            }

            addSubview(textField)
            addSubview(subButton)
            addSubview(addButton)
            addSubview(sline)
            addSubview(aline)

            subButton.snp.makeConstraints { (m) in
                m.size.equalTo(CGSize(width: 38, height: 38))
                m.left.top.bottom.equalToSuperview()
            }

            addButton.snp.makeConstraints { (m) in
                m.size.equalTo(CGSize(width: 38, height: 38))
                m.right.top.bottom.equalToSuperview()
            }

            textField.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.equalTo(subButton.snp.right).offset(5)
                m.right.equalTo(addButton.snp.left).offset(-5)
            }

            sline.snp.makeConstraints { (m) in
                m.width.equalTo(CGFloat.singleLineWidth)
                m.right.top.bottom.equalTo(subButton)
            }

            aline.snp.makeConstraints { (m) in
                m.width.equalTo(CGFloat.singleLineWidth)
                m.left.top.bottom.equalTo(addButton)
            }

        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class BubbleView: UIView {

        let leftView = UIImageView(image: R.image.icon_spot_bubble_left()?.resizable)
        let centerView = UIImageView(image: R.image.icon_spot_bubble_center()?.resizable)
        let rightView = UIImageView(image: R.image.icon_spot_bubble_right()?.resizable)
        let textLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.numberOfLines = 0
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(leftView)
            addSubview(centerView)
            addSubview(rightView)
            addSubview(textLabel)

            leftView.snp.makeConstraints { (m) in
                m.top.left.bottom.equalToSuperview()
            }

            rightView.snp.makeConstraints { (m) in
                m.top.right.bottom.equalToSuperview()
                m.width.equalTo(leftView)
            }

            centerView.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.equalTo(leftView.snp.right)
                m.right.equalTo(rightView.snp.left)
                m.width.equalTo(15)
            }

            textLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(10)
                m.left.equalToSuperview().offset(15)
                m.bottom.equalToSuperview().offset(-18)
                m.right.equalToSuperview().offset(-15)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class PercentView: UIView {

        static var values: [Double] = [
            0.25,
            0.5,
            0.75,
            1
        ]

        let buttons = PercentView.values.map {
            makeSegmentButton(title: String(format: "%.0f%%", $0 * 100))
        }

        var changed: ((Int) -> Void)?

        var index: Int? = nil {
            didSet {
                self.updateState()
            }
        }


        override init(frame: CGRect) {
            super.init(frame: frame)

            for (index, button) in buttons.enumerated() {
                addSubview(button)
                button.snp.makeConstraints { (m) in
                    m.top.equalToSuperview()
                    m.bottom.equalToSuperview()
                    if index == 0 {
                        m.left.equalToSuperview()
                    } else {
                        m.left.equalTo(buttons[index - 1].snp.right).offset(4)
                        m.width.equalTo(buttons[index - 1])
                    }

                    if index == buttons.count - 1 {
                        m.right.equalToSuperview()
                    }
                }

                button.rx.tap.bind { [weak self] in
                    guard let `self` = self else { return }
                    self.index = index
                    self.changed?(index)
                }.disposed(by: rx.disposeBag)
            }
            updateState()
        }

        func updateState() {
            for (i, b) in self.buttons.enumerated() {
                b.isEnabled = (self.index != i)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        static func makeSegmentButton(title: String) -> UIButton {
            let ret = UIButton()
            ret.setTitle(title, for: .normal)
            ret.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            ret.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.45), for: .normal)
            ret.setTitleColor(UIColor(netHex: 0x007AFF), for: .disabled)
            ret.setBackgroundImage(R.image.icon_trading_segment_unselected_fram()?.resizable, for: .normal)
            ret.setBackgroundImage(R.image.icon_trading_segment_selected_fram()?.resizable, for: .disabled)
            return ret
        }
    }

    class ConfirmView: UIView {
        let priceTitleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.text = R.string.localizable.spotPageDepthPrice()
        }

        let priceValueLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x007AFF, alpha: 0.7)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }

        let priceBgView = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0x007AFF, alpha: 0.06)
        }

        let volTitleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.text = R.string.localizable.spotPageDepthVol()
        }

        let volValueLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x007AFF, alpha: 0.7)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }

        let checkButton = BackupMnemonicViewController.ConfirmView().then { view in
            view.label.text = R.string.localizable.spotPageConfirmTip()
            let customType = ActiveType.custom(pattern: view.label.text!)
            view.label.enabledTypes = [customType]
            view.label.customize { [weak view] label in
                label.customColor[customType] = view?.label.textColor
                label.customSelectedColor[customType] = view?.label.textColor
                label.handleCustomTap(for: customType) { [weak view] element in
                    view?.checkButton.isSelected = !(view?.checkButton.isSelected ?? true)
                }
            }
        }

        init(price: String, vol: String) {
            super.init(frame: .zero)

            priceValueLabel.text = price
            volValueLabel.text = vol

            addSubview(priceBgView)
            addSubview(priceTitleLabel)
            addSubview(priceValueLabel)
            addSubview(volTitleLabel)
            addSubview(volValueLabel)
            addSubview(checkButton)

            priceBgView.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(16)
                m.left.right.equalToSuperview()
                m.height.equalTo(50)
            }

            priceTitleLabel.snp.makeConstraints { (m) in
                m.left.equalToSuperview().offset(15)
                m.centerY.equalTo(priceBgView)
            }

            priceValueLabel.snp.makeConstraints { (m) in
                m.right.equalToSuperview().offset(-15)
                m.centerY.equalTo(priceBgView)
            }

            volTitleLabel.snp.makeConstraints { (m) in
                m.top.equalTo(priceBgView.snp.bottom).offset(16)
                m.left.equalToSuperview().offset(15)
            }

            volValueLabel.snp.makeConstraints { (m) in
                m.right.equalToSuperview().offset(-15)
                m.centerY.equalTo(volTitleLabel)
            }

            checkButton.snp.makeConstraints { (m) in
                m.top.equalTo(volTitleLabel.snp.bottom).offset(28)
                m.left.right.equalToSuperview().inset(15)
                m.bottom.equalToSuperview().offset(-12)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// Call Contract
extension SpotOperationView {

    func placeOrderAndShowConfirmIfNeeded(isBuy: Bool) {

        guard let vm = self.spotViewModelBehaviorRelay.value else { return }

        let quoteTokenInfo = vm.quoteTokenInfo
        let tradeTokenInfo = vm.tradeTokenInfo

        self.endEditing(true)

        guard let priceText = self.priceTextField.textField.text, !priceText.isEmpty, let price = BigDecimal(priceText) else {
            Toast.show(R.string.localizable.spotPagePostToastPriceEmpty())
            return
        }

        guard let volText = self.volTextField.textField.text, !volText.isEmpty, let vol = volText.toAmount(decimals: tradeTokenInfo.decimals) else {
            Toast.show(R.string.localizable.spotPagePostToastVolEmpty())
            return
        }

        if isBuy {
            guard price > BigDecimal(0) else {
                Toast.show(R.string.localizable.spotPagePostToastPriceZero())
                return
            }

            guard vol > Amount(0) else {
                Toast.show(R.string.localizable.spotPagePostToastVolZero())
                return
            }

            guard type(of: self).checkAmount(vm: vm, isBuy: true, priceText: priceText, volText: volText, isShowToast: true).isSuccess else {
                return
            }


            let block = {
                Workflow.dexBuyWithConfirm(account: HDWalletManager.instance.account!,
                                           tradeTokenInfo: tradeTokenInfo,
                                           quoteTokenInfo: quoteTokenInfo,
                                           price: priceText,
                                           quantity: vol,
                                           completion: { [weak self] ret in
                                            switch ret {
                                            case .success:
                                                self?.setVol("")
                                            case .failure:
                                                break
                                            }
                })
            }

            if WalletManager.setting.isNeedConfirmForPlaceOrder() {
                let title = "\(R.string.localizable.spotPageButtonBuyTitle()) \(tradeTokenInfo.symbol)"
                let confirmView = ConfirmView(price: "\(priceText) \(quoteTokenInfo.symbol)", vol: "\(volText) \(tradeTokenInfo.symbol)")
                Alert.show(title: title, message: nil, customView: confirmView, actions: [
                    (.cancel, nil),
                    (.default(title: R.string.localizable.confirm()), { _ in
                        if confirmView.checkButton.checkButton.isSelected {
                            WalletManager.setting.updatePlaceOrderConfirmExpireTimestamp()
                        }
                        block()
                    }),
                ])
            } else {
                block()
            }
        } else {
            guard price != BigDecimal(0) else {
                Toast.show(R.string.localizable.spotPagePostToastPriceZero())
                return
            }

            guard vol != Amount(0) else {
                Toast.show(R.string.localizable.spotPagePostToastVolZero())
                return
            }

            guard type(of: self).checkAmount(vm: vm, isBuy: false, priceText: priceText, volText: volText, isShowToast: true).isSuccess else {
                return
            }

            let block = {
                Workflow.dexSellWithConfirm(account: HDWalletManager.instance.account!,
                                            tradeTokenInfo: tradeTokenInfo,
                                            quoteTokenInfo: quoteTokenInfo,
                                            price: priceText,
                                            quantity: vol,
                                            completion: { [weak self] ret in
                                                switch ret {
                                                case .success:
                                                    self?.setVol("")
                                                case .failure:
                                                    break
                                                }
                })
            }

            if WalletManager.setting.isNeedConfirmForPlaceOrder() {
                let title = "\(R.string.localizable.spotPageButtonSellTitle()) \(tradeTokenInfo.symbol)"
                let confirmView = ConfirmView(price: "\(priceText) \(quoteTokenInfo.symbol)", vol: "\(volText) \(tradeTokenInfo.symbol)")
                Alert.show(title: title, message: nil, customView: confirmView, actions: [
                    (.cancel, nil),
                    (.default(title: R.string.localizable.confirm()), { _ in
                        if confirmView.checkButton.checkButton.isSelected {
                            WalletManager.setting.updatePlaceOrderConfirmExpireTimestamp()
                        }
                        block()
                    }),
                ])
            } else {
                block()
            }
        }

    }
}
