//
//  SendQuotaItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/1.
//

import UIKit

class SendQuotaItemView: SendStaticItemView {

    var utString: String

    init(utString: String) {
        self.utString = utString
        super.init(title: R.string.localizable.quotaManagePageQuotaQuotaTitle(), rightViewStyle: .label(style: .attributed(string: type(of: self).utStringToAttributedString(utString: utString))), titleTipButtonStyle: .button(style: .tip(clicked: {
            var url: URL!
            if LocalizationService.sharedInstance.currentLanguage == .chinese {
                url = URL.init(string: "https://vite-static-pages.netlify.com/quota/zh/quota.html")
            } else {
                url = URL.init(string: "https://vite-static-pages.netlify.com/quota/en/quota.html")
            }
            let vc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)


        })))
    }

    static fileprivate func utStringToAttributedString(utString: String) -> NSAttributedString {
        let string = "\(utString) Quota"
        let range = string.range(of: utString)!
        let ret = NSMutableAttributedString(string: string)
        ret.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59)], range: NSRange(range, in: string))
        return ret
    }

    func update(utString: String) {
        guard let label = rightView as? UILabel else { fatalError() }
        self.utString = utString
        label.attributedText = type(of: self).utStringToAttributedString(utString: utString)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
