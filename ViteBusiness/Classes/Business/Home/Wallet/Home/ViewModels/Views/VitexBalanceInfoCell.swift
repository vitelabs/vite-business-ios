//
//  VitexBalanceInfoCell.swift
//  Action
//
//  Created by haoshenyang on 2019/9/5.
//

import UIKit
import Then

class VitexBalanceInfoCell: BaseTableViewCell {
    
    static var cellHeight: CGFloat {
        return 130
    }

    var handler : ((UIButton) -> ())?

    fileprivate let colorView = UIImageView()
    fileprivate let iconImageView = TokenIconView()

    fileprivate let  availableTitleLabel = UILabel().then { label in
        label.text = "可用余额"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.45)
    }
    fileprivate let  availableLabel = UILabel().then { label in
        label.text = "label"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.init(netHex: 0x24272B)
    }

    fileprivate let  totalTitleLabel = UILabel().then { label in
        label.text = "全部余额"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.45)
    }
    fileprivate let  totalLabel = UILabel().then { label in
        label.text = "label"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.init(netHex: 0x24272B)
    }

    fileprivate let seperator = UIView().then { s in
        s.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
    }

    fileprivate let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
    }

    fileprivate let highlightedMaskView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 2
        $0.isUserInteractionEnabled = false
        $0.isHidden = true
    }

    fileprivate let button = UIButton().then { button in
        button.setImage(R.image.icon_nav_more(), for: .normal)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none

        let whiteView = UIView().then {
            $0.backgroundColor = UIColor.white
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 2
        }

        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        let shadowView = UIView().then {
            $0.backgroundColor = nil
            $0.layer.shadowColor = UIColor(netHex: 0x000000, alpha: 0.1).cgColor
            $0.layer.shadowOpacity = 1
            $0.layer.shadowOffset = CGSize(width: 0, height: 5)
            $0.layer.shadowRadius = 20
        }

        shadowView.addSubview(whiteView)
        whiteView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        contentView.addSubview(shadowView)
        whiteView.addSubview(iconImageView)
        whiteView.addSubview(symbolLabel)
        whiteView.addSubview(colorView)
        whiteView.addSubview(highlightedMaskView)
        whiteView.addSubview(seperator)
        whiteView.addSubview(availableTitleLabel)
        whiteView.addSubview(availableLabel)
        whiteView.addSubview(totalTitleLabel)
        whiteView.addSubview(totalLabel)
        whiteView.addSubview(button)


        shadowView.snp.makeConstraints { (m) in
            m.top.equalTo(contentView)
            m.left.equalTo(contentView).offset(24)
            m.right.equalTo(contentView).offset(-24)
            m.height.equalTo(70)
            m.bottom.equalTo(contentView).offset(-16)
        }

        highlightedMaskView.snp.makeConstraints { (m) in
            m.edges.equalTo(shadowView)
        }

        colorView.snp.makeConstraints { (m) in
            m.top.left.bottom.equalTo(whiteView)
            m.width.equalTo(3)
        }

        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconImageView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(8)
            m.left.equalToSuperview().offset(14)
            m.size.equalTo(CGSize(width: 40, height: 40))
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(iconImageView)
            m.left.equalTo(iconImageView.snp.right).offset(13)
        }

        button.snp.makeConstraints { (m) in
            m.centerY.equalTo(iconImageView)
            m.right.equalToSuperview().offset(-13)
        }

        symbolLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        seperator.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(14)
            m.height.equalTo(1)
            m.top.equalTo(iconImageView.snp.bottom).offset(8)
        }

        availableTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(seperator.snp.bottom).offset(8)
            m.left.equalToSuperview().offset(14)
        }

        availableLabel.snp.makeConstraints { (m) in
            m.top.equalTo(availableTitleLabel.snp.bottom).offset(5)
            m.left.equalTo(availableTitleLabel)
        }

        totalTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(seperator.snp.bottom).offset(8)
            m.left.equalTo(seperator.snp.centerX).offset(14)
        }

        totalLabel.snp.makeConstraints { (m) in
            m.top.equalTo(totalTitleLabel.snp.bottom).offset(5)
            m.left.equalTo(totalTitleLabel)
            m.right.lessThanOrEqualTo(seperator.snp.right)
        }

        button.rx.tap.bind { [unowned self] in
            self.handler?(self.button)
        }.disposed(by: rx.disposeBag)


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        highlightedMaskView.isHidden = !highlighted
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        highlightedMaskView.isHidden = !selected
//    }

    func bind(viewModel: WalletHomeBalanceInfoViewModel) {

        iconImageView.tokenInfo = viewModel.tokenInfo

        symbolLabel.text = viewModel.symbol
        symbolLabel.textColor = UIColor.init(netHex: 0x24272B)
        colorView.backgroundColor = viewModel.tokenInfo.mainColor
    }
}
