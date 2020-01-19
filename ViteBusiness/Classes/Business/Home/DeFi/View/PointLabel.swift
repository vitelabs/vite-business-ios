//
//  PointLabel.swift
//  Action
//
//  Created by haoshenyang on 2019/12/2.
//

import UIKit

class PointLabel: UIView {

    var text: String? {
        set {
            label.text = newValue
        }
        get {
            return label.text
        }
    }

    var font: UIFont! {
        set {
            label.font = newValue
            pointAnchor.font = newValue
        }
        get {
            return label.font
        }
    }

    var textColor: UIColor! {
        set {
            label.textColor = newValue
        }
        get {
            return label.textColor
        }
    }

    var textAlignment: NSTextAlignment  {
           set {
               label.textAlignment = newValue
                pointAnchor.textAlignment = newValue
           }
           get {
               return label.textAlignment
           }
       }

    var numberOfLines: Int  {
              set {
                  label.numberOfLines = newValue
                   pointAnchor.numberOfLines = newValue
              }
              get {
                  return label.numberOfLines
              }
          }

    private let pointView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(netHex:0x007AFF)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()

    private let label = UILabel()

    private let pointAnchor = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pointView)
        addSubview(label)

        label.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(10)
            m.right.top.bottom.equalToSuperview()
        }

        pointAnchor.text = " "
        addSubview(pointAnchor)
        pointAnchor.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(10)
            m.right.top.equalToSuperview()
        }

        pointView.snp.makeConstraints { (m) in
            m.left.equalToSuperview()
            m.height.width.equalTo(6)
            m.centerY.equalTo(pointAnchor)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
