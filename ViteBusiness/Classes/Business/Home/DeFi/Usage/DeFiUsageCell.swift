//
//  DeFiUsageCell.swift
//  Action
//
//  Created by haoshenyang on 2019/12/9.
//

import UIKit
import RxSwift
import RxCocoa

let decimals = TokenInfo.BuildIn.vite.value.decimals
let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return dateFormatter
}()

class DefiUsageForSBPCell: BaseTableViewCell,ListCellable {

    func bind(_ item: DefiUsageInfo) {

        bgColoredLable.text = " \(item.usageInfo.sbpName ?? ""): \(item.usageInfo.blockProducingAddress  ?? "") "
        amountLabel.text = item.amountInfo.baseAmount.amountShort(decimals: decimals)
        timeLabel.text = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(item.usageTime)))
        borrowedFundLabel.text = R.string.localizable.defiUsePageUsedBorrowedFundTitle() + item.amountInfo.loanAmount.amountShort(decimals: decimals)
        baseFundLabel.text = R.string.localizable.defiUsePageUsedBasefundTitle() + item.amountInfo.baseAmount.amountShort(decimals: decimals)
        chainHeightLabel.text = R.string.localizable.defiUsePageDeadlineBlockHeightTitle() + String(item.usageInfo.pledgeDueHeight)

        self.editButton.rx.tap.bind { [unowned self] _ in

            let alert = UIAlertController.init(title: R.string.localizable.defiUsePageEditSbpTitle(), message: nil, preferredStyle: .alert)

            alert.addTextField(configurationHandler: { (textField) in
                textField.isEnabled = false
                textField.text =  R.string.localizable.defiUsePageEditSbpBlockProducingAddressTitle()
            })
            alert.addTextField(configurationHandler: { (textField) in
                textField.clearButtonMode = .always
                textField.text = item.usageInfo.blockProducingAddress
            })
            alert.addTextField(configurationHandler: { (textField) in
                textField.isEnabled = false
                textField.text =  R.string.localizable.defiUsePageEditSbpRewardWithdrawAddressTitle()
            })
            alert.addTextField(configurationHandler: { (textField) in
                textField.clearButtonMode = .always
                textField.text = item.usageInfo.rewardWithdrawAddress
            })

            let action0 = UIAlertAction.init(title: R.string.localizable.defiUsePageEditSbpConfirm(), style: .default) { [unowned alert] (action) in
                let textFields = alert.textFields!
                let address1 = textFields[1].text ?? item.usageInfo.blockProducingAddress ?? ""
                let address2 = textFields[3].text ?? item.usageInfo.rewardWithdrawAddress ?? ""
                guard address1.isViteAddress && address2.isViteAddress else {
                    Toast.show("worng address")
                    return
                }
                Workflow.defiUpdateSBPRegistrationWithConfirm(
                    account: HDWalletManager.instance.account!,
                    tokenInfo: TokenInfo.BuildIn.vite.value,
                    investId: UInt64(item.usageHash)!,
                    operationCode: 3,
                    sbpName: "",
                    blockProducingAddress: address1,
                    rewardWithdrawAddress: address2) { (result) in
                        switch result {
                        case .success(_):
                            break
                        case .failure(let e):
                            Toast.show(e.localizedDescription)
                        }
                }

            }

            let action1 = UIAlertAction.init(title: R.string.localizable.defiUsePageEditSbpCancle(), style: .default) { (action) in

                Workflow.defiCancelInvestWithConfirm(
                    account: HDWalletManager.instance.account!,
                    tokenInfo: TokenInfo.BuildIn.vite.value,
                    investId: UInt64(item.usageHash)!) { (result) in
                        switch result {
                        case .success(_):
                            break
                        case .failure(let e):
                            Toast.show(e.localizedDescription)
                        }

                }

            }

            alert.addAction(action0)
            alert.addAction(action1)


            UIViewController.current?.present(alert, animated: true, completion: nil)

        }.disposed(by: disposeBag)

        self.cancleButton.rx.tap
            .bind { _ in
            Alert.show(title: R.string.localizable.defiUsePageEditSbpCancleTitle(), message: "\(R.string.localizable.defiUsePageEditCanCancleAmount()) \(item.usageInfo.pledgeAmount.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals)) VITE。\n\(R.string.localizable.defiUsePageEditSbpCancleDesc())", actions: [
                (.default(title: R.string.localizable.defiUsePageEditCancleCancle()), nil),
                (.default(title: R.string.localizable.defiUsePageEditCancleConfirm()), {[weak self] _ in

                }),
                ])
        }.disposed(by: disposeBag)
    }

     static var cellHeight: CGFloat = 224

     typealias Model = DefiUsageInfo

    let icon = UIImageView().then {
        $0.image = R.image.defi_use_sbp()
    }
    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x77808A)
        $0.text = R.string.localizable.defiUsePageRegistSbp()
    }
    let bgColoredLable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "  "
        $0.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
        $0.layer.cornerRadius = 1
    }

    let seperator = UIImageView(image: R.image.icon_my_loan_cell_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

    let amountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let untilLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        $0.text = "VITE"
    }
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let amountTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageQoutoFund()
    }
    let timeTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageGussesedDeadlineTime()
    }
    let borrowedFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageUsedBorrowedFundTitle()
    }
    let baseFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageUsedBasefundTitle()
    }
    let chainHeightLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageDeadlineBlockHeightTitle()
    }

    let editButton = UIButton().then {
        $0.setTitle(R.string.localizable.defiUsePageDeit(), for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        $0.setTitleColor(UIColor.init(netHex: 0x007AFF), for: .normal)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.setBackgroundImage(UIImage.image(withColor: .white, cornerRadius: 13, borderColor: nil, borderWidth: 0).resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.highlighted.resizable, for: .highlighted)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        $0.layer.cornerRadius = 13

        $0.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 5, height: 5)
        $0.layer.shadowRadius = 5
    }

    let cancleButton = UIButton().then {
        $0.setTitle(R.string.localizable.defiUsePageRevocationSBP(), for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.setTitleColor(.white, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.highlighted.resizable, for: .highlighted)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    let getAwardLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        $0.text = R.string.localizable.defiUsePageSBPReward()
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bgColoredLable)
        contentView.addSubview(seperator)
        contentView.addSubview(amountLabel)
        contentView.addSubview(untilLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(borrowedFundLabel)
        contentView.addSubview(baseFundLabel)
        contentView.addSubview(chainHeightLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(cancleButton)
        contentView.addSubview(getAwardLabel)

        icon.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalToSuperview().offset(22)
            m.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(icon.snp.trailing).offset(3)
            m.centerY.equalTo(icon)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        bgColoredLable.snp.makeConstraints { (m) in
            m.trailing.equalToSuperview().offset(-23)
            m.centerY.equalTo(icon)
            m.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(10)
        }

        seperator.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(23)
            m.top.equalTo(icon.snp.bottom).offset(10)
            m.height.equalTo(1)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        untilLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(amountLabel.snp.trailing).offset(2)
            m.centerY.equalTo(amountLabel)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(contentView.snp.centerX)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        amountTitleLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        timeTitleLabel.snp.makeConstraints { (m) in
             m.leading.equalTo(timeLabel)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        borrowedFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountTitleLabel.snp.bottom).offset(10)
        }

        baseFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(borrowedFundLabel.snp.bottom).offset(6)
        }

        chainHeightLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
             m.top.equalTo(baseFundLabel.snp.bottom).offset(6)
        }

        editButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(chainHeightLabel)
            m.trailing.equalTo(contentView).offset(-106)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

        cancleButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(chainHeightLabel)
            m.trailing.equalTo(contentView).offset(-24)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

        getAwardLabel.snp.makeConstraints { (m) in
            m.top.equalTo(cancleButton.snp.bottom).offset(15)
            m.leading.equalToSuperview().offset(23)
        }

        let bottomseperator = UIView().then { (view) in
            view.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
        }
        contentView.addSubview(bottomseperator)
        bottomseperator.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.height.equalTo(0.5)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DefiUsageForSVIPCell: BaseTableViewCell ,ListCellable {

    func bind(_ item: DefiUsageInfo) {
        bgColoredLable.text = " " + R.string.localizable.defiBillBillTypeTitleOpenSVIPexchange() + ": " + (item.usageInfo.svipAddress  ?? "") + " "
        amountLabel.text = item.amountInfo.baseAmount.amountShort(decimals: decimals)
        timeLabel.text = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(item.usageTime)))
        borrowedFundLabel.text = R.string.localizable.defiUsePageUsedBorrowedFundTitle() + item.amountInfo.loanAmount.amountShort(decimals: decimals)
        baseFundLabel.text = R.string.localizable.defiUsePageUsedBasefundTitle() + item.amountInfo.baseAmount.amountShort(decimals: decimals)

        self.cancleButton.rx.tap.bind { _ in
            Alert.show(title: R.string.localizable.defiUsePageEditSvipCancleTitle(), message: "\(R.string.localizable.defiUsePageEditCanCancleAmount())\(item.usageInfo.pledgeAmount.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals)) VITE\n\(R.string.localizable.defiUsePageEditSvipCancleDesc())", actions: [
            (.default(title: R.string.localizable.defiUsePageEditCancleCancle()), nil),
            (.default(title: R.string.localizable.defiUsePageEditCancleConfirm()), {[weak self] _ in
                Workflow.defiCancelInvestWithConfirm(
                    account: HDWalletManager.instance.account!,
                    tokenInfo: TokenInfo.BuildIn.vite.value,
                    investId: UInt64(item.usageHash)!) { (result) in
                        switch result {
                        case .success(_):
                            break
                        case .failure(let e):
                            Toast.show(e.localizedDescription)
                        }

                }
            }),
            ])

        }.disposed(by: disposeBag)
    }

     static var cellHeight: CGFloat = 162

     typealias Model = DefiUsageInfo

    let icon = UIImageView().then {
        $0.image = R.image.defi_use_svip()
    }
    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x77808A)
        $0.text = R.string.localizable.defiUsePageOpenSvip()
    }
    let bgColoredLable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "  "
        $0.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
        $0.layer.cornerRadius = 1
    }

    let seperator = UIImageView(image: R.image.icon_my_loan_cell_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

    let amountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let untilLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        $0.text = "VITE"
    }
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let amountTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageQoutoFund()
    }
    let timeTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageGussesedDeadlineTime()
    }
    let borrowedFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageUsedBorrowedFundTitle()
    }
    let baseFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageUsedBasefundTitle()
    }

    let cancleButton = UIButton().then {
        $0.setTitle(R.string.localizable.defiUsePageCloseSvip(), for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.setTitleColor(.white, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.highlighted.resizable, for: .highlighted)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bgColoredLable)
        contentView.addSubview(seperator)
        contentView.addSubview(amountLabel)
        contentView.addSubview(untilLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(borrowedFundLabel)
        contentView.addSubview(baseFundLabel)
        contentView.addSubview(cancleButton)

        icon.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalToSuperview().offset(22)
            m.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(icon.snp.trailing).offset(3)
            m.centerY.equalTo(icon)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        bgColoredLable.snp.makeConstraints { (m) in
            m.trailing.equalToSuperview().offset(-23)
            m.centerY.equalTo(icon)
            m.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(10)
        }

        seperator.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(23)
            m.top.equalTo(icon.snp.bottom).offset(10)
            m.height.equalTo(1)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        untilLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(amountLabel.snp.trailing).offset(2)
            m.centerY.equalTo(amountLabel)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(contentView.snp.centerX)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        amountTitleLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        timeTitleLabel.snp.makeConstraints { (m) in
             m.leading.equalTo(timeLabel)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        borrowedFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountTitleLabel.snp.bottom).offset(10)
        }

        baseFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(borrowedFundLabel.snp.bottom).offset(6)
        }

        cancleButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(baseFundLabel)
            m.trailing.equalTo(contentView).offset(-24)
//            m.width.equalTo(76)
            m.height.equalTo(26)
        }

        let bottomseperator = UIView().then { (view) in
            view.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
        }
        contentView.addSubview(bottomseperator)
        bottomseperator.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.height.equalTo(0.5)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class DefiUsageForQuotalCell: BaseTableViewCell ,ListCellable {

    func bind(_ item: DefiUsageInfo) {
        bgColoredLable.text = " " + R.string.localizable.peldgeAddressTitle() + ": " + (item.usageInfo.quotaAddress  ?? "") + " "
        amountLabel.text = item.amountInfo.baseAmount.amountShort(decimals: decimals)
        timeLabel.text = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(item.usageTime)))
        borrowedFundLabel.text = R.string.localizable.defiUsePageUsedBorrowedFundTitle() + item.amountInfo.loanAmount.amountShort(decimals: decimals)
        baseFundLabel.text = R.string.localizable.defiUsePageUsedBasefundTitle() + item.amountInfo.baseAmount.amountShort(decimals: decimals)
        disposeBag = DisposeBag()
        self.cancleButton.rx.tap.bind { _ in

            Alert.show(title: R.string.localizable.defiUsePageEditQuotalCancleTitle(),
                               message: "\(R.string.localizable.defiUsePageEditCanCancleAmount()) \(item.usageInfo.pledgeAmount.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals)) VITE。\n\(R.string.localizable.defiUsePageEditQuotalCancleDesc())",
                actions: [
                       (.default(title: R.string.localizable.defiUsePageEditCancleCancle()), nil),
                       (.default(title: R.string.localizable.defiUsePageEditCancleConfirm()), {[weak self] _ in
                        Workflow.defiCancelInvestWithConfirm(
                            account: HDWalletManager.instance.account!,
                            tokenInfo: TokenInfo.BuildIn.vite.value,
                            investId: UInt64(item.usageHash)!) { (result) in
                                switch result {
                                case .success(_):
                                    break
                                case .failure(let e):
                                    Toast.show(e.localizedDescription)
                                }

                        }
                       }),
                       ])

        }.disposed(by: disposeBag)

    }

     static var cellHeight: CGFloat = 162

     typealias Model = DefiUsageInfo

    let icon = UIImageView().then {
        $0.image = R.image.defi_use_quoto()
    }
    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x77808A)
        $0.text = R.string.localizable.defiUsePageGetQouto()
    }
    let bgColoredLable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "  "
        $0.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
        $0.layer.cornerRadius = 1
    }

    let seperator = UIImageView(image: R.image.icon_my_loan_cell_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

    let amountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let untilLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        $0.text = "VITE"
    }
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let amountTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageQoutoFund()
    }
    let timeTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageGussesedDeadlineTime()
    }
    let borrowedFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageUsedBorrowedFundTitle()
    }
    let baseFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageUsedBasefundTitle()
    }


    let cancleButton = UIButton().then {
        $0.setTitle(R.string.localizable.defiUsePageCancleQouto(), for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.setTitleColor(.white, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.highlighted.resizable, for: .highlighted)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bgColoredLable)
        contentView.addSubview(seperator)
        contentView.addSubview(amountLabel)
        contentView.addSubview(untilLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(borrowedFundLabel)
        contentView.addSubview(baseFundLabel)
        contentView.addSubview(cancleButton)

        icon.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalToSuperview().offset(22)
            m.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(icon.snp.trailing).offset(3)
            m.centerY.equalTo(icon)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        bgColoredLable.snp.makeConstraints { (m) in
            m.trailing.equalToSuperview().offset(-23)
            m.centerY.equalTo(icon)
            m.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(10)
        }

        seperator.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(23)
            m.top.equalTo(icon.snp.bottom).offset(10)
            m.height.equalTo(1)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        untilLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(amountLabel.snp.trailing).offset(2)
            m.centerY.equalTo(amountLabel)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(contentView.snp.centerX)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        amountTitleLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        timeTitleLabel.snp.makeConstraints { (m) in
             m.leading.equalTo(timeLabel)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        borrowedFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountTitleLabel.snp.bottom).offset(10)
        }

        baseFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(borrowedFundLabel.snp.bottom).offset(6)
        }


        cancleButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(baseFundLabel)
            m.trailing.equalTo(contentView).offset(-24)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

        let bottomseperator = UIView().then { (view) in
            view.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
        }
        contentView.addSubview(bottomseperator)
        bottomseperator.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.height.equalTo(0.5)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class DefiUsageForMinningCell: BaseTableViewCell ,ListCellable {

    func bind(_ item: DefiUsageInfo) {
       bgColoredLable.text = " "
        amountLabel.text = item.amountInfo.baseAmount.amountShort(decimals: decimals)
        timeLabel.text = dateFormatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(item.usageTime)))
        borrowedFundLabel.text = R.string.localizable.defiUsePageUsedBorrowedFundTitle() + item.amountInfo.loanAmount.amountShort(decimals: decimals)
        baseFundLabel.text = R.string.localizable.defiUsePageUsedBasefundTitle() + item.amountInfo.baseAmount.amountShort(decimals: decimals)

        self.editButton.rx.tap.bind { [unowned self] _ in
            func vitexPageUrl() -> URL {
                var urlStr = ViteConst.instance.vite.viteXUrl + "#/assets"
                    + "?address=" + (HDWalletManager.instance.account?.address ?? "")
                    + "&currency=" + AppSettingsService.instance.appSettings.currency.rawValue
                urlStr += "&activeTab=miningStaking"
                return URL.init(string:urlStr)!
            }
            let webvc = WKWebViewController(url: vitexPageUrl())
            var vcs = UIViewController.current?.navigationController?.viewControllers
            vcs?.append(webvc)
            if let vcs = vcs {
                UIViewController.current?.navigationController?.setViewControllers(vcs, animated: true)
            }
        }.disposed(by: disposeBag)

        self.cancleButton.rx.tap.bind { _ in

            Alert.show(title: R.string.localizable.defiUsePageEditMinningCancleTitle(), message: "\(R.string.localizable.defiUsePageEditCanCancleAmount()) \(item.usageInfo.pledgeAmount.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals)) VITE。\n\(R.string.localizable.defiUsePageEditMinningCancleDesc())", actions: [
                       (.default(title: R.string.localizable.defiUsePageEditMinningcancleConfirm()), {[weak self] _ in
                                Workflow.defiCancelInvestWithConfirm(
                                    account: HDWalletManager.instance.account!,
                                    tokenInfo: TokenInfo.BuildIn.vite.value,
                                    investId: UInt64(item.usageHash)!) { (result) in
                                        switch result {
                                        case .success(_):
                                            break
                                        case .failure(let e):
                                            Toast.show(e.localizedDescription)
                                        }

                                }


                       }),
                       (.default(title: R.string.localizable.defiUsePageEditMinningCancleCancle()), nil),
                       ])

        }.disposed(by: disposeBag)
    }

     static var cellHeight: CGFloat = 162

     typealias Model = DefiUsageInfo

    let icon = UIImageView().then {
        $0.image = R.image.defi_use_minning()
    }
    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x77808A)
        $0.text = R.string.localizable.defiBillBillTypeTitleMinning()
    }
    let bgColoredLable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "  "
//        $0.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
        $0.layer.cornerRadius = 1
    }

    let seperator = UIImageView(image: R.image.icon_my_loan_cell_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

    let amountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let untilLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.8)
        $0.text = "VITE"
    }
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "0"
    }
    let amountTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageQoutoFund()
    }
    let timeTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageGussesedDeadlineTime()
    }
    let borrowedFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageUsedBorrowedFundTitle()
    }
    let baseFundLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = R.string.localizable.defiUsePageUsedBasefundTitle()
    }

    let editButton = UIButton().then {
        $0.setTitle(R.string.localizable.defiUsePageViewMinningReward(), for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        $0.setTitleColor(UIColor.init(netHex: 0x007AFF), for: .normal)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.setBackgroundImage(UIImage.image(withColor: .white, cornerRadius: 13, borderColor: nil, borderWidth: 0).resizable, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        $0.layer.cornerRadius = 13
        
        $0.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 5, height: 5)
        $0.layer.shadowRadius = 5
    }

    let cancleButton = UIButton().then {
        $0.setTitle(R.string.localizable.defiUsePageViewStopMinning(), for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.setTitleColor(.white, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_button_frame_blue()?.highlighted.resizable, for: .highlighted)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bgColoredLable)
        contentView.addSubview(seperator)
        contentView.addSubview(amountLabel)
        contentView.addSubview(untilLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(amountTitleLabel)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(borrowedFundLabel)
        contentView.addSubview(baseFundLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(cancleButton)

        icon.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalToSuperview().offset(22)
            m.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(icon.snp.trailing).offset(3)
            m.centerY.equalTo(icon)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        bgColoredLable.snp.makeConstraints { (m) in
            m.trailing.equalToSuperview().offset(-23)
            m.centerY.equalTo(icon)
            m.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(10)
        }

        seperator.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(23)
            m.top.equalTo(icon.snp.bottom).offset(10)
            m.height.equalTo(1)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        untilLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(amountLabel.snp.trailing).offset(2)
            m.centerY.equalTo(amountLabel)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(contentView.snp.centerX)
            m.top.equalTo(seperator.snp.bottom).offset(9)
        }

        amountTitleLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        timeTitleLabel.snp.makeConstraints { (m) in
             m.leading.equalTo(timeLabel)
            m.top.equalTo(amountLabel.snp.bottom).offset(2)
        }

        borrowedFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(amountTitleLabel.snp.bottom).offset(10)
        }

        baseFundLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(23)
            m.top.equalTo(borrowedFundLabel.snp.bottom).offset(6)
        }


        editButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(baseFundLabel)
            m.trailing.equalTo(contentView).offset(-106)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

        cancleButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(baseFundLabel)
            m.trailing.equalTo(contentView).offset(-24)
            m.width.equalTo(76)
            m.height.equalTo(26)
        }

        let bottomseperator = UIView().then { (view) in
            view.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
        }
        contentView.addSubview(bottomseperator)
        bottomseperator.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.height.equalTo(0.5)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
