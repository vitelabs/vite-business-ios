//
//  DeFiProductInfoCard.swift
//  Action
//
//  Created by haoshenyang on 2019/12/2.
//

import UIKit

class DeFiProductInfoCard: UIView {
    enum Status: String {
        case 无
        case 认购中
        case 到期未售罄
        case 成功售罄

        func color() -> UIColor {
            switch self {
            case .无:
                return UIColor.init(netHex: 0xffffff)
             case .认购中:
                return UIColor.init(netHex: 0x007AFF, alpha: 0.6)
            case .到期未售罄:
                return UIColor.init(netHex: 0xB5C8FF)
            case .成功售罄:
                return UIColor.init(netHex: 0xFFC800)
            }
        }
    }

    convenience init(title: String? = nil,
         status: DeFiProductInfoCard.Status = .无,
         porgressDesc: String? = nil,
          progress: CGFloat = 0.0,
          deadLineDesc: NSAttributedString? = nil) {
        self.init(frame: CGRect.init(x: 0, y: 0, width: kScreenH - 48, height: 100))
        self.config(title: title, status: status, progressDesc: porgressDesc, progress: progress, deadLineDesc: deadLineDesc)
    }

    func config(title: String? = nil,
        status: DeFiProductInfoCard.Status = .无,
        progressDesc: String? = nil,
         progress: CGFloat = 0.0,
         deadLineDesc: NSAttributedString? = nil) {
        titleLabel.text = title
        statusLabel.isHidden = status == .none
        statusLabel.titleLab.text = status.rawValue
        statusLabel.bgImg.image = R.image.btn_path_bg()?.tintColor(status.color()).resizable
        progressLabel.text = progressDesc
        progressView.progress = progress
        deadLineDescLabel.attributedText = deadLineDesc
    }

    var size: CGSize {
        let height = self.deadLineDescLabel.attributedText != nil ? 132.0 : 94
        return CGSize.init(width: Double(kScreenW - 48), height: height)
    }

    let productIcon = UIImageView().then {
        $0.image = R.image.defi_lock()
    }

    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor.init(netHex: 0x3E4A59)
    }
    let statusLabel = LabelBgView().then {
        $0.titleLab.font = UIFont.boldSystemFont(ofSize: 12)
        $0.titleLab.textColor = UIColor.init(netHex: 0xFFFFFF)
    }
    let seperator: UIImageView = {
        let lineImg = UIImageView()
        lineImg.isUserInteractionEnabled = true
        lineImg.image = R.image.dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile)
        return lineImg
    }()
    let progressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59)
    }
    let progressView =  ProgressView()
    let deadLineDescLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.cornerRadius = 2
        self.layer.masksToBounds = true
        backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom,
                              frame: CGRect.init(x: 0, y: 0, width: kScreenW - 48, height: 132),
                              colors: [UIColor(netHex: 0xE3F0FF),UIColor(netHex: 0xF2F8FF)])

        addSubview(productIcon)
        addSubview(titleLabel)
        addSubview(statusLabel)
        addSubview(seperator)
        addSubview(progressLabel)
        addSubview(progressView)
        addSubview(deadLineDescLabel)

        productIcon.snp.makeConstraints { (m) in
            m.width.height.equalTo(20)
            m.leading.equalToSuperview().offset(14)
            m.top.equalToSuperview().offset(14)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.leading.equalTo(productIcon.snp.trailing).offset(3)
            m.centerY.equalTo(productIcon)
        }

        statusLabel.snp.makeConstraints { (m) -> Void in
           m.centerY.equalTo(productIcon)
           m.right.equalTo(self).offset(-14)
           m.height.equalTo(18)
       }

        seperator.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(5)
            m.height.equalTo(0.5)
            m.top.equalTo(productIcon.snp.bottom).offset(12)
        }

        progressLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().inset(14)
            m.top.equalTo(seperator.snp.bottom).offset(11)

        }

        progressView.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(14)
            m.top.equalTo(seperator.snp.bottom).offset(31)
        }

        deadLineDescLabel.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview().inset(14)
            m.top.equalTo(seperator.snp.bottom).offset(47)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

