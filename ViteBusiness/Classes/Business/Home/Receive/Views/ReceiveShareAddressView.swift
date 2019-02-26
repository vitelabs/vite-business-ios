//
//  ReceiveShareAddressView.swift
//  Vite
//
//  Created by Stone on 2018/9/26.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ReceiveShareAddressView: UIView {

    fileprivate let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.textAlignment = .center
    }

    fileprivate lazy var addressBackView = UIView().then { view in
        view.backgroundColor = UIColor(netHex: 0xF3F5F9)
    }

    fileprivate let addressNameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
    }

    fileprivate let addressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.numberOfLines = 2
    }

    init(name: String, address: String, addressName: String?) {
        super.init(frame: CGRect.zero)

        nameLabel.text = name
        setupAddressBackView(name: addressName, address: address)

        addSubview(nameLabel)
        addSubview(addressBackView)

        nameLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self).offset(22)
            m.left.equalTo(self).offset(24)
            m.right.equalTo(self).offset(-24)
        }

        addressBackView.snp.makeConstraints { (m) in
            m.top.equalTo(nameLabel.snp.bottom).offset(20)
            m.left.equalTo(self).offset(24)
            m.right.equalTo(self).offset(-24)
            m.bottom.equalTo(self)
        }
    }

    func setupAddressBackView(name: String?, address: String) {

        if let name = name {

            addressBackView.addSubview(addressNameLabel)
            addressBackView.addSubview(addressLabel)

            addressNameLabel.text = name
            addressLabel.text = address

            addressNameLabel.snp.makeConstraints { (m) in
                m.top.equalTo(addressBackView).offset(8)
                m.left.equalTo(addressBackView).offset(16)
                m.right.equalTo(addressBackView).offset(-16)
                m.height.equalTo(22)
            }

            addressLabel.snp.makeConstraints { (m) in
                m.top.equalTo(addressNameLabel.snp.bottom)
                m.left.equalTo(addressBackView).offset(16)
                m.right.equalTo(addressBackView).offset(-16)
                m.bottom.equalTo(addressBackView).offset(-10)
            }

        } else {

            addressBackView.addSubview(addressLabel)
            addressLabel.text = address

            addressLabel.snp.makeConstraints { (m) in
                m.top.equalTo(addressBackView).offset(10)
                m.left.equalTo(addressBackView).offset(16)
                m.right.equalTo(addressBackView).offset(-16)
                m.bottom.equalTo(addressBackView).offset(-10)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
