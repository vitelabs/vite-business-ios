//
//  DeFiHomeProductCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/28.
//

import Foundation
import ViteWallet

class DeFiHomeProductCell: BaseTableViewCell, ListCellable {
    typealias Model = DeFiLoan

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
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.highlighted.resizable, for: .highlighted)
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

    fileprivate let progressView = ProgressView(height: 4)

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
        }

        progressLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(progressView)
            m.left.equalTo(progressView.snp.right).offset(6)
            m.right.equalTo(leftLayoutGuide).offset(-22)
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ item: DeFiLoan) {

        endTimeLabel.text = R.string.localizable.defiHomePageCellEndTime(item.countDownString)
        rateLabel.text = item.yearRateString
        progressView.progress = CGFloat(item.loanCompleteness)
        progressLabel.text = item.loanCompletenessString


        let timeString = R.string.localizable.defiHomePageCellBorrowTime(String(item.loanDuration))
        let timeAttributedString = NSMutableAttributedString(string: timeString)

        timeAttributedString.addAttributes(
            text: timeString,
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x77808A),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ])

        timeAttributedString.addAttributes(
            text: String(item.loanDuration),
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x77808A),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)
        ])
        timeLabel.attributedText = timeAttributedString

        let totalString = "\(R.string.localizable.defiHomePageCellTotalAmount()) \(item.loanAmount.amountShortWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals)) VITE"
        let totalAttributedString = NSMutableAttributedString(string: totalString)

        totalAttributedString.addAttributes(
            text: R.string.localizable.defiHomePageCellTotalAmount(),
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.6),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ])

        totalAttributedString.addAttributes(
            text: item.loanAmount.amountShortWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals),
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.8),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        totalAttributedString.addAttributes(
            text: "VITE",
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.3),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ])
        totalLabel.attributedText = totalAttributedString

        let eachString = "\(R.string.localizable.defiHomePageCellEachAmount()) \(item.singleCopyAmount.amountShortWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals)) VITE"
        let eachAttributedString = NSMutableAttributedString(string: eachString)

        eachAttributedString.addAttributes(
            text: R.string.localizable.defiHomePageCellEachAmount(),
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.6),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ])

        eachAttributedString.addAttributes(
            text: item.singleCopyAmount.amountShortWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals),
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.8),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        eachAttributedString.addAttributes(
            text: "VITE",
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.3),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ])
        eachLabel.attributedText = eachAttributedString

        buyButton.rx.tap.bind {
            let vc = DeFiSubscriptionViewController(productHash: item.productHash)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
}

extension NSMutableAttributedString {
    func addAttributes(text: String, attrs: [NSAttributedString.Key : Any]) {

        func getRanges(ranges: [Range<String.Index>], source: String, sub: String) -> [Range<String.Index>] {
            var array = ranges
            if let r = source.range(of: sub, options: .backwards) {
                array.append(r)
                let newSource = String(source[source.startIndex..<r.lowerBound])
                return getRanges(ranges: array, source: newSource, sub: sub)
            } else {
                return array
            }
        }

        let ranges = getRanges(ranges: [], source: self.string, sub: text)
        for r in ranges {
            let range = NSRange(r, in: self.string)
            addAttributes(attrs, range: range)
        }
    }
}
