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

class SpotOperationView: UIView {

    static let height: CGFloat = 303

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
            m.centerY.equalTo(amountLabel)
            m.right.equalTo(percentView)
            m.width.equalTo(37)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.top.equalTo(percentView.snp.bottom).offset(12)
            m.left.equalToSuperview()
            m.right.equalTo(transferButton.snp.left)
        }

        volLabel.snp.makeConstraints { (m) in
            m.top.equalTo(amountLabel.snp.bottom).offset(4)
            m.left.right.equalToSuperview()
        }

        vipButton.snp.makeConstraints { (m) in
            m.top.equalTo(volLabel.snp.bottom).offset(4)
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
            self.setPrice(self.marketInfoBehaviorRelay.value?.statistic.closePrice ?? "")
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
                             segmentView.isBuyBehaviorRelay.asDriver()).drive(onNext: { [weak self] (balanceMap, info, spotViewModel, priceText, isBuy) in
                                guard let `self` = self else { return }

                                let quoteTokenInfo = spotViewModel.quoteTokenInfo
                                let tradeTokenInfo = spotViewModel.tradeTokenInfo
                                let sourceTokenInfo = isBuy ? quoteTokenInfo : tradeTokenInfo

                                let sourceToken = sourceTokenInfo.toViteToken()!
                                let balance = balanceMap[sourceToken.id]?.available ?? Amount()
                                self.amountLabel.text = R.string.localizable.spotPageAvailable(balance.amountFullWithGroupSeparator(decimals: sourceToken.decimals)) + " \(sourceTokenInfo.symbol)"

                                if let text = priceText, let price = BigDecimal(text), price != BigDecimal(0) {
                                    self.priceLabel.text = "≈" + MarketInfoService.shared.legalPrice(quoteTokenSymbol: quoteTokenInfo.uniqueSymbol, price: text)
                                    if isBuy {
                                        self.volLabel.text = R.string.localizable.spotPageBuyable(self.calcVol(p: 1) ?? "--") + " \(tradeTokenInfo.symbol)"
                                    } else {
                                        let vol = BigDecimal(balance.amountFull(decimals: sourceToken.decimals))! * price
                                        self.volLabel.text = R.string.localizable.spotPageSellable(BigDecimalFormatter.format(bigDecimal: vol, style: .decimalTruncation(Int(info.statistic.quantityPrecision)), padding: .none, options: [.groupSeparator])) + " \(quoteTokenInfo.symbol)"
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
                                self.percentView.index = nil

                                guard !(price ?? "").isEmpty && !(vol ?? "").isEmpty else {
                                    return
                                }

                                _ = self.checkAmount()
        }).disposed(by: rx.disposeBag)

        percentView.changed = { [weak self] index in
            guard let `self` = self else { return }
            guard let text = self.priceTextField.textField.text, let price = BigDecimal(text), price > BigDecimal(0) else {
                self.percentView.index = nil
                return
            }

            guard let vol = self.calcVol(p: PercentView.values[index]) else { return }
            self.volTextField.textField.text = vol
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
            guard let `self` = self else { return }
            guard let vm = self.spotViewModelBehaviorRelay.value else { return }

            let quoteTokenInfo = vm.quoteTokenInfo
            let tradeTokenInfo = vm.tradeTokenInfo

            guard let priceText = self.priceTextField.textField.text, !priceText.isEmpty, let price = BigDecimal(priceText) else {
                Toast.show(R.string.localizable.spotPagePostToastPriceEmpty())
                return
            }

            guard let volText = self.volTextField.textField.text, !volText.isEmpty, let vol = volText.toAmount(decimals: tradeTokenInfo.decimals) else {
                Toast.show(R.string.localizable.spotPagePostToastVolEmpty())
                return
            }

            guard price > BigDecimal(0) else {
                Toast.show(R.string.localizable.spotPagePostToastPriceZero())
                return
            }

            guard vol > Amount(0) else {
                Toast.show(R.string.localizable.spotPagePostToastVolZero())
                return
            }

            guard self.checkAmount() else {
                return
            }

            self.endEditing(true)

            Workflow.dexBuyWithConfirm(account: HDWalletManager.instance.account!,
                                       tradeTokenInfo: tradeTokenInfo,
                                       quoteTokenInfo: quoteTokenInfo,
                                       price: priceText,
                                       quantity: vol,
                                       completion: { _ in })

        }.disposed(by: rx.disposeBag)

        sellButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            guard let vm = self.spotViewModelBehaviorRelay.value else { return }
            let quoteTokenInfo = vm.quoteTokenInfo
            let tradeTokenInfo = vm.tradeTokenInfo

            guard let priceText = self.priceTextField.textField.text, !priceText.isEmpty, let price = BigDecimal(priceText) else {
                Toast.show(R.string.localizable.spotPagePostToastPriceEmpty())
                return
            }

            guard let volText = self.volTextField.textField.text, !volText.isEmpty, let vol = volText.toAmount(decimals: tradeTokenInfo.decimals) else {
                Toast.show(R.string.localizable.spotPagePostToastVolEmpty())
                return
            }

            guard price != BigDecimal(0) else {
                Toast.show(R.string.localizable.spotPagePostToastPriceZero())
                return
            }

            guard vol != Amount(0) else {
                Toast.show(R.string.localizable.spotPagePostToastVolZero())
                return
            }

            guard self.checkAmount() else {
                return
            }

            self.endEditing(true)

            Workflow.dexSellWithConfirm(account: HDWalletManager.instance.account!,
                                        tradeTokenInfo: tradeTokenInfo,
                                        quoteTokenInfo: quoteTokenInfo,
                                        price: priceText,
                                        quantity: vol,
                                        completion: { _ in })
        }.disposed(by: rx.disposeBag)
    }

    func calcQuoteBigDecimal() -> BigDecimal? {
        guard let priceText = self.priceTextField.textField.text, !priceText.isEmpty, let price = BigDecimal(priceText) else {
            return nil
        }

        guard let volText = self.volTextField.textField.text, !volText.isEmpty, let vol = BigDecimal(volText) else {
            return nil
        }

        let bigDecimal = price * vol
        return bigDecimal
    }

    func calcFeeRate() -> BigDecimal? {
        guard let vm = self.spotViewModelBehaviorRelay.value else {
             return nil
        }

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

    func calcFee() -> (amount: Amount, fee: Amount)? {
        guard let quoteBigDecimal = calcQuoteBigDecimal() else {
            return nil
        }

        guard let feeRate = calcFeeRate() else {
            return nil
        }

        guard let vm = self.spotViewModelBehaviorRelay.value else {
             return nil
        }

        let quote = quoteBigDecimal * BigDecimal(BigInt(10).power(vm.quoteTokenInfo.decimals))
        let feeBigDecimal = quote * feeRate
        let amount = quote.ceil()
        let fee = feeBigDecimal.ceil()

        plog(level: .debug, log: "calcFee quote: \(quoteBigDecimal.description), rate: \(feeRate.description), fee: \((quoteBigDecimal * feeRate).description)", tag: .market)
        return (amount, fee)
    }

    func checkAmount() -> Bool {
        guard let (amount, fee) = calcFee() else {
            return false
        }

        guard let vm = self.spotViewModelBehaviorRelay.value else {
             return false
        }

        if self.segmentView.isBuyBehaviorRelay.value {
            let minAmount = MarketInfoService.shared.marketLimit.getMinAmount(quoteTokenSymbol: vm.quoteTokenInfo.uniqueSymbol)
            let total = amount + fee
            guard total >= minAmount else {
                Toast.show(R.string.localizable.spotPagePostToastAmountMin())
                return false
            }

            let balance = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: vm.quoteTokenInfo.viteTokenId)?.available ?? Amount()

            guard total <= balance else {
                Toast.show(R.string.localizable.sendPageToastAmountError())
                return false
            }

            return true

        } else {
            let minAmount = MarketInfoService.shared.marketLimit.getMinAmount(quoteTokenSymbol: vm.quoteTokenInfo.uniqueSymbol)
            let total = amount
            guard total >= minAmount else {
                Toast.show(R.string.localizable.spotPagePostToastAmountMin())
                return false
            }

            let balance = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: vm.tradeTokenInfo.viteTokenId)?.available ?? Amount()

            guard let volText = self.volTextField.textField.text, !volText.isEmpty,
                let vol = volText.toAmount(decimals: vm.tradeTokenInfo.decimals) else {
                return false
            }

            guard vol <= balance else {
                Toast.show(R.string.localizable.sendPageToastAmountError())
                return false
            }

            return true
        }
    }

    func calcVol(p: Double) -> String? {
        guard p >= 0, p <= 1 else { return nil }
        guard let info = self.marketInfoBehaviorRelay.value else { return nil }
        guard let vm = self.spotViewModelBehaviorRelay.value else { return nil }

        let isBuy = self.segmentView.isBuyBehaviorRelay.value
        let quoteTokenInfo = vm.quoteTokenInfo
        let tradeTokenInfo = vm.tradeTokenInfo
        let tradeToken = tradeTokenInfo.toViteToken()!
        let quoteToken = quoteTokenInfo.toViteToken()!
        let percent = BigDecimal("\(p)")!
        let decimals = min(Int(info.statistic.quantityPrecision), tradeTokenInfo.decimals)

        if isBuy {
            guard let text = self.priceTextField.textField.text,
                let price = BigDecimal(text), price > BigDecimal(0) else {
                return nil
            }

             guard let feeRate = calcFeeRate() else { return nil }

            let balance = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: quoteToken.id)?.available ?? Amount()
            let multiple = BigDecimal(BigInt(1)) + feeRate
            let vol = BigDecimal(balance.amountFull(decimals: quoteToken.decimals))! / (multiple * price)
            return BigDecimalFormatter.format(bigDecimal: vol * percent, style: .decimalTruncation(decimals), padding: .none, options: [])
        } else {
            let balance = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: tradeToken.id)?.available ?? Amount()
            return BigDecimalFormatter.format(bigDecimal: BigDecimal(balance) * percent / BigDecimal(BigInt(10).power(tradeTokenInfo.decimals)), style: .decimalTruncation(decimals), padding: .none, options: [])
        }
    }

    func getDexVipPledge() ->Promise<Pledge?> {
        let address = HDWalletManager.instance.account!.address
        return ViteNode.dex.info.getDexVIPStakeInfoListRequest(address: address, index: 0, count: 100)
            .then { pledgeDetail -> Promise<Pledge?> in
                for pledge in pledgeDetail.list where pledge.bid == 2 {
                    return Promise.value(pledge)
                }
                return ViteNode.dex.info.getDexVIPStakeInfoListRequest(address: address, index: 0, count: Int(pledgeDetail.totalCount))
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
        setVol(text)
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
        self.spotViewModelBehaviorRelay.accept(spotViewModel)

        if let vm = spotViewModel, vm.level <= 0 {
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
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.keyboardType = .decimalPad
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.cornerRadius = 2
            layer.borderColor = UIColor(netHex: 0xD3DFEF).cgColor
            layer.borderWidth = CGFloat.singleLineWidth

            addSubview(textField)

            textField.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.right.equalToSuperview().inset(10)
                m.height.equalTo(30)
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
}
