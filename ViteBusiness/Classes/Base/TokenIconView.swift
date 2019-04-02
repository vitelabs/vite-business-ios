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
    let tokenIconFrameImageView = UIImageView(image: R.image.icon_token_info_frame())
    let chainIconImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        tokenIconImageView.backgroundColor = UIColor.white
        addSubview(tokenIconImageView)
        addSubview(tokenIconFrameImageView)
        addSubview(chainIconImageView)

        tokenIconImageView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        tokenIconFrameImageView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        chainIconImageView.snp.makeConstraints { (m) in
            m.bottom.right.equalToSuperview()
            m.width.height.equalToSuperview().multipliedBy(18.0/40.0)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(cornerRadius: CGFloat) {
        tokenIconImageView.layer.masksToBounds = true
        tokenIconImageView.layer.cornerRadius = 20
        tokenIconFrameImageView.removeFromSuperview()
    }

    var tokenInfo: TokenInfo? {
        didSet {
            tokenIconImageView.kf.cancelDownloadTask()
            tokenIconImageView.image = UIImage.color(UIColor(netHex: 0xF8F8F8))
            chainIconImageView.image = tokenInfo?.chainIcon
            chainIconImageView.isHidden = tokenInfo?.chainIcon == nil
            updateLayer()
            guard let tokenInfo = tokenInfo else { return }
            guard let url = URL(string: tokenInfo.icon) else { return }
            tokenIconImageView.kf.setImage(with: url, placeholder: UIImage.color(UIColor(netHex: 0xF8F8F8)))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayer()
    }

    var shapeLayer: CAShapeLayer! = nil
    private func updateLayer() {

        if self.shapeLayer == nil {
            self.shapeLayer = CAShapeLayer()
            self.shapeLayer.lineWidth = 1
            self.shapeLayer.fillColor = UIColor.clear.cgColor
            self.layer.addSublayer(self.shapeLayer)
        }

        let view = self.tokenIconImageView
        self.shapeLayer.strokeColor = self.tokenInfo?.strokeColor.cgColor ?? UIColor.clear.cgColor
        self.shapeLayer.path = UIBezierPath(arcCenter: view.center, radius: view.frame.width / 2, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), clockwise: false).cgPath
    }
}
