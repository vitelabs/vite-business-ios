//
//  TokenIconView.swift
//  Action
//
//  Created by Stone on 2019/2/27.
//

import UIKit
import SnapKit
import Kingfisher

class TokenIconView: UIView {

    let tokenIconImageView = UIImageView()
    let chainIconImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tokenIconImageView)
        addSubview(chainIconImageView)

        tokenIconImageView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        chainIconImageView.snp.makeConstraints { (m) in
            m.bottom.right.equalToSuperview()
            m.width.height.equalToSuperview().multipliedBy(18.0/40.0)
        }

        tokenIconImageView.backgroundColor = UIColor.red
        chainIconImageView.backgroundColor = UIColor.green
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var tokenInfo: TokenInfo? {
        didSet {
            guard let tokenInfo = tokenInfo else { return }
            guard let url = URL(string: tokenInfo.icon) else { return }
            tokenIconImageView.kf.cancelDownloadTask()
            tokenIconImageView.kf.setImage(with: url)
            chainIconImageView.image = tokenInfo.chainIcon
            chainIconImageView.isHidden = tokenInfo.chainIcon == nil
        }
    }
}
