//
//  EthGasFeeSliderView.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/25.
//
import UIKit
import SnapKit
import BigInt
import web3swift
import ViteWallet


public class EthGasFeeSliderView: UIView {
    public var value : Float = 0.0 {
        didSet {
            guard value != oldValue else {
                return
            }
            if value == self.feeSlider.minimumValue || value == self.feeSlider.maximumValue {
                self.valueLab.text = String(format: "%.2f gwei", value)
            }else {
                self.valueLab.text = String(format: "%.4f gwei", value)
            }
            eth = (value * Float(self.gasLimit) * pow(10.0, -9))
            eth = eth <= 0.0001 ? eth.roundTo(5) :  eth.roundTo(4)


            if eth <= 0.0001 {
                ethStr = String(format: "%.5f", eth)
            } else {
                ethStr = String(format: "%.4f", eth)
            }
            var rateFee = ""
            let balance = ethStr.toAmount(decimals: 18) ?? Amount(0)

            if let rateFeeStr =  ExchangeRateManager.instance.calculateBalanceWithEthRate(balance) {
                rateFee = String(format: "≈%@",rateFeeStr)
            }
            self.totalGasFeeLab.text = String(format: "%@ ETH %@", ethStr,rateFee)
            self.feeSlider.value = Float(value)
        }
    }

    var ethStr: String = ""
    var eth: Float = 0

    let indicatorView = UIActivityIndicatorView(style: .gray).then {
        $0.hidesWhenStopped = true
        $0.startAnimating()
    }

    lazy var totalGasFeeTitleLab = UILabel().then {(totalGasFeeTitleLab) in
        totalGasFeeTitleLab.textColor = UIColor(netHex: 0x3E4A59)
        totalGasFeeTitleLab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        totalGasFeeTitleLab.text = R.string.localizable.ethPageGasFeeTitle()

        self.addSubview(totalGasFeeTitleLab)
        totalGasFeeTitleLab.snp.makeConstraints({ (m) in
            m.top.left.equalToSuperview()
            m.height.equalTo(20)
        })
    }

    lazy var tipButton = UIButton().then {(tipButton) in
        tipButton.setImage(R.image.icon_button_infor(), for: .normal)
        tipButton.setImage(R.image.icon_button_infor()?.highlighted, for: .highlighted)

        self.addSubview(tipButton)
        tipButton.snp.makeConstraints({ (m) in
            m.left.equalTo(self.totalGasFeeTitleLab.snp.right).offset(6)
            m.centerY.equalTo(self.totalGasFeeTitleLab)
            m.height.width.equalTo(20)
        })
    }

    lazy var totalGasFeeLab = UILabel().then {(totalGasFeeLab) in
        totalGasFeeLab.textColor = UIColor(netHex: 0x24272B)
        totalGasFeeLab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        totalGasFeeLab.isHidden = true
        self.addSubview(totalGasFeeLab)
        totalGasFeeLab.snp.makeConstraints({ (m) in
            m.centerY.equalTo(self.totalGasFeeTitleLab)
            m.right.equalToSuperview()
            m.height.equalTo(20)
        })
    }

    lazy var feeSlider = GasFeeSliderView().then {
        let blueImage = UIImage.line_color(UIColor(netHex: 0x007AFF),kScreenW).resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 5, bottom: 5, right: 4))
        let grayImage = UIImage.line_color(UIColor(netHex: 0xF3F6F9),kScreenW).resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 5, bottom: 5, right: 4))
        $0.setMinimumTrackImage(grayImage, for: .normal)
        $0.setMinimumTrackImage(grayImage, for: .selected)
        $0.setMaximumTrackImage(grayImage, for: .normal)
        $0.setMaximumTrackImage(grayImage, for: .selected)
        $0.minimumValue = 1
        $0.maximumValue = 100
        $0.value = 1
        $0.isContinuous = true
        $0.setThumbImage(UIImage(), for: .normal)
        $0.setThumbImage(UIImage(), for: .highlighted)
        $0.setThumbImage(UIImage(), for: .selected)
        $0.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        $0.isUserInteractionEnabled = false
    }

    lazy var slowLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x5E6875)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.text = R.string.localizable.ethPageGasFeeSlowTitle()
    }

    lazy var fastLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x5E6875)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.text = R.string.localizable.ethPageGasFeeFastTitle()
    }

    lazy var valueLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha:0.6)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.isHidden = true
    }

    @objc fileprivate func valueChanged() {
        self.value = self.feeSlider.value.roundTo(4)
    }

    var gasLimit:Int
    init(gasLimit:Int) {
        self.gasLimit = gasLimit
        super.init(frame: CGRect.zero)

        self.addSubview(indicatorView)
        indicatorView.snp.makeConstraints({ (m) in
            m.centerY.equalTo(totalGasFeeTitleLab)
            m.right.equalToSuperview()
        })

        self.addSubview(feeSlider)
        feeSlider.snp.makeConstraints({ (m) in
            m.top.equalTo(self.totalGasFeeTitleLab.snp.bottom).offset(30)
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

        tipButton.rx.tap.bind {
            Alert.show(title: R.string.localizable.hint(),
                       message: R.string.localizable.ethPageGasFeeNoticeTitle(),
                       actions: [(Alert.UIAlertControllerAletrActionTitle.default(title: R.string.localizable.addressManageTipAlertOk()), nil)])
            }.disposed(by: rx.disposeBag)

        ETHAccount.fetchGasPrice()
            .done({ price in
                // Gwei = 9
                let b = BigDecimal(number: price, digits: 9)
                if let value = Float(b.description) {
                    self.feeSlider.minimumValue = value / 2
                    self.feeSlider.maximumValue = value * 3
                    self.value = value
                } else {
                    self.feeSlider.minimumValue = 1
                    self.feeSlider.maximumValue = 100
                    self.value = 1
                }

                self.indicatorView.stopAnimating()
                self.totalGasFeeLab.isHidden = false
                self.valueLab.isHidden = false
                self.feeSlider.isUserInteractionEnabled = true
                self.feeSlider.setThumbImage(R.image.gasSlider(), for: .normal)
                self.feeSlider.setThumbImage(R.image.gasSlider(), for: .highlighted)
                self.feeSlider.setThumbImage(R.image.gasSlider(), for: .selected)

                let blueImage = UIImage.line_color(UIColor(netHex: 0x007AFF),kScreenW).resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 5, bottom: 5, right: 4))
                self.feeSlider.setMinimumTrackImage(blueImage, for: .normal)
                self.feeSlider.setMinimumTrackImage(blueImage, for: .selected)
            }).catch { (_) in
                self.feeSlider.minimumValue = 1
                self.feeSlider.maximumValue = 100
                self.value = 1
                self.indicatorView.stopAnimating()
                self.totalGasFeeLab.isHidden = false
                self.valueLab.isHidden = false
                self.feeSlider.isUserInteractionEnabled = true
                self.feeSlider.setThumbImage(R.image.gasSlider(), for: .normal)
                self.feeSlider.setThumbImage(R.image.gasSlider(), for: .highlighted)
                self.feeSlider.setThumbImage(R.image.gasSlider(), for: .selected)

                let blueImage = UIImage.line_color(UIColor(netHex: 0x007AFF),kScreenW).resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 5, bottom: 5, right: 4))
                self.feeSlider.setMinimumTrackImage(blueImage, for: .normal)
                self.feeSlider.setMinimumTrackImage(blueImage, for: .selected)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GasFeeSliderView: UISlider {
    var lastBounds : CGRect = .zero

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let newRect = CGRect.init(x: rect.origin.x-5, y: rect.origin.y , width: rect.size.width + 10, height: rect.size.height)
        let result = super.thumbRect(forBounds: bounds, trackRect: newRect, value: value).insetBy(dx: 5, dy: 5)
        lastBounds = result
        return result
    }

    let Fix_X  = CGFloat(30)
    let Fix_Y = CGFloat(40)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        if view != self {
            if point.y >= -15 && point.y < (lastBounds.size.height + Fix_Y) && point.x >= 0 && point.x < self.bounds.size.width {
                view = self
            }
        }
        return view
    }

   override  func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var result = super.point(inside: point, with: event)
        if !result {
            if point.x >= (lastBounds.origin.x - Fix_X) && point.x <= (lastBounds.origin.x + lastBounds.size.width + Fix_X) && point.y >= -Fix_Y && point.y < (lastBounds.size.height + Fix_Y) {
                result = true
            }
        }
        return result
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
       let newRect = CGRect.init(x: bounds.origin.x, y: bounds.origin.y , width: bounds.size.width, height: 4)
        return newRect
    }
}

extension Float {
    /// Rounds the double to decimal places value
    func roundTo(_ places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }

    func ethGasFeeDisplay(_ gasLimit:Float) -> String {
        var eth = (self * gasLimit * pow(10.0, -9))
        eth = eth <= 0.0001 ? eth.roundTo(5) :  eth.roundTo(4)

        if eth <= 0.0001 {
            return String(format: "%.5f ETH", eth)
        } else {
            return String(format: "%.4f ETH", eth)
        }
    }
}


extension UIImage {
    public static func line_color(_ color: UIColor, _ width:CGFloat) -> UIImage {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: width, height: 10)
        layer.cornerRadius = 3
        layer.backgroundColor = color.cgColor
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


