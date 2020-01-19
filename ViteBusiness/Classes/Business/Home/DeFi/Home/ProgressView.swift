//
//  ProgressView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import Foundation

class ProgressView: UIView {

    var progress: CGFloat = 0.0 {
        didSet {
            currentView.snp.remakeConstraints { (m) in
                m.left.top.bottom.equalTo(maxView)
                m.width.equalTo(maxView).multipliedBy(progress)
            }

            GCD.delay(0.01) {
                self.maxView.backgroundColor =
                    UIColor.gradientColor(style: .left2right,
                    frame: self.frame,
                    colors: [UIColor(netHex: 0xF2F8FF),
                             UIColor(netHex: 0xE3F0FF)])
                self.currentView.backgroundColor =
                    UIColor.gradientColor(style: .left2right,
                      frame: self.frame,
                      colors: [UIColor(netHex: 0x2A7FFF),
                               UIColor(netHex: 0x54B6FF)])
            }
        }
    }

    private let maxView = UIView().then {
        $0.layer.masksToBounds = true
    }

    private let currentView = UIView().then {
        $0.layer.masksToBounds = true
    }

    init(height: CGFloat) {
        super.init(frame: .zero)

        addSubview(maxView)
        addSubview(currentView)

        maxView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
            m.height.equalTo(height)
        }

        currentView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        maxView.layer.cornerRadius = height / 2
        currentView.layer.cornerRadius = height / 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
