//
//  SendQuotaItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/1.
//

import UIKit

class SendQuotaItemView: SendStaticItemView {

    init(utString: String) {
        super.init(title: R.string.localizable.quotaManagePageQuotaQuotaTitle(), rightViewStyle: .label(style: .attributed(string: type(of: self).utStringToAttributedString(utString: utString))), titleTipButtonStyle: .button(style: .tip(clicked: {
            let htmlString = R.string.localizable.popPageTipQuota()
            let vc = PopViewController(htmlString: htmlString)
            vc.modalPresentationStyle = .overCurrentContext
            let delegate =  StyleActionSheetTranstionDelegate()
            vc.transitioningDelegate = delegate
            UIViewController.current?.present(vc, animated: true, completion: nil)
        })))
    }

    static fileprivate func utStringToAttributedString(utString: String) -> NSAttributedString {
        let string = "\(utString) UT"
        let range = string.range(of: utString)!
        let ret = NSMutableAttributedString(string: string)
        ret.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59)], range: NSRange(range, in: string))
        return ret
    }

    func update(utString: String) {
        guard let label = rightView as? UILabel else { fatalError() }
        label.attributedText = type(of: self).utStringToAttributedString(utString: utString)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
