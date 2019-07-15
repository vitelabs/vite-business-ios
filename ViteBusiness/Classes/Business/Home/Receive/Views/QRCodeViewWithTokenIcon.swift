//
//  QRCodeViewWithTokenIcon.swift
//  Action
//
//  Created by haoshenyang on 2019/6/14.
//

import Foundation
import ViteWallet

class QRCodeViewWithTokenIcon: UIView{

    let imageView = UIImageView()
    let iconView = TokenIconView()


    func bind(tokenInfo: TokenInfo, content: String) {
        QRCodeHelper.createQRCode(string: content) { (image) in
            self.imageView.image = image
        }

        self.iconView.tokenInfo = tokenInfo
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)

        imageView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        imageView.addSubview(iconView)
        iconView.set(cornerRadius: 20)
        iconView.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
            m.size.equalTo(CGSize(width: 40, height: 40))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
