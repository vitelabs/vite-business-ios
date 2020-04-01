//
//  MarketDetailNavView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/16.
//

import UIKit
import RxSwift
import RxCocoa

class MarketDetailNavView: UIView {

    static let height: CGFloat = 44

    var switchPair: ((MarketInfo) -> Void)?

    let backButton = UIButton().then {
        $0.setImage(R.image.icon_nav_back_black_gray(), for: .normal)
        $0.setImage(R.image.icon_nav_back_black_gray()?.highlighted, for: .highlighted)
    }

    let tradeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
    }

    let quoteLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B)
    }

    let miningImgView = UIImageView()

    let changeImageView = UIImageView(image: R.image.icon_market_change())
    let changeButton = UIButton().then {
        $0.backgroundColor = .clear
    }

    let operatorImageView = UIImageView()

    let favButton = UIButton().then {
        $0.setImage(R.image.icon_market_un_fav(), for: .normal)
        $0.setImage(R.image.icon_market_un_fav()?.highlighted, for: .highlighted)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(netHex: 0x3E4A59, alpha: 0.02)

        addSubview(backButton)
        addSubview(changeButton)
        addSubview(tradeLabel)
        addSubview(quoteLabel)
        addSubview(miningImgView)

        addSubview(changeImageView)
        addSubview(operatorImageView)
        addSubview(favButton)

        let vLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xffffff, alpha: 0.15)
        }

        addSubview(vLine)


        backButton.snp.makeConstraints { (m) in
            m.top.equalTo(self.safeAreaLayoutGuideSnpTop)
            m.bottom.equalToSuperview()
            m.left.equalToSuperview().offset(20)
            m.size.equalTo(CGSize(width: 28, height: 28 + 16))
        }

        changeButton.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalTo(tradeLabel)
            m.right.equalTo(operatorImageView.snp.left)
        }

        tradeLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(backButton)
            m.left.equalTo(backButton.snp.right).offset(8)
        }

        quoteLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(backButton)
            m.left.equalTo(tradeLabel.snp.right).offset(3)
        }

        miningImgView.snp.makeConstraints { (m) in
            m.centerY.equalTo(backButton)
            m.left.equalTo(quoteLabel.snp.right).offset(4)
        }

        vLine.snp.makeConstraints { (m) in
            m.width.equalTo(CGFloat.singleLineWidth)
            m.centerY.equalTo(backButton)
            m.height.equalTo(12)
            m.left.equalTo(miningImgView.snp.right).offset(8)
        }

        changeImageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(backButton)
            m.left.equalTo(vLine.snp.right)
        }

        favButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(backButton)
            m.right.equalToSuperview().offset(-20)
        }

        operatorImageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(backButton)
            m.right.equalTo(favButton.snp.left).offset(-8)
            m.size.equalTo(CGSize(width: 14, height: 14))
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

        backButton.rx.tap.bind {
            UIViewController.current?.navigationController?.popViewController(animated: true)
        }.disposed(by: rx.disposeBag)

        changeButton.rx.tap.bind {
            SeletcMarketPairManager.shared.showCard()
            SeletcMarketPairManager.shared.onSelectInfo = { [weak self] info in
                self?.switchPair?(info)
            }
        }.disposed(by: rx.disposeBag)
    }

    let marketInfoBehaviorRelay: BehaviorRelay<MarketInfo?> = BehaviorRelay(value: nil)

    func setOpertionIcon(_ urlString: String?) {
        operatorImageView.kf.cancelDownloadTask()
        if let urlString = urlString, let url = URL(string: urlString) {
            operatorImageView.kf.setImage(with: url, placeholder: UIImage.color(UIColor(netHex: 0xF8F8F8)))
        }
    }

    func bind(marketInfo: MarketInfo) {
        marketInfoBehaviorRelay.accept(marketInfo)
        tradeLabel.text = marketInfo.statistic.tradeTokenSymbol
        quoteLabel.text = "/\(marketInfo.statistic.quoteTokenSymbol ?? "")"
        miningImgView.image = marketInfo.miningImage
        miningImgView.isHidden = miningImgView.image == nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
