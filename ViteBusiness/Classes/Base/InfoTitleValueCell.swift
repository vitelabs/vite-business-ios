//
//  InfoTitleValueCell.swift
//  ViteBusiness
//
//  Created by Stone on 2020/5/8.
//

import Foundation

class InfoTitleValueCell: BaseTableViewCell {

    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
    }

    let valueLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 0
    }

    let button = UIButton().then {
        $0.backgroundColor = .clear
    }

    var url: URL?
    var clicked: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(button)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(20)
            m.left.right.equalToSuperview().inset(24)
        }

        valueLabel.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(10)
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalToSuperview().offset(-12)
        }

        button.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        let hLine = UIView().then { $0.backgroundColor = Colors.lineGray}
        contentView.addSubview(hLine)
        hLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalTo(contentView)
        }

        button.rx.tap.bind { [weak self] in
            if let clicked = self?.clicked {
                clicked()
            } else if let url = self?.url {
                WebHandler.open(url)
            }
        }.disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String, text: String, url: URL? = nil, clicked: (() -> Void)? = nil) {
        titleLabel.text = title
        valueLabel.text = text

        self.url = url
        self.clicked = clicked

        if url != nil || clicked != nil {
            valueLabel.textColor = UIColor(netHex: 0x007AFF)
            button.isHidden = false
        } else {
            valueLabel.textColor = UIColor(netHex: 0x24272B)
            button.isHidden = true
        }

        button.isEnabled = (url != nil || clicked != nil)
    }
}
