//
//  ConfirmEthViteExchangeViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

struct ConfirmEthViteExchangeViewModel: ConfirmViewModelType {

    private let tokenInfo: TokenInfo
    private let addressString: String
    private let feeString: String
    private let amountString: String

    init(tokenInfo: TokenInfo, addressString: String, amountString: String, feeString: String) {
        self.tokenInfo = tokenInfo
        self.addressString = addressString
        self.amountString = amountString
        self.feeString = feeString
    }

    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPageEthViteExchangeTitle()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageEthViteExchangeConfirmButton()
    }

    func createInfoView() -> UIView {
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }

        let infoView = ConfirmEthViteExchangeInfoView()
        let amountView = ConfirmAmountView(type: .amount)
        let feeView = ConfirmAmountView(type: .fee)

        stackView.addArrangedSubview(infoView)
        stackView.addPlaceholder(height: 15)
        stackView.addArrangedSubview(amountView)
        stackView.addArrangedSubview(feeView)

        infoView.set(title: R.string.localizable.confirmTransactionAddressTitle(), detail: addressString)
        amountView.set(text: amountString)
        feeView.set(text: feeString)

        return stackView
    }
}

fileprivate class ConfirmEthViteExchangeInfoView: UIView {

    fileprivate let titleLabel = UILabel().then {
        $0.text = R.string.localizable.confirmTransactionAddressTitle()
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
    }

    fileprivate let detailLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor.init(netHex: 0x24272B, alpha: 0.7)
        $0.numberOfLines = 2
        $0.adjustsFontSizeToFitWidth = true
    }

    fileprivate let tokenIconView = UIImageView(image: R.image.icon_vite_exchange())

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(tokenIconView)


        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.leading.equalToSuperview().offset(24)
            m.trailing.equalToSuperview().offset(-24)
        }

        detailLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(24)
            m.top.equalTo(titleLabel.snp.bottom).offset(12)
        }

        tokenIconView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(21)
            make.trailing.equalToSuperview().offset(-24)
            make.leading.equalTo(detailLabel.snp.trailing).offset(16)
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.bottom.equalToSuperview()
        }
    }

    func set(title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
