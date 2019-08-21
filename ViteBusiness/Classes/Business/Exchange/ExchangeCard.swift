//
//  ExchangeCard.swift
//  Action
//
//  Created by haoshenyang on 2019/8/7.
//

import UIKit

class ExchangeCard: UIView {

    let topBackground = UIImageView()
    let exchangeIcon = UIImageView()
    let exchangeTitlelabel = UILabel()
    let historyButton = UIButton()
    let historyArrowImage = UIImageView()

    let whiteView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 2
    }

    let middleSeperator = UIImageView()
    let middleIcon = UIImageView()


    let viteInfo = ExchangeTokenInfoView()

    let ethInfo = ExchangeTokenInfoView()

    let priceBackground = UIView()
    let priceLabel = UILabel()


    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(whiteView)
        whiteView.addSubview(topBackground)
        whiteView.addSubview(exchangeIcon)
        whiteView.addSubview(exchangeTitlelabel)
        whiteView.addSubview(historyArrowImage)
        whiteView.addSubview(historyButton)
        whiteView.addSubview(middleSeperator)
        whiteView.addSubview(middleIcon)
        whiteView.addSubview(viteInfo)
        whiteView.addSubview(ethInfo)
        whiteView.addSubview(priceBackground)
        whiteView.addSubview(priceLabel)




        historyArrowImage.image = R.image.exchange_hisrory_arrow()

        exchangeTitlelabel.text = R.string.localizable.exchangeCardTitle()
        exchangeTitlelabel.font = UIFont.boldSystemFont(ofSize: 14)
        exchangeTitlelabel.textColor = UIColor.init(netHex: 0x3E4A59)

        exchangeIcon.image = R.image.exchange_icon()
        historyButton.setTitle(R.string.localizable.exchangeHistory(), for: .normal)
        historyButton.setTitleColor(UIColor.init(netHex: 0x007AFF), for: .normal)
        historyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)

        topBackground.backgroundColor =
            UIColor.gradientColor(style: .leftTop2rightBottom,
                                  frame: CGRect.init(x: 0, y: 0, width:kScreenW - 48, height: 48),
                                  colors: [UIColor(netHex: 0xE3F0FF),UIColor(netHex: 0xF2F8FF)])



        GCD.delay(1) {
            self.ethInfo.icon.tokenInfo = TokenInfo.eth000
            self.ethInfo.tokenNamelabel.text = TokenInfo.eth000.symbol
            ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId:TokenInfo.eth000.id)
                .drive(onNext: { [weak self] balanceInfo in
                    guard let `self` = self else { return }
                    self.ethInfo.banlanceLabel.text = balanceInfo?.balance.amountFullWithGroupSeparator(decimals: TokenInfo.eth000.decimals)
                }).disposed(by: self.rx.disposeBag)

            self.viteInfo.icon.tokenInfo = TokenInfo.viteCoin
            self.viteInfo.tokenNamelabel.text = TokenInfo.viteCoin.symbol
            ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId:TokenInfo.viteCoin.id)
                .drive(onNext: { [weak self] balanceInfo in
                    guard let `self` = self else { return }
                    self.viteInfo.banlanceLabel.text = balanceInfo?.balance.amountFullWithGroupSeparator(decimals: TokenInfo.viteCoin.decimals)
                }).disposed(by: self.rx.disposeBag)

        }


        whiteView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        topBackground.snp.makeConstraints { (m) in
            m.height.equalTo(48)
            m.top.left.right.equalToSuperview()
        }

        exchangeIcon.snp.makeConstraints { (m) in
            m.width.height.equalTo(14)
            m.centerY.equalTo(topBackground)
            m.left.equalToSuperview().offset(16)
        }

        exchangeTitlelabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(exchangeIcon)
            m.left.equalTo(exchangeIcon.snp.right).offset(10)
        }

        historyButton.snp.makeConstraints { (m) in
            m.right.equalTo(historyArrowImage.snp.left)
            m.centerY.equalTo(exchangeIcon)
        }

        historyArrowImage.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-16)
            m.centerY.equalTo(exchangeIcon)
        }

        historyArrowImage.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-16)
            m.centerY.equalTo(exchangeIcon)
            m.width.height.equalTo(14)
        }



        ethInfo.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.height.equalTo(90)
            m.top.equalTo(topBackground.snp.bottom).offset(22)
        }

        viteInfo.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.height.equalTo(90)
            m.top.equalTo(ethInfo.snp.bottom).offset(84)
        }

        middleSeperator.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-16)
            m.left.equalToSuperview().offset(16)
            m.height.equalTo(1)
            m.top.equalTo(ethInfo.snp.bottom).offset(42)
        }


        middleIcon.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.centerY.equalTo(middleSeperator)
            m.size.equalTo(CGSize.init(width: 30, height: 30))
        }

        middleSeperator.image = R.image.exchange_middle_line()?.resizableImage(withCapInsets: .zero, resizingMode: .tile)
        middleIcon.image = R.image.exchange_arrow()

        priceBackground.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-16)
            m.left.equalToSuperview().offset(16)
            m.height.equalTo(32)
            m.bottom.equalToSuperview().offset(-26)
        }

        priceBackground.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
//
        priceLabel.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(26)
            m.centerY.equalTo(priceBackground)
        }

        priceLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha:  0.45)
        priceLabel.font = UIFont.systemFont(ofSize: 14)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

class ExchangeTokenInfoView: UIView {
    let icon = TokenIconView()
    let tokenNamelabel = UILabel()
    let banlanceLabel = UILabel()
    let inputTextField = UITextField()
    let bottonLine = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(icon)
        addSubview(tokenNamelabel)
        addSubview(banlanceLabel)
        addSubview(inputTextField)
        addSubview(bottonLine)

        icon.snp.makeConstraints { (m) in
            m.width.height.equalTo(30)
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(16)
        }

        tokenNamelabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(icon)
            m.left.equalTo(icon.snp.right).offset(10)
        }

        banlanceLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-16)
            m.centerY.equalTo(icon)
        }

        inputTextField.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-16)
            m.left.equalToSuperview().offset(16)
            m.height.equalTo(54)
            m.top.equalTo(icon.snp.bottom).offset(12)
        }

        bottonLine.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-16)
            m.left.equalToSuperview().offset(16)
            m.top.equalTo(inputTextField.snp.bottom)
            m.height.equalTo(CGFloat.singleLineWidth)
        }

        tokenNamelabel.font = UIFont.boldSystemFont(ofSize: 16)
        tokenNamelabel.textColor = UIColor.init(netHex: 0x3E4A59)

        banlanceLabel.font = UIFont.systemFont(ofSize: 13)
        banlanceLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)

        inputTextField.font = UIFont.boldSystemFont(ofSize: 20)
        inputTextField.textColor = UIColor.init(netHex: 0x24272B)
        inputTextField.keyboardType = .decimalPad

        bottonLine.backgroundColor = UIColor.init(netHex: 0xD3DFEF)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
