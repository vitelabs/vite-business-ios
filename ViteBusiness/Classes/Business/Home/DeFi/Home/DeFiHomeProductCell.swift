//
//  DeFiHomeProductCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/28.
//

import Foundation

class ProgressView: UIView {

    var progress: CGFloat = 0.0 {
        didSet {
            currentImageView.snp.remakeConstraints { (m) in
                m.left.top.bottom.equalTo(maxImageView)
                m.width.equalTo(maxImageView).multipliedBy(progress)
            }

            GCD.delay(0.01) {
                self.maxImageView.backgroundColor =
                    UIColor.gradientColor(style: .left2right,
                    frame: self.frame,
                    colors: [UIColor(netHex: 0xF2F8FF),
                             UIColor(netHex: 0xE3F0FF)])
                self.currentImageView.backgroundColor =
                    UIColor.gradientColor(style: .left2right,
                      frame: self.frame,
                      colors: [UIColor(netHex: 0x2A7FFF),
                               UIColor(netHex: 0x54B6FF)])
            }
        }
    }

    private let maxImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 2
    }

    private let currentImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(maxImageView)
        addSubview(currentImageView)

        maxImageView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
            m.height.equalTo(4)
        }

        currentImageView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DeFiHomeProductCell: BaseTableViewCell, ListCellable {

    static var cellHeight: CGFloat {
        return 145
    }

    fileprivate let iconImageView = UIImageView(image: R.image.icon_defi_home_cell_safe_flag())

    fileprivate let endTimeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
    }

    fileprivate let buyButton = UIButton().then {
        $0.setTitle(R.string.localizable.defiHomePageCellBuyButtonTitle(), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.resizable.highlighted, for: .highlighted)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    fileprivate let rateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        $0.numberOfLines = 1
        $0.textColor = UIColor(netHex: 0xFF0008)
    }

    fileprivate let rateTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        $0.numberOfLines = 1
        $0.text = R.string.localizable.defiHomePageCellRateTitle()
    }

    fileprivate let progressView = ProgressView()

    fileprivate let progressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        $0.numberOfLines = 1
    }

    fileprivate let timeLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x77808A)
        $0.numberOfLines = 1
    }

    fileprivate let totalLabel = UILabel().then {
        $0.numberOfLines = 1
    }

    fileprivate let eachLabel = UILabel().then {
        $0.numberOfLines = 1
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(iconImageView)
        contentView.addSubview(endTimeLabel)
        contentView.addSubview(buyButton)
        contentView.addSubview(rateLabel)
        contentView.addSubview(rateTitleLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(progressLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(totalLabel)
        contentView.addSubview(eachLabel)

        let line = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
        }

        contentView.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview()
        }

        let leftLayoutGuide = UILayoutGuide()
        let rightLayoutGuide = UILayoutGuide()
        contentView.addLayoutGuide(leftLayoutGuide)
        contentView.addLayoutGuide(rightLayoutGuide)

        iconImageView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(21)
            m.left.equalToSuperview().offset(24)
            m.size.equalTo(CGSize(width: 22, height: 22))
        }

        endTimeLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(iconImageView)
            m.left.equalTo(iconImageView.snp.right).offset(4)
        }

        buyButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(iconImageView)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(26)
        }

        leftLayoutGuide.snp.makeConstraints { (m) in
            m.top.equalTo(iconImageView.snp.bottom).offset(14)
            m.left.equalToSuperview().offset(24)
            m.bottom.equalToSuperview()
        }

        rightLayoutGuide.snp.makeConstraints { (m) in
            m.top.equalTo(iconImageView.snp.bottom).offset(14)
            m.left.equalTo(leftLayoutGuide.snp.right)
            m.width.equalTo(leftLayoutGuide)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview()
        }

        rateLabel.snp.makeConstraints { (m) in
            m.top.left.equalTo(leftLayoutGuide)
        }

        rateTitleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(leftLayoutGuide)
            m.top.equalTo(rateLabel.snp.bottom).offset(8)
        }

        progressView.snp.makeConstraints { (m) in
            m.left.equalTo(leftLayoutGuide)
            m.top.equalTo(rateTitleLabel.snp.bottom).offset(14)
            m.width.equalTo(110)
        }

        progressLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(progressView)
            m.left.equalTo(progressView.snp.right).offset(6)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.top.left.equalTo(rightLayoutGuide)
        }

        totalLabel.snp.makeConstraints { (m) in
            m.left.equalTo(rightLayoutGuide)
            m.top.equalTo(timeLabel.snp.bottom).offset(6)
        }

        eachLabel.snp.makeConstraints { (m) in
            m.left.equalTo(rightLayoutGuide)
            m.top.equalTo(totalLabel.snp.bottom).offset(4)
        }

        endTimeLabel.text = R.string.localizable.defiHomePageCellEndTime("30", "12:22:22")
        rateLabel.text = "10.33%"
        progressView.progress = 0.5
        progressLabel.text = "50%"

        timeLabel.text = R.string.localizable.defiHomePageCellBorrowTime("30")
        totalLabel.text = "\(R.string.localizable.defiHomePageCellTotalAmount()) 12.0000 VITE"
        eachLabel.text = "\(R.string.localizable.defiHomePageCellEachAmount()) 1.0000 VITE"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
