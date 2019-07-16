//
//  BalanceInfoViteCoinOperationView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/2/28.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class BalanceInfoViteCoinOperationView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 44)
    }

    let voteButton = OperationButton(icon: R.image.icon_balance_detail_vote(), title: R.string.localizable.balanceInfoDetailVote())
    let pledgeButton = OperationButton(icon: R.image.icon_balance_detail_pledge(), title: R.string.localizable.balanceInfoDetailPledge())

    override init(frame: CGRect) {
        super.init(frame: frame)


        clipsToBounds = false
        
        addSubview(voteButton)
        addSubview(pledgeButton)

        voteButton.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalToSuperview()
        }

        pledgeButton.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalTo(voteButton.snp.right).offset(15)
            m.right.equalToSuperview()
            m.width.equalTo(voteButton)
        }

        voteButton.button.rx.tap.bind {
            Statistics.log(eventId: Statistics.Page.WalletHome.voteClicked.rawValue)
            let sendViewController = VoteHomeViewController()
            UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            }.disposed(by: rx.disposeBag)
        
        pledgeButton.button.rx.tap.bind {
            Statistics.log(eventId: Statistics.Page.WalletHome.quotaClicked.rawValue)
            let sendViewController = QuotaManageViewController()
            UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


class OperationButton: UIView {

    enum Style {
        case multiple
        case single
    }

    let button = UIButton().then {
        $0.setBackgroundImage(nil, for: .normal)
        $0.setBackgroundImage(UIImage.color(UIColor.white.withAlphaComponent(0.2)), for: .highlighted)
    }


    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 44)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(icon: UIImage?, title: String, style: Style = .multiple) {
        super.init(frame: CGRect.zero)
        setShadow(width: 0, height: 2, radius: 10)

        let imageView = UIImageView()

        let vLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xe5e5ea)
        }

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x007AFF)
            $0.numberOfLines = 2
            $0.textAlignment = .center
        }

        imageView.image = icon
        titleLabel.text = title

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(button)

        button.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        switch style {
        case .multiple:

            addSubview(vLine)

            imageView.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.left.equalToSuperview().offset(14)
                m.size.equalTo(CGSize(width: 20, height: 20))
            }

            vLine.snp.makeConstraints { (m) in
                m.width.equalTo(CGFloat.singleLineWidth)
                m.left.equalTo(imageView.snp.right).offset(10)
                m.top.equalToSuperview().offset(10)
                m.bottom.equalToSuperview().offset(-10)
            }

            titleLabel.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.left.equalTo(vLine.snp.right).offset(5)
                m.right.equalToSuperview().offset(-5)
            }

        case .single:

            let guide = UILayoutGuide()
            addLayoutGuide(guide)

            guide.snp.makeConstraints { (m) in
                m.center.equalTo(self)
            }

            imageView.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.size.equalTo(CGSize(width: 20, height: 20))
                m.left.equalTo(guide)
            }

            titleLabel.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.left.equalTo(imageView.snp.right).offset(16)
                m.right.equalTo(guide)
            }
        }
    }
}
