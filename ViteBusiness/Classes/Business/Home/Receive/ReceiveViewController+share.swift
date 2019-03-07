//
//  ReceiveViewController+share.swift
//  Action
//
//  Created by Stone on 2019/2/25.
//

import ViteWallet

extension ReceiveViewController {
    func share(viewModel: ReceiveViewModelType) {

        let superView = UIView()
        let backView = UIView()

        let contentView = UIImageView(image: R.image.background_button_white()?.resizable).then {
            $0.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowOffset = CGSize(width: 0, height: 5)
            $0.layer.shadowRadius = 20
        }

        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }

        superView.addSubview(backView)
        backView.snp.makeConstraints { (m) in
            m.center.equalTo(superView)
            m.width.equalTo(375)
        }

        backView.addSubview(contentView)
        backView.addSubview(stackView)
        contentView.snp.makeConstraints { (m) in
            m.top.equalTo(backView).offset(70)
            m.left.equalTo(backView).offset(24)
            m.right.equalTo(backView).offset(-24)
            m.bottom.equalTo(backView).offset(-70)
        }

        stackView.snp.makeConstraints { (m) in
            m.edges.equalTo(contentView)
        }

        let addressView = ReceiveShareAddressView(name: viewModel.walletName, address: viewModel.address, addressName: viewModel.addressName)
        let tokenView = UIView()
        let qrcodeView = UIView()
        let noteView = ReceiveShareNoteView(text: self.noteView.noteTitleTextFieldView.textField.text)

        let tokenSymbolLabel = UILabel().then {
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x24272B)
            $0.numberOfLines = 0
            $0.text = self.qrcodeView.tokenSymbolLabel.text

            tokenView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(tokenView).offset(28)
                m.left.equalTo(tokenView).offset(24)
                m.right.equalTo(tokenView).offset(-24)
                m.bottom.equalTo(tokenView)
            }
        }

        let qrcodeImageView = UIImageView(image: self.qrcodeView.imageView.screenshot).then {
            qrcodeView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(qrcodeView).offset(28)
                m.center.equalTo(qrcodeView)
                m.size.equalTo(CGSize(width: 170, height: 170))
                m.bottom.equalTo(qrcodeView).offset(-20)
            }
        }

        stackView.addArrangedSubview(addressView)
        stackView.addArrangedSubview(tokenView)
        stackView.addArrangedSubview(qrcodeView)

        if viewModel.isShowNoteView {
            stackView.addArrangedSubview(noteView)
        } else {
            stackView.addPlaceholder(height: 20)
        }

        let layoutGuide = UILayoutGuide()
        let iconImageView = UIImageView(image: R.image.icon_receive_logo())
        let label = UILabel()
        label.text = R.string.localizable.receivePageWalletName()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        backView.addLayoutGuide(layoutGuide)
        backView.addSubview(iconImageView)
        backView.addSubview(label)

        layoutGuide.snp.makeConstraints { (m) in
            m.top.equalTo(contentView.snp.bottom)
            m.bottom.equalTo(backView)
            m.centerX.equalTo(backView)
        }

        iconImageView.snp.makeConstraints { (m) in
            m.centerY.left.equalTo(layoutGuide)
        }

        label.snp.makeConstraints { (m) in
            m.right.equalTo(layoutGuide)
            m.centerY.equalTo(iconImageView)
            m.left.equalTo(iconImageView.snp.right).offset(10)
        }

        superView.setNeedsLayout()
        superView.layoutIfNeeded()
        backView.backgroundColor = UIColor.gradientColor(style: .top2bottom, frame: backView.frame, colors: tokenInfo.chainBackgroundGradientColors)
        guard let image = backView.screenshot else { return }
        Workflow.share(activityItems: [image])
    }
}

