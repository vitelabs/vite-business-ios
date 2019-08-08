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

    let colorBackgroundView = UIView()

    let addressButton = UIButton().then {
        $0.setBackgroundImage(nil, for: .normal)
        $0.setBackgroundImage(UIImage.color(UIColor.white.withAlphaComponent(0.2)), for: .highlighted)
    }
    let balanceView = UIView()
    let onroadView = UIView()
    let pledgeView = UIView()

    let buttonView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        $0.layer.shadowOpacity = 1
        $0.layer.shadowOffset = CGSize(width: 0, height: -2)
        $0.layer.shadowRadius = 2
    }

    let quotaView = BalanceInfoViteChainQuotaView()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 308)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        layer.cornerRadius = 2

        addSubview(colorBackgroundView)
        colorBackgroundView.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
            m.height.equalTo(218)
        }

        setupAddressView()
        setupBalanceView()

        setupButtonView()

        setupOnroadView()
        setupPledgeView()

        setupQuotaView()
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

        colorBackgroundView.addSubview(addressButton)
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
            Statistics.log(eventId: Statistics.Page.WalletHome.changeAddressClicked.rawValue)
            UIViewController.current?.navigationController?.pushViewController(AddressManageViewController(), animated: true)
            }.disposed(by: rx.disposeBag)

        Observable.combineLatest(
            HDWalletManager.instance.accountDriver.filterNil().asObservable(),
            AddressManageService.instance.myAddressNameMapDriver.asObservable())
            .bind { (account, _) in
                nameLabel.text = AddressManageService.instance.name(for: account.address)
                addressLabel.text = account.address
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

        colorBackgroundView.addSubview(balanceView)
        balanceView.addSubview(balanceLabel)
        balanceView.addSubview(priceLabel)

        balanceView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.equalTo(addressButton.snp.bottom).offset(11)
            m.height.equalTo(52)
        }

        balanceLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(14)
            m.right.equalToSuperview().offset(-14)
        }

        priceLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.left.equalToSuperview().offset(14)
            m.right.equalToSuperview().offset(-14)
        }
    }

    func setupOnroadView() {

        onroadTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor.white.withAlphaComponent(0.8)
            $0.numberOfLines = 1
        }

        onroadLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.textColor = UIColor.white
            $0.numberOfLines = 1
        }

        colorBackgroundView.addSubview(onroadView)
        onroadView.addSubview(onroadTitleLabel)
        onroadView.addSubview(onroadLabel)

        onroadView.snp.makeConstraints { (m) in
            m.top.equalTo(balanceView.snp.bottom).offset(14)
            m.left.equalToSuperview().offset(14)
            m.height.equalTo(37)
        }

        onroadTitleLabel.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
        }

        onroadLabel.snp.makeConstraints { (m) in
            m.bottom.left.right.equalToSuperview()
        }
    }

    func setupPledgeView() {

        pledgeTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor.white.withAlphaComponent(0.8)
            $0.numberOfLines = 1
            $0.text = R.string.localizable.balanceInfoDetailPledgeAmountTitle()
        }

        pledgeLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.textColor = UIColor.white
            $0.numberOfLines = 1
        }

        colorBackgroundView.addSubview(pledgeView)
        pledgeView.addSubview(pledgeTitleLabel)
        pledgeView.addSubview(pledgeLabel)

        pledgeView.snp.makeConstraints { (m) in
            m.top.equalTo(onroadView)
            m.left.equalTo(onroadView.snp.right)
            m.right.equalToSuperview().offset(-14)
            m.height.equalTo(onroadView)
            m.width.equalTo(onroadView)
        }

        pledgeTitleLabel.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
        }

        pledgeLabel.snp.makeConstraints { (m) in
            m.bottom.left.right.equalToSuperview()
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

        colorBackgroundView.addSubview(buttonView)
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

    func setupQuotaView() {
        addSubview(quotaView)
        quotaView.snp.makeConstraints { (m) in
            m.top.equalTo(colorBackgroundView.snp.bottom).offset(16)
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.height.equalTo(74)
        }
    }

    var balanceLabel: UILabel!
    var receiveButton: UIButton!
    var sendButton: UIButton!
    var onroadTitleLabel: UILabel!
    var onroadLabel: UILabel!
    var pledgeTitleLabel: UILabel!
    var pledgeLabel: UILabel!
    var priceLabel: UILabel!

    func bind(tokenInfo: TokenInfo) {
        guard let token = tokenInfo.toViteToken() else { return }

        pledgeView.isHidden = !tokenInfo.isViteCoin

        Driver.combineLatest(
            ExchangeRateManager.instance.rateMapDriver,
            ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: tokenInfo.viteTokenId).filterNil()).map({ (map, balanceInfo) -> String in
                "≈" + map.priceString(for: balanceInfo.tokenInfo, balance: balanceInfo.balance)
            }).drive(priceLabel.rx.text).disposed(by: rx.disposeBag)

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: tokenInfo.viteTokenId).filterNil()
            .map({ $0.balance.amountFullWithGroupSeparator(decimals: token.decimals) })
            .drive(balanceLabel.rx.text).disposed(by: rx.disposeBag)

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: tokenInfo.viteTokenId).filterNil()
            .map({
                if $0.unconfirmedCount > 0 {
                    let ut = (Double($0.unconfirmedCount) * ViteWalletConst.ut.receive).utToString()
                    return R.string.localizable.balanceInfoDetailUnconfirmedTitle() + R.string.localizable.balanceInfoDetailUnconfirmedQuotaTitle("\(ut)")
                } else {
                    return R.string.localizable.balanceInfoDetailUnconfirmedTitle()
                }
            })
            .drive(onroadTitleLabel.rx.text).disposed(by: rx.disposeBag)

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: tokenInfo.viteTokenId).filterNil()
            .map({ $0.unconfirmedBalance.amountFullWithGroupSeparator(decimals: token.decimals) })
            .drive(onroadLabel.rx.text).disposed(by: rx.disposeBag)

        FetchQuotaManager.instance.quotaDriver.drive(onNext: { [weak self] (quota) in
            guard let `self` = self else { return }
            self.quotaView.updateQuota(currect: quota.currentUt, max: quota.utpe)
        }).disposed(by: rx.disposeBag)

        FetchQuotaManager.instance.pledgeAmountDriver
            .map({ $0.amountFullWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals) })
            .drive(pledgeLabel.rx.text).disposed(by: rx.disposeBag)

        receiveButton.rx.tap.bind { [weak self] in
            Statistics.log(eventId: String(format: Statistics.Page.WalletHome.tokenDetailsReceiveClicked.rawValue, tokenInfo.statisticsId))
            UIViewController.current?.navigationController?.pushViewController(ReceiveViewController(tokenInfo: tokenInfo), animated: true)
            }.disposed(by: rx.disposeBag)

        sendButton.rx.tap.bind { [weak self] in
            Statistics.log(eventId: String(format: Statistics.Page.WalletHome.tokenDetailsSendClicked.rawValue, tokenInfo.statisticsId))
            let sendViewController = SendViewController(tokenInfo: tokenInfo, address: nil, amount: nil, note: nil)
            UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            }.disposed(by: rx.disposeBag)

        DispatchQueue.main.async {
            self.colorBackgroundView.backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: self.frame, colors: tokenInfo.coinBackgroundGradientColors)
        }
    }
}
