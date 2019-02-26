//
//  EthGasFeeSliderView.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/25.
//
import UIKit
import SnapKit
import ViteUtils

class EthGasFeeSliderView: UIView {
    let totalGasFeeTitleLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = "矿工费用"
    }

    let totalGasFeeLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    let feeSlider = GasFeeSliderView().then {
    $0.setMinimumTrackImage(UIImage.color(UIColor(netHex: 0x007AFF)), for: .normal)
    $0.setMaximumTrackImage(UIImage.color(UIColor(netHex: 0xF3F6F9)), for: .normal)
        $0.minimumValue = 1
        $0.maximumValue = 100
        $0.isContinuous = true
        $0.setThumbImage(R.image.gasSlider(), for: .normal)
        $0.setThumbImage(R.image.gasSlider(), for: .highlighted)
        $0.setThumbImage(R.image.gasSlider(), for: .selected)
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    let slowLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x5E6875)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.text = "Slow"
    }

    let fastLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x5E6875)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.text = "Fast"
    }

    let valueLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha:0.6)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    @objc fileprivate func valueChanged() {
        self.valueLab.text = String.init(format: "%.4fgwei", self.feeSlider.value)
    }

    init() {
        super.init(frame: CGRect.zero)
        self.addSubview(totalGasFeeTitleLab)
        totalGasFeeTitleLab.snp.makeConstraints({ (m) in
            m.top.left.equalToSuperview()
            m.height.equalTo(20)
        })

        self.addSubview(totalGasFeeLab)
        totalGasFeeLab.snp.makeConstraints({ (m) in
            m.centerY.equalTo(self.totalGasFeeTitleLab)
             m.right.equalToSuperview()
             m.height.equalTo(20)
        })

        self.addSubview(feeSlider)
        feeSlider.snp.makeConstraints({ (m) in
            m.top.equalTo(self.totalGasFeeTitleLab.snp.bottom).offset(40)
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.height.equalTo(18)
        })

        self.addSubview(slowLab)
        slowLab.snp.makeConstraints({ (m) in
            m.top.equalTo(self.feeSlider.snp.bottom).offset(2)
            m.left.bottom.equalToSuperview()
            m.height.equalTo(16)
        })

        self.addSubview(fastLab)
        fastLab.snp.makeConstraints({ (m) in
            m.top.equalTo(self.feeSlider.snp.bottom).offset(2)
            m.right.bottom.equalToSuperview()
            m.height.equalTo(16)
        })

        self.addSubview(valueLab)
        valueLab.snp.makeConstraints({ (m) in
            m.top.equalTo(self.feeSlider.snp.bottom).offset(2)
            m.centerX.equalToSuperview()
            m.height.equalTo(16)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GasFeeSliderView: UISlider {
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let newRect = CGRect.init(x: rect.origin.x-5, y: rect.origin.y , width: rect.size.width + 10, height: rect.size.height)
        return super.thumbRect(forBounds: bounds, trackRect: newRect, value: value).insetBy(dx: 5, dy: 5)
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
       let newRect = CGRect.init(x: bounds.origin.x, y: bounds.origin.y , width: bounds.size.width, height: 4)
        self.layer.cornerRadius = 4
        return newRect
    }
}
