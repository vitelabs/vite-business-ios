//
//  SpotNavView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/30.
//

import Foundation
import RxSwift
import RxCocoa

class SpotNavView: UIView {
    static let height: CGFloat = 63

    var switchPair: ((MarketInfo) -> Void)?

    let tradeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.text = "--"
    }

    let quoteLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.text = "/--"
    }

    let miningImgView = UIImageView()

    let changeImageView = UIImageView(image: R.image.icon_market_change())
    let changeButton = UIButton().then {
        $0.backgroundColor = .clear
    }

    let operatorImageView = UIImageView()

    let klineButton = UIButton().then {
        $0.setImage(R.image.icon_spot_kilne(), for: .normal)
        $0.setImage(R.image.icon_spot_kilne()?.highlighted, for: .highlighted)
    }

    let favButton = UIButton().then {
        $0.setImage(R.image.icon_market_un_fav(), for: .normal)
        $0.setImage(R.image.icon_market_un_fav()?.highlighted, for: .highlighted)
    }

    let percentLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = "--"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(changeButton)
        addSubview(tradeLabel)
        addSubview(quoteLabel)
        addSubview(miningImgView)

        addSubview(changeImageView)
        addSubview(operatorImageView)
        addSubview(klineButton)
        addSubview(favButton)
        addSubview(percentLabel)

        let vLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xffffff, alpha: 0.15)
        }

        addSubview(vLine)

        changeButton.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalTo(tradeLabel)
            m.right.equalTo(operatorImageView.snp.left)
        }

        tradeLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(10)
            m.left.equalToSuperview().offset(24)
        }

        quoteLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(tradeLabel)
            m.left.equalTo(tradeLabel.snp.right).offset(2)
        }

        miningImgView.snp.makeConstraints { (m) in
            m.centerY.equalTo(tradeLabel)
            m.left.equalTo(quoteLabel.snp.right).offset(4)
        }

        vLine.snp.makeConstraints { (m) in
            m.width.equalTo(CGFloat.singleLineWidth)
            m.centerY.equalTo(tradeLabel)
            m.height.equalTo(12)
            m.left.equalTo(miningImgView.snp.right).offset(8)
        }

        changeImageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(tradeLabel)
            m.left.equalTo(vLine.snp.right).offset(7)
        }

        favButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(tradeLabel)
            m.right.equalToSuperview().offset(-24)
            m.size.equalTo(CGSize(width: 28, height: 28))
        }

        klineButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(tradeLabel)
            m.right.equalTo(favButton.snp.left)
            m.size.equalTo(CGSize(width: 16 + 20, height: 16 + 20))
        }

        operatorImageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(tradeLabel)
            m.right.equalTo(klineButton.snp.left).offset(-6)
            m.size.equalTo(CGSize(width: 14, height: 14))
        }

        percentLabel.snp.makeConstraints { (m) in
            m.top.equalTo(tradeLabel.snp.bottom).offset(6)
            m.bottom.equalToSuperview().offset(-6)
            m.left.equalTo(tradeLabel)
        }

        BehaviorRelay.combineLatest(MarketInfoService.shared.favouriteBehaviorRelay, marketInfoBehaviorRelay).bind { [weak self] in
            let symbol = $1?.statistic.symbol ?? ""
            if $0.contains(symbol) {
                self?.favButton.setImage(R.image.icon_market_fav(), for: .normal)
                self?.favButton.setImage(R.image.icon_market_fav()?.highlighted, for: .highlighted)
            } else {
                self?.favButton.setImage(R.image.icon_market_un_fav(), for: .normal)
                self?.favButton.setImage(R.image.icon_market_un_fav()?.highlighted, for: .highlighted)
            }
        }.disposed(by: rx.disposeBag)

        favButton.rx.tap.bind { [weak self] in
            guard let symbol = self?.marketInfoBehaviorRelay.value?.statistic.symbol else { return }
            if MarketInfoService.shared.isFavourite(symbol: symbol) {
                MarketInfoService.shared.removeFavourite(symbol: symbol)
            } else {
                MarketInfoService.shared.addFavourite(symbol: symbol)
            }
        }.disposed(by: rx.disposeBag)

        changeButton.rx.tap.bind {
            SeletcMarketPairManager.shared.showCard()
            SeletcMarketPairManager.shared.onSelectInfo = { [weak self] info in
                self?.switchPair?(info)
            }
        }.disposed(by: rx.disposeBag)

        klineButton.rx.tap.bind { [weak self] in
            guard let marketInfo = self?.marketInfoBehaviorRelay.value else { return }
            let vc = MarketDetailViewController(marketInfo: marketInfo)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)
    }

    let marketInfoBehaviorRelay: BehaviorRelay<MarketInfo?> = BehaviorRelay(value: nil)

    func setOpertionIcon(_ urlString: String?) {
        operatorImageView.kf.cancelDownloadTask()
        if let urlString = urlString, let url = URL(string: urlString) {
            operatorImageView.kf.setImage(with: url, placeholder: UIImage.color(UIColor(netHex: 0xF8F8F8)))
        }
    }

    func bind(marketInfo: MarketInfo?) {
        marketInfoBehaviorRelay.accept(marketInfo)
        tradeLabel.text = marketInfo?.statistic.tradeTokenSymbol ?? "--"
        quoteLabel.text = "/\(marketInfo?.statistic.quoteTokenSymbol ?? "--")"
        miningImgView.image = marketInfo?.miningImage
        miningImgView.isHidden = miningImgView.image == nil
        percentLabel.text = marketInfo?.persentString ?? "--"
        percentLabel.textColor = marketInfo?.persentColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
