//
//  MyDeFiSubscribeCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import UIKit
import ViteWallet

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
            m.left.greaterThanOrEqualTo(idLabel.snp.right).offset(6)
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
        self.item = item
        let token = ViteWalletConst.viteToken
        idLabel.text = R.string.localizable.defiMyPageMySubscriptionCellIdTitle() + item.productHash
        progressView.progress = CGFloat(item.loanCompleteness)
        progressLabel.text = item.loanCompletenessString

        bottomLabel.attributedText = {

            let left = R.string.localizable.defiMyPageMySubscriptionCellTitleYearRate(item.yearRateString)
            let right = R.string.localizable.defiMyPageMySubscriptionCellTitleDuration(String(item.loanDuration))

            let leftA = NSMutableAttributedString(string: left)
            let rightA = NSMutableAttributedString(string: right)

            leftA.addAttributes(
                text: left,
                attrs: [
                    NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.45),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
            ])

            leftA.addAttributes(
                text: item.yearRateString,
                attrs: [
                    NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.8),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)
            ])

            rightA.addAttributes(
                text: right,
                attrs: [
                    NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.45),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
            ])

            rightA.addAttributes(
                text: String(item.loanDuration),
                attrs: [
                    NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.8),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)
            ])

            let ret = leftA
            ret.append(NSAttributedString(string: "   "))
            ret.append(rightA)
            return ret
        }()

        func showSubscribedAndLeft() {
            leftTitleLabel.text = R.string.localizable.defiMyPageMySubscriptionCellTitleSaled()
            rightTitleLabel.text = R.string.localizable.defiMyPageMySubscriptionCellTitleRemainAmount()

            leftLabel.attributedText = {
                let amount = item.mySubscribedAmount.amountShortWithGroupSeparator(decimals: token.decimals)
                let symbol = token.symbol
                let string = amount+symbol
                let ret = NSMutableAttributedString(string: string)

                ret.addAttributes(
                    text: amount,
                    attrs: [
                        NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.8),
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)
                ])

                ret.addAttributes(
                    text: symbol,
                    attrs: [
                        NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.3),
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
                ])

                return ret
            }()

            rightLabel.attributedText = {
                let amount = item.leftSubscriptionAmount.amountShortWithGroupSeparator(decimals: token.decimals)
                let symbol = token.symbol
                let string = amount+symbol
                let ret = NSMutableAttributedString(string: string)

                ret.addAttributes(
                    text: amount,
                    attrs: [
                        NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.8),
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)
                ])

                ret.addAttributes(
                    text: symbol,
                    attrs: [
                        NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.3),
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
                ])

                return ret
            }()
        }

        func showSubscribedAndProfits() {
            leftTitleLabel.text = R.string.localizable.defiMyPageMySubscriptionCellTitleSubscriptionAmount()
            rightTitleLabel.text = R.string.localizable.defiMyPageMySubscriptionCellTitleTotalEarnings()

            leftLabel.attributedText = {
                let amount = item.mySubscribedAmount.amountShortWithGroupSeparator(decimals: token.decimals)
                let symbol = token.symbol
                let string = amount+symbol
                let ret = NSMutableAttributedString(string: string)

                ret.addAttributes(
                    text: amount,
                    attrs: [
                        NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.8),
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)
                ])

                ret.addAttributes(
                    text: symbol,
                    attrs: [
                        NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.3),
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
                ])

                return ret
            }()

            rightLabel.attributedText = {
                let amount = item.totalProfits.amountShortWithGroupSeparator(decimals: token.decimals)
                let symbol = token.symbol
                let string = amount+symbol
                let ret = NSMutableAttributedString(string: string)

                ret.addAttributes(
                    text: amount,
                    attrs: [
                        NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.8),
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)
                ])

                ret.addAttributes(
                    text: symbol,
                    attrs: [
                        NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.3),
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
                ])

                return ret
            }()
        }

        switch item.productStatus {
        case .onSale:
            iconImageView.image = R.image.icon_cell_loan_on_sale()
            statusLabel.text = R.string.localizable.defiMyPageMySubscriptionCellHeaderEndTime(item.countDownString)
            showSubscribedAndLeft()
            button.isHidden = false
            button.setTitle(R.string.localizable.defiMyPageMySubscriptionCellButtonSubscription(), for: .normal)
            button.rx.tap.bind {
                let vc = DeFiSubscriptionViewController(productHash: item.productHash)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)

        case .failed:
            iconImageView.image = R.image.icon_cell_loan_failed()
            statusLabel.text = R.string.localizable.defiMyPageMySubscriptionCellHeaderFailed()
            showSubscribedAndLeft()
            button.isHidden = false
            button.setTitle(R.string.localizable.defiMyPageMySubscriptionCellButtonViewRefund(), for: .normal)
            button.rx.tap.bind {
                let vc = MyDeFiBillViewController.init()
                vc.initStatus = .认购失败退款
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)

        case .success:
            iconImageView.image = R.image.icon_cell_loan_sucess()
            statusLabel.text = R.string.localizable.defiMyPageMySubscriptionCellHeaderSuccess(item.subscriptionFinishTimeString)
            showSubscribedAndProfits()
            button.isHidden = false
            button.setTitle(R.string.localizable.defiMyPageMySubscriptionCellButtonViewEarnings(), for: .normal)
            button.rx.tap.bind {
                 let vc = MyDeFiBillViewController.init()
                   vc.initStatus = .认购收益
                   UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)

        case .cancel:
            break
        }
    }

    var item: DeFiSubscription?
    func updateEndTime(date: Date) {
        guard let item = self.item else { return }
        guard item.productStatus == .onSale else { return }
        statusLabel.text = R.string.localizable.defiMyPageMyLoanCellHeaderEndTime(item.countDownString(for: date))
    }
}
