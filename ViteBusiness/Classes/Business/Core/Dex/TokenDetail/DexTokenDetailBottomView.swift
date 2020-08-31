//
//  DexTokenDetailBottomView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/31.
//

import Foundation
import RxSwift
import RxCocoa

class DexTokenDetailBottomView: UIView {

    init(tokenInfo: TokenInfo, type: DexAssetsHomeViewController.PType) {
        super.init(frame: CGRect.zero)

        var buttons = [Button]()

        switch type {
        case .wallet:

            let deposit = Button(text: R.string.localizable.dexTokenDetailPageButtonDeposit(), image: R.image.icon_dex_token_deposit())
            let withdraw = Button(text: R.string.localizable.dexTokenDetailPageButtonWithdraw(), image: R.image.icon_dex_token_withdraw())
            let transfer = Button(text: R.string.localizable.dexTokenDetailPageButtonTransfer(), image: R.image.icon_dex_token_transfer())
            let send = Button(text: R.string.localizable.dexTokenDetailPageButtonSend(), image: R.image.icon_dex_token_send())

            if tokenInfo.gatewayInfo != nil {
                buttons.append(deposit)
                buttons.append(withdraw)
            }

            buttons.append(transfer)
            buttons.append(send)

            deposit.button.rx.tap.bind {
                let vc = CrossChainStatementViewController(tokenInfo: tokenInfo)
                vc.isWithDraw = false
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

            withdraw.button.rx.tap.bind {
                let vc = CrossChainStatementViewController(tokenInfo: tokenInfo)
                vc.isWithDraw = true
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

            transfer.button.rx.tap.bind {
                let vc = ManageViteXBanlaceViewController(tokenInfo: tokenInfo)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

            send.button.rx.tap.bind {
                let vc = SendViewController(tokenInfo: tokenInfo, address: nil, amount: nil, data: nil)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

        case .vitex:
            let transfer = Button(text: R.string.localizable.dexTokenDetailPageButtonTransfer(), image: R.image.icon_dex_token_transfer())
            let trading = Button(text: R.string.localizable.dexTokenDetailPageButtonTrading(), image: R.image.icon_dex_token_trading())

            buttons.append(transfer)
            buttons.append(trading)

            transfer.button.rx.tap.bind {
                let vc = ManageViteXBanlaceViewController(tokenInfo: tokenInfo)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

            trading.button.rx.tap.bind {
                
            }.disposed(by: rx.disposeBag)
        }

        if buttons.count == 4 {
            let guide = UILayoutGuide()
            addLayoutGuide(guide)
            guide.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(12)
                m.left.right.equalToSuperview().inset(24)
                m.bottom.equalToSuperview()
            }

            buttons.forEach {
                addSubview($0)
            }

            let g1 = UIView()
            let g2 = UIView()
            let g3 = UIView()

            g1.setContentHuggingPriority(.defaultLow, for: .horizontal)
            g2.setContentHuggingPriority(.defaultLow, for: .horizontal)
            g3.setContentHuggingPriority(.defaultLow, for: .horizontal)

            addSubview(g1)
            addSubview(g2)
            addSubview(g3)

            buttons[0].snp.makeConstraints { (m) in
                m.top.equalTo(guide)
                m.left.equalTo(guide)
            }

            g1.snp.makeConstraints { (m) in
                m.top.bottom.equalTo(guide)
                m.left.equalTo(buttons[0].snp.right)
            }

            buttons[1].snp.makeConstraints { (m) in
                m.top.equalTo(guide)
                m.left.equalTo(g1.snp.right)
            }

            g2.snp.makeConstraints { (m) in
                m.top.bottom.equalTo(guide)
                m.left.equalTo(buttons[1].snp.right)
                m.width.equalTo(g1)
            }

            buttons[2].snp.makeConstraints { (m) in
                m.top.equalTo(guide)
                m.left.equalTo(g2.snp.right)
            }

            g3.snp.makeConstraints { (m) in
                m.top.bottom.equalTo(guide)
                m.left.equalTo(buttons[2].snp.right)
                m.width.equalTo(g1)
            }

            buttons[3].snp.makeConstraints { (m) in
                m.top.equalTo(guide)
                m.left.equalTo(g3.snp.right)
                m.right.equalTo(guide)
            }
        } else if buttons.count == 2 {
            buttons.forEach {
                addSubview($0)
            }

            buttons[0].snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(12)
                m.left.equalToSuperview().offset(74)
            }

            buttons[1].snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(12)
                m.right.equalToSuperview().offset(-74)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension DexTokenDetailBottomView {
    class Button: UIStackView {

        let button = UIButton()

        let label = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0xA1A9CB)
            $0.textAlignment = .center
        }

        init(text: String, image: UIImage?) {
            super.init(frame: CGRect.zero)

            axis = .vertical
            alignment = .center
            distribution = .fill
            spacing = 2

            label.text = text
            button.setImage(image, for: .normal)
            button.setImage(image?.highlighted, for: .highlighted)

            addArrangedSubview(button)
            addArrangedSubview(label)

            button.snp.makeConstraints { (m) in
                m.size.equalTo(CGSize(width: 40, height: 40))
            }
        }

        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
