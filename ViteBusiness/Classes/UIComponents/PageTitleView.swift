//
//  TitleView.swift
//  Action
//
//  Created by haoshenyang on 2019/6/17.
//

import Foundation

class PageTitleView: UIView {

    enum Style {
        case onlyTitle
        case titleAndIcon
        case titleAndInfoButton
    }

    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24)
        $0.numberOfLines = 1
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = UIColor(netHex: 0x24272B)
    }

    var tokenIconView: TokenIconView?

    var iconView: UIImageView?

    var infoButton = UIButton.init() .then {
        $0.setImage(R.image.infor_white(), for: .normal)
    }

    var tokenInfo: TokenInfo? {
        didSet {
            tokenIconView?.tokenInfo = tokenInfo
        }
    }
}

extension PageTitleView {
    class func titleView(style: PageTitleView.Style ) -> PageTitleView {
        switch style {
        case .onlyTitle:
            return self.onlyTitle()
        case .titleAndIcon:
            return self.titleAndIcon()
        case .titleAndInfoButton:
            return self.titleAndInfoButton()
        default:
            break
        }
    }

    class func onlyTitle(title: String? = nil) -> PageTitleView {
        let view = PageTitleView()
        view.addSubview(view.titleLabel)
        view.titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(view).offset(6)
            m.left.equalTo(view).offset(24)
            m.bottom.equalTo(view).offset(-20)
            m.height.equalTo(29)
        }
        view.titleLabel.text = title
        return view
    }

    class func titleAndIcon(title: String? = nil, icon: UIImage? = nil) -> PageTitleView {
        let view = PageTitleView.onlyTitle(title: title)
        view.iconView = UIImageView()
        view.addSubview(view.iconView!)
        view.iconView!.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-22)
            m.top.equalToSuperview().offset(0.5)
            m.size.equalTo(CGSize(width: 50, height: 50))
        }
        view.iconView!.image = icon
        return view
    }

    class func titleAndTokenIcon(title: String? = nil, tokenInfo: TokenInfo? = nil) -> PageTitleView {
        let view = PageTitleView.onlyTitle(title: title)
        view.tokenIconView = TokenIconView.init()
        view.addSubview(view.tokenIconView!)
        view.tokenIconView!.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-22)
            m.top.equalToSuperview().offset(0.5)
            m.size.equalTo(CGSize(width: 50, height: 50))
        }
        view.tokenIconView?.tokenInfo = tokenInfo
        return view
    }

    class func titleAndInfoButton(title: String? = nil) -> PageTitleView {
        let view = PageTitleView.onlyTitle(title: title)
        view.addSubview(view.infoButton)
        view.infoButton.snp.makeConstraints { (m) in
            m.left.equalTo(view.titleLabel.snp.right).offset(6)
            m.centerY.equalTo(view.titleLabel)
            m.size.equalTo(CGSize(width: 16, height: 16))
        }
        return view
    }
}



