//
//  TableViewLoadingView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/7.
//

import UIKit

class TableViewLoadingView: UIView {

    fileprivate let activityIndicatorView = UIActivityIndicatorView(style: .gray)

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white

        addSubview(activityIndicatorView)

        activityIndicatorView.startAnimating()
        activityIndicatorView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(20)
            m.center.equalToSuperview()
            m.bottom.equalToSuperview().offset(-40)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
