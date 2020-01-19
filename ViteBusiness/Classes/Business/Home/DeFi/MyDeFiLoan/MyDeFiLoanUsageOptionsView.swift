//
//  MyDeFiLoanUsageOptionsView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/24.
//

import Foundation

class MyDeFiLoanUsageOptionsView: VisualEffectAnimationView {

    fileprivate let whiteView = UIView().then {
        $0.backgroundColor = .white
    }
    fileprivate let containerView: UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }

    let clicked: (DeFiLoanUsageOption) -> ()

    init(options: [DeFiLoanUsageOption], clicked: @escaping (DeFiLoanUsageOption) -> ()) {
        self.clicked = clicked
        guard let superView = UIViewController.current?.navigationController?.view else { fatalError() }
        super.init(superview: superView, style: .color(color: UIColor(netHex: 0x04040F, alpha: 0.4)))

        let animationView = UIView().then {
            $0.backgroundColor = whiteView.backgroundColor
        }

        contentView.addSubview(animationView)
        contentView.addSubview(whiteView)

        animationView.snp.makeConstraints { (m) in
            m.top.equalTo(whiteView)
            m.left.right.bottom.equalToSuperview()
        }

        whiteView.snp.makeConstraints { (m) in
            m.top.equalTo(contentView.snp.bottom)
            m.left.right.equalToSuperview()
        }

        whiteView.addSubview(containerView)
        containerView.snp.makeConstraints { (m) in
            m.top.left.right.bottom.equalToSuperview()
        }

        let cancelButton = UIButton().then {
            $0.setTitle(R.string.localizable.cancel(), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x24272B), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x24272B).highlighted, for: .highlighted)
            $0.backgroundColor = .white
        }

        cancelButton.snp.makeConstraints { $0.height.equalTo(56) }
        cancelButton.rx.tap.bind { [weak self] in
            self?.hide()
        }.disposed(by: rx.disposeBag)

        options.forEach {
            containerView.addArrangedSubview(button(option: $0))
        }

        containerView.addArrangedSubview(cancelButton)
    }

    func button(option: DeFiLoanUsageOption) -> UIView {
        if option.usable {
            let button = UIButton().then {
                $0.setTitle(option.name, for: .normal)
                $0.setTitleColor(UIColor(netHex: 0x24272B), for: .normal)
                $0.setTitleColor(UIColor(netHex: 0x24272B).highlighted, for: .highlighted)
                $0.backgroundColor = .white
            }

            let line = UIView()
            line.backgroundColor = UIColor(netHex: 0xD3DFEF)
            button.addSubview(line)
            line.snp.makeConstraints { (m) in
                m.height.equalTo(CGFloat.singleLineWidth)
                m.left.right.bottom.equalToSuperview()
            }

            button.snp.makeConstraints { $0.height.equalTo(56) }
            button.rx.tap.bind { [weak self] in
                self?.clicked(option)
                self?.hide()
            }.disposed(by: rx.disposeBag)
            return button
        } else {
            let view = UIView().then {
                $0.backgroundColor = .white
            }
            let line = UIView()
            line.backgroundColor = UIColor(netHex: 0xD3DFEF)
            view.addSubview(line)
            line.snp.makeConstraints { (m) in
                m.height.equalTo(CGFloat.singleLineWidth)
                m.left.right.bottom.equalToSuperview()
            }

            view.snp.makeConstraints { $0.height.equalTo(56) }


            let titleLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
                $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                $0.text = option.name
                $0.textAlignment = .center
            }

            let resonLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
                $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                $0.text = option.unusableReason
                $0.textAlignment = .center
            }

            view.addSubview(titleLabel)
            view.addSubview(resonLabel)

            titleLabel.snp.makeConstraints { (m) in
                m.top.left.right.equalToSuperview().inset(10)
            }

            resonLabel.snp.makeConstraints { (m) in
                m.bottom.equalToSuperview().inset(6)
                m.left.right.equalToSuperview().inset(10)
            }

            return view
        }
    }

    public override func show(animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        contentView.layoutIfNeeded()
        whiteView.snp.remakeConstraints { (m) in
            m.bottom.equalTo(contentView.safeAreaLayoutGuideSnpBottom)
            m.left.right.equalToSuperview()
        }

        super.show(animations: { [weak self] in
            guard let `self` = self else { return }
            self.contentView.layoutIfNeeded()
            if let a = animations { a() }
            }, completion: completion)
    }

    public override func hide(animations: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        contentView.layoutIfNeeded()
        whiteView.snp.remakeConstraints { (m) in
            m.top.equalTo(contentView.snp.bottom)
            m.left.right.equalToSuperview()
        }
        super.hide(animations: { [weak self] in
            guard let `self` = self else { return }
            self.contentView.layoutIfNeeded()
            if let a = animations { a() }
            }, completion: {
                if let c = completion { c() }
        })
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
