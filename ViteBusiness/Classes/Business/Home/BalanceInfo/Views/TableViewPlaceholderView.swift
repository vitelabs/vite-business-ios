//
//  TableViewPlaceholderView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/7.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class TableViewPlaceholderView: UIView {

    enum ImageType {
        case empty
        case networkError
        case custom(UIImage?)
    }

    enum ViewType {
        case text(_ text: String)
        case button(_ title: String, _ tap: () -> Void)
    }

    init(imageType: ImageType, viewType: ViewType) {
        super.init(frame: CGRect.zero)
        backgroundColor = .white

        let image: UIImage?
        let text: String
        let tap: (() -> Void)?

        switch imageType {
        case .empty:
            image = R.image.empty()
        case .networkError:
            image = R.image.network_error()
        case .custom(let i):
            image = i
        }

        switch viewType {
        case .text(let t):
            text = t
            tap = nil
        case .button(let t, let b):
            text = t
            tap = b
        }

        let imageView = UIImageView(image: image)
        let button = UIButton(type: .system).then {
            $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.textAlignment = .center
            $0.setTitle(text, for: .normal)
            if let tap = tap { // button
                $0.isUserInteractionEnabled = true
                $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
                $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)

                $0.rx.tap.bind { tap() }.disposed(by: rx.disposeBag)
            } else { // text
                $0.isUserInteractionEnabled = false
                $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.45), for: .normal)
                $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.45).highlighted, for: .highlighted)
            }
        }

        addSubview(imageView)
        addSubview(button)

        imageView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(20)
            m.centerX.equalToSuperview()
            m.size.equalTo(CGSize(width: 130, height: 130))
        }
        button.snp.makeConstraints { (m) in
            m.top.equalTo(imageView.snp.bottom).offset(20)
            m.left.right.equalToSuperview()
            m.bottom.equalToSuperview().offset(-40)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TableViewBottomPlaceholderView: UIView {

    var retry: Observable<Void> {
        return retryButton.rx.tap.asObservable()
    }

    fileprivate let retryButton = UIButton().then {
        $0.setTitle(R.string.localizable.retry(), for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        addSubview(retryButton)
        retryButton.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
