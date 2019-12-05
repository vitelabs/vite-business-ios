//
//  MyDeFiSubscribeCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import UIKit

class MyDeFiSubscribeCell: BaseTableViewCell, ListCellable {
    typealias Model = DeFiSubscription

    static var cellHeight: CGFloat {
        return 170
    }

    fileprivate let iconImageView = UIImageView()

    fileprivate let idLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x77808A)
        $0.numberOfLines = 1
    }

    fileprivate let lineImageView = UIImageView(image: R.image.icon_my_loan_cell_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

    fileprivate let statusLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
    }

    fileprivate let leftLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.8)
        $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }

    fileprivate let rightLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.8)
        $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }

    fileprivate let leftTitleLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    fileprivate let rightTitleLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    fileprivate let bottomLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    fileprivate let progressView = ProgressView(height: 6)

    fileprivate let progressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        $0.numberOfLines = 1
    }

    fileprivate let button = UIButton().then {
        $0.setTitle(R.string.localizable.defiHomePageCellBuyButtonTitle(), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.highlighted.resizable, for: .highlighted)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(iconImageView)
        contentView.addSubview(idLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(lineImageView)
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightLabel)
        contentView.addSubview(leftTitleLabel)
        contentView.addSubview(rightTitleLabel)
        contentView.addSubview(bottomLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(progressLabel)
        contentView.addSubview(button)

        let line = UIView()
        line.backgroundColor = UIColor(netHex: 0xD3DFEF)
        contentView.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(26)
            m.left.equalToSuperview().offset(24)
            m.size.equalTo(CGSize(width: 12, height: 12))
        }

        idLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(iconImageView)
            m.left.equalTo(iconImageView.snp.right).offset(6)
        }

        statusLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(iconImageView)
            m.left.equalTo(idLabel.snp.right).offset(6)
            m.right.equalToSuperview().offset(-24)
        }

        idLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        idLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        lineImageView.snp.makeConstraints { (m) in
            m.top.equalTo(iconImageView.snp.bottom).offset(13)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }

        leftLabel.snp.makeConstraints { (m) in
            m.top.equalTo(lineImageView.snp.bottom).offset(9)
            m.left.equalToSuperview().offset(24)
        }

        leftTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(leftLabel.snp.bottom).offset(2)
            m.left.equalToSuperview().offset(24)
        }

        rightLabel.snp.makeConstraints { (m) in
            m.top.equalTo(lineImageView.snp.bottom).offset(9)
            m.left.equalTo(contentView.snp.centerX)
        }

        rightTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(rightLabel.snp.bottom).offset(2)
            m.left.equalTo(contentView.snp.centerX)
        }

        bottomLabel.snp.makeConstraints { (m) in
            m.top.equalTo(leftTitleLabel.snp.bottom).offset(10)
            m.left.equalToSuperview().offset(24)
        }

        progressView.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-19)
            m.left.equalToSuperview().offset(24)
        }

        progressLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(progressView)
            m.left.equalTo(progressView.snp.right).offset(6)
            m.right.equalTo(contentView.snp.centerX).offset(-21)
        }

        button.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview().offset(-8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ item: DeFiSubscription) {
        textLabel?.text = "456"
    }
}
