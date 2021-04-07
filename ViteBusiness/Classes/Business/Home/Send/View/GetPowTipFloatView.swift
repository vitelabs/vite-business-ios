//
//  GetPowTipFloatView.swift
//  ViteBusiness
//
//  Created by stone on 2021/3/31.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import DACircularProgress

class GetPowTipFloatView: VisualEffectAnimationView {

    fileprivate let containerView: UIView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }

    fileprivate let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x242728)
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.text = R.string.localizable.quotaPowTipFloatViewTitle()
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    lazy fileprivate var h1Label = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    let pledgeButton = UIButton(style: .blue, title: R.string.localizable.quotaPowTipFloatViewPledge())
    let notNewButton = UIButton().then {
        $0.setTitle(R.string.localizable.quotaPowTipFloatViewNotNow(), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
    let onlyPledgeButton = UIButton().then {
        $0.setTitle(R.string.localizable.quotaPowTipFloatViewPledge(), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }

    let cancelButton = UIButton().then {
        $0.setImage(R.image.icon_quota_close(), for: .normal)
        $0.setImage(R.image.icon_quota_close()?.highlighted, for: .highlighted)
    }

    init(superview: UIView, address: String, pledgeClick: @escaping () -> Void, notNowClick: @escaping () -> Void, cancelClick: @escaping () -> Void) {
        super.init(superview: superview)

        isEnableTapDismiss = false

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(h1Label)
        containerView.addSubview(cancelButton)

        containerView.snp.makeConstraints { (m) in
            m.center.equalTo(contentView)
            m.width.equalTo(270)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(24)
            m.left.equalToSuperview().offset(16)
            m.right.equalToSuperview().offset(-16)
        }


        h1Label.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(12)
            m.left.right.equalTo(titleLabel)
        }

        cancelButton.snp.makeConstraints { (m) in
            m.top.right.equalToSuperview()
            m.size.equalTo(CGSize(width: 39, height: 39))
        }
        
        if PowManager.instance.canGetPow(address: address) {
            
            h1Label.text = R.string.localizable.quotaPowTipFloatViewMessage2()
            
            containerView.addSubview(pledgeButton)
            containerView.addSubview(notNewButton)
            
            pledgeButton.snp.makeConstraints { (m) in
                m.top.equalTo(h1Label.snp.bottom).offset(12)
                m.height.equalTo(50)
                m.left.right.equalToSuperview().inset(16)
            }
            
            notNewButton.snp.makeConstraints { (m) in
                m.top.equalTo(pledgeButton.snp.bottom)
                m.height.equalTo(44)
                m.left.right.equalToSuperview().inset(16)
                m.bottom.equalToSuperview()
            }
        } else {
            
            h1Label.text = R.string.localizable.quotaPowTipFloatViewMessage1(String(AppConfigService.instance.getPowTimesPreDay))
            
            containerView.addSubview(onlyPledgeButton)
            
            onlyPledgeButton.snp.makeConstraints { (m) in
                m.top.equalTo(h1Label.snp.bottom).offset(12)
                m.height.equalTo(49)
                m.left.right.bottom.equalToSuperview()
            }

            let line = UIView().then {
                $0.backgroundColor = Colors.lineGray
            }

            containerView.addSubview(line)
            line.snp.makeConstraints { (m) in
                m.height.equalTo(CGFloat.singleLineWidth)
                m.left.right.equalToSuperview()
                m.bottom.equalTo((onlyPledgeButton).snp.top)
            }
        }
        
        onlyPledgeButton.rx.tap.bind { [weak self] in
            self?.hide()
            pledgeClick()
            }.disposed(by: rx.disposeBag)

        pledgeButton.rx.tap.bind { [weak self] in
            self?.hide()
            pledgeClick()
            }.disposed(by: rx.disposeBag)
        
        notNewButton.rx.tap.bind { [weak self] in
            self?.hide()
            PowManager.instance.update(address: address)
            notNowClick()
            }.disposed(by: rx.disposeBag)
        cancelButton.rx.tap.bind { [weak self] in
            self?.hide()
            cancelClick()
            }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
