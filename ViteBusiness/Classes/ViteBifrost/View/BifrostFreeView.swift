//
//  BifrostFreeView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import UIKit

class BifrostFreeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        let imageView = UIImageView(image: R.image.icon_vb_placeholder_free())
        let headerLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x24272B)
            $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        let contentLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x24272B, alpha: 0.6)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }

        headerLabel.text = R.string.localizable.bifrostHomePageFreeHeader()
        contentLabel.text = R.string.localizable.bifrostHomePageFreeContent()

        addSubview(imageView)
        addSubview(headerLabel)
        addSubview(contentLabel)

        imageView.snp.makeConstraints { (m) in
            m.top.centerX.equalToSuperview()
        }

        headerLabel.snp.makeConstraints { (m) in
            m.top.equalTo(imageView.snp.bottom).offset(20)
            m.left.equalToSuperview().offset(15)
            m.right.equalToSuperview().offset(-15)
        }

        contentLabel.snp.makeConstraints { (m) in
            m.top.equalTo(headerLabel.snp.bottom).offset(10)
            m.left.equalToSuperview().offset(15)
            m.right.equalToSuperview().offset(-15)
            m.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
