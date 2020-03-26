//
//  TokenIconView.swift
//  Action
//
//  Created by Stone on 2019/2/27.
//

import UIKit
import SnapKit
import Kingfisher
import pop

class TokenIconView: UIView {

    let tokenIconImageView = UIImageView()
    let tokenIconFrameImageView = UIImageView(image: R.image.icon_token_info_frame())
    let gatewayIconImageView = UIImageView(image: R.image.gateway())
    let showGateWayIcon: Bool

    func set(tokenIconImage: UIImage?) {
        tokenIconImageView.kf.cancelDownloadTask()
        tokenIconImageView.image = tokenIconImage
    }

    init(showGateWayIcon: Bool = false) {
        self.showGateWayIcon = showGateWayIcon
        super.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: 1))

        tokenIconImageView.backgroundColor = UIColor.white
        addSubview(tokenIconImageView)
        addSubview(tokenIconFrameImageView)
        addSubview(gatewayIconImageView)

        tokenIconImageView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        tokenIconFrameImageView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        gatewayIconImageView.snp.makeConstraints { (m) in
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

    func beat() {
        let animation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)!
        animation.fromValue = NSValue(cgSize: CGSize(width: 0.8, height: 0.8))
        animation.toValue = NSValue(cgSize: CGSize(width: 1, height: 1))
        animation.springBounciness = 10
        self.layer.pop_add(animation, forKey: "layerScaleSmallSpringAnimation")
    }

    func setTokenIcon(_ urlString: String) {
        tokenIconImageView.kf.cancelDownloadTask()
        tokenIconImageView.image = UIImage.color(UIColor(netHex: 0xF8F8F8))
        updateLayer()
        gatewayIconImageView.isHidden = true
        self.bringSubviewToFront(gatewayIconImageView)
        guard let url = URL(string: urlString) else { return }
        tokenIconImageView.kf.setImage(with: url, placeholder: UIImage.color(UIColor(netHex: 0xF8F8F8)))
    }

    var tokenInfo: TokenInfo? {
        didSet {
            tokenIconImageView.kf.cancelDownloadTask()
            tokenIconImageView.image = UIImage.color(UIColor(netHex: 0xF8F8F8))
            updateLayer()
            gatewayIconImageView.isHidden = !showGateWayIcon || tokenInfo?.gatewayInfo == nil
            self.bringSubviewToFront(gatewayIconImageView)
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
    func updateLayer() {

        if self.shapeLayer == nil {
            self.shapeLayer = CAShapeLayer()
            self.shapeLayer.lineWidth = 0.5
            self.shapeLayer.fillColor = UIColor.clear.cgColor
            self.layer.addSublayer(self.shapeLayer)
        }

        let view = self.tokenIconImageView
        self.shapeLayer.strokeColor = UIColor.init(netHex: 0xE5E5EA).cgColor
        self.shapeLayer.path = UIBezierPath(arcCenter: view.center, radius: view.frame.width / 2, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), clockwise: false).cgPath
    }
}
