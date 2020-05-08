//
//  SocialCell.swift
//  ViteBusiness
//
//  Created by Stone on 2020/5/8.
//

import Foundation

class SocialCell: BaseTableViewCell {
    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
    }

    let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 20
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)


        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(20)
            m.left.right.equalToSuperview().inset(24)
        }

        stackView.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(10)
            m.left.right.equalToSuperview().inset(24)
            m.height.equalTo(32)
            m.bottom.equalToSuperview().offset(-16)
        }
    }

    func set(_ values: [(image: UIImage?, url: URL)]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
        }

        values.forEach { value in
            let button = UIButton()
            button.setImage(value.image, for: .normal)
            button.setImage(value.image?.highlighted, for: .highlighted)
            button.snp.makeConstraints { m in m.size.equalTo(CGSize(width: 32, height: 32)) }
            button.rx.tap.bind { WebHandler.open(value.url) }.disposed(by: disposeBag)
            stackView.addArrangedSubview(button)
        }

        let view = UIView()
        view.backgroundColor = .clear
        view.snp.makeConstraints { m in m.size.equalTo(CGSize(width: 32, height: 800)).priority(.low) }
        stackView.addArrangedSubview(view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
