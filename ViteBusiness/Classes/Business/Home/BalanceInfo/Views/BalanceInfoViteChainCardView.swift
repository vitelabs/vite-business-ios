//
//  BalanceInfoViteChainCardView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/2/28.
//

import UIKit
import NSObject_Rx
import RxSwift
import RxCocoa
import ViteWallet

class BalanceInfoViteChainCardView: UIView {

    let addressButton = UIButton().then {
        $0.setBackgroundImage(nil, for: .normal)
        $0.setBackgroundImage(UIImage.color(UIColor.white.withAlphaComponent(0.2)), for: .highlighted)
    }
    let balanceView = UIView()

    let onroadView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.14)
        $0.isHidden = true
    }

    let buttonView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        $0.layer.shadowOpacity = 1
        $0.layer.shadowOffset = CGSize(width: 0, height: -2)
        $0.layer.shadowRadius = 2
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 188)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        layer.cornerRadius = 2

        setupAddressView()
        setupBalanceView()

        setupButtonView()
        setupOnroadView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupAddressView() {
        let nameImageView = UIImageView(image: R.image.icon_address_name())
        let nameLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.textColor = UIColor.white
            $0.numberOfLines = 1
        }
        let addressLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.textColor = UIColor.white.withAlphaComponent(0.7)
            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingMiddle
        }
        let arrowsImageView = UIImageView(image: R.image.icon_balance_detail_arrows())
        let lineImageView = UIImageView(image: R.image.dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

        addSubview(addressButton)
        addressButton.addSubview(nameImageView)
        addressButton.addSubview(nameLabel)
        addressButton.addSubview(addressLabel)
        addressButton.addSubview(arrowsImageView)
        addressButton.addSubview(lineImageView)

        addressButton.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
            m.height.equalTo(45)
        }

        nameImageView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(14)
            m.centerY.equalToSuperview()
            m.size.equalTo(CGSize(width: 12, height: 12))
        }

        nameLabel.snp.makeConstraints { (m) in
            m.left.equalTo(nameImageView.snp.right).offset(7)
            m.centerY.equalToSuperview()
        }

        addressLabel.snp.makeConstraints { (m) in
            m.left.equalTo(nameLabel.snp.right).offset(6)
            m.centerY.equalToSuperview()
        }

        arrowsImageView.snp.makeConstraints { (m) in
            m.left.equalTo(addressLabel.snp.right).offset(10)
            m.centerY.equalToSuperview()
            m.right.equalToSuperview().offset(-14)
            m.size.equalTo(CGSize(width: 20, height: 20))
        }

        lineImageView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
        }

        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addressButton.rx.tap.bind {
            UIViewController.current?.navigationController?.pushViewController(AddressManageViewController(), animated: true)
            }.disposed(by: rx.disposeBag)

        Observable.combineLatest(
            HDWalletManager.instance.accountDriver.filterNil().asObservable(),
            AddressManageService.instance.myAddressNameMapDriver.asObservable())
            .bind { (account, _) in
                nameLabel.text = AddressManageService.instance.name(for: account.address)
                addressLabel.text = account.address.description
            }.disposed(by: rx.disposeBag)
    }

    func setupBalanceView() {
        balanceLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            $0.textColor = UIColor.white
            $0.numberOfLines = 1
        }

        priceLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor.white
            $0.numberOfLines = 1
        }

        quotaLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.textColor = UIColor.white.withAlphaComponent(0.7)
            $0.numberOfLines = 1
        }

        addSubview(balanceView)
        balanceView.addSubview(balanceLabel)
        balanceView.addSubview(priceLabel)
        balanceView.addSubview(quotaLabel)

        balanceView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.equalTo(addressButton.snp.bottom)
            m.height.equalTo(80)
        }

        balanceLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(15)
            m.left.equalToSuperview().offset(14)
            m.right.equalToSuperview().offset(-14)
        }

        priceLabel.snp.makeConstraints { (m) in
            m.top.equalTo(balanceLabel.snp.bottom).offset(14)
            m.left.equalToSuperview().offset(14)
        }

        quotaLabel.snp.makeConstraints { (m) in
            m.top.equalTo(balanceLabel.snp.bottom).offset(14)
            m.left.equalTo(priceLabel.snp.right).offset(10)
            m.right.equalToSuperview().offset(-14)
        }

        priceLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        quotaLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    func setupOnroadView() {

        onroadLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 11, weight: .regular)
            $0.textColor = UIColor.white.withAlphaComponent(0.7)
            $0.numberOfLines = 1
        }

        addSubview(onroadView)
        onroadView.addSubview(onroadLabel)

        onroadView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalTo(buttonView.snp.top)
            m.height.equalTo(18)
        }

        onroadLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(14)
            m.right.equalToSuperview().offset(-14)
            m.centerY.equalToSuperview()
        }
    }

    func setupButtonView() {

        receiveButton = UIButton().then {
            $0.setTitle(R.string.localizable.balanceInfoDetailReveiceButtonTitle(), for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.setTitleColor(UIColor.white.highlighted, for: .highlighted)
        }

        sendButton = UIButton().then {
            $0.setTitle(R.string.localizable.balanceInfoDetailSendButtonTitle(), for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.setTitleColor(UIColor.white.highlighted, for: .highlighted)
        }

        let vLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xffffff, alpha: 0.15)
        }

        addSubview(buttonView)
        buttonView.addSubview(receiveButton)
        buttonView.addSubview(sendButton)
        buttonView.addSubview(vLine)

        buttonView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.height.equalTo(44)
        }

        receiveButton.snp.makeConstraints { (m) in
            m.top.left.bottom.equalToSuperview()
        }

        sendButton.snp.makeConstraints { (m) in
            m.top.right.bottom.equalToSuperview()
            m.left.equalTo(receiveButton.snp.right)
            m.width.equalTo(receiveButton)
        }

        vLine.snp.makeConstraints { (m) in
            m.width.equalTo(CGFloat.singleLineWidth)
            m.centerX.equalToSuperview()
            m.top.equalToSuperview().offset(7)
            m.bottom.equalToSuperview().offset(-7)
        }
    }

    var balanceLabel: UILabel!
    var receiveButton: UIButton!
    var sendButton: UIButton!
    var onroadLabel: UILabel!
    var priceLabel: UILabel!
    var quotaLabel: UILabel!

    func bind(tokenInfo: TokenInfo) {
        guard let token = tokenInfo.toViteToken() else { return }

        Driver.combineLatest(
            ExchangeRateManager.instance.rateMapDriver,
            ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: tokenInfo.viteTokenId).filterNil()).map({ (map, balanceInfo) -> String in
                "≈" + map.priceString(for: balanceInfo.tokenInfo, balance: balanceInfo.balance)
            }).drive(priceLabel.rx.text).disposed(by: rx.disposeBag)

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: tokenInfo.viteTokenId).filterNil()
            .map({ $0.balance.amountFull(decimals: token.decimals) })
            .drive(balanceLabel.rx.text).disposed(by: rx.disposeBag)

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: tokenInfo.viteTokenId).filterNil()
            .map({ $0.unconfirmedBalance.amountFull(decimals: token.decimals) })
            .map({ R.string.localizable.balanceInfoDetailOnroadAmountContent($0) })
            .drive(onroadLabel.rx.text).disposed(by: rx.disposeBag)

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: tokenInfo.viteTokenId).filterNil()
            .map({ $0.unconfirmedBalance.value == 0 })
            .drive(onroadView.rx.isHidden).disposed(by: rx.disposeBag)

        FetchQuotaService.instance.maxTxCountDriver
            .map({ R.string.localizable.balanceInfoDetailPledgeCountContent($0) })
            .drive(quotaLabel.rx.text).disposed(by: rx.disposeBag)

        receiveButton.rx.tap.bind { [weak self] in
            UIViewController.current?.navigationController?.pushViewController(ReceiveViewController(tokenInfo: tokenInfo), animated: true)
            }.disposed(by: rx.disposeBag)

        sendButton.rx.tap.bind { [weak self] in
            let sendViewController = SendViewController(tokenInfo: tokenInfo, address: nil, amount: nil, note: nil)
            UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            }.disposed(by: rx.disposeBag)

        DispatchQueue.main.async {
            self.backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: self.frame, colors: tokenInfo.coinBackgroundGradientColors)
        }
    }
}
