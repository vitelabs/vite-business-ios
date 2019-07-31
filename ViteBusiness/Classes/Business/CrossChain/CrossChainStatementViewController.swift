//
//  CrossChainStatementViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/7/30.
//

import Foundation
import ActiveLabel

class CrossChainStatementViewController: BaseViewController {

    var completion: (()-> ())?

    let topLabel = ActiveLabel()
    let bottomLabel = ActiveLabel()
    let agreeButton = UIButton.init(style: .blueWithShadow,title: "下一步")


    override func viewDidLoad() {
        super.viewDidLoad()

        topLabel.numberOfLines = 0
        bottomLabel.numberOfLines = 0
        topLabel.font = UIFont.systemFont(ofSize: 12)
        bottomLabel.font = UIFont.systemFont(ofSize: 12)

        view.addSubview(topLabel)
        view.addSubview(bottomLabel)
        view.addSubview(agreeButton)

        topLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(20)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }

        agreeButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(view.snp_bottom).offset(-40)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.height.equalTo(50)
        }

        bottomLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(agreeButton.snp.top).offset(-20)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }

        setStatementInfo()

        agreeButton.rx.tap.bind { _ in
            self.navigationController?.popViewController(animated: true)
            self.completion?()
        }
    }

    func setStatementInfo()  {

        var isVite = false

        let name = "xinsheng"
        let detail = R.string.localizable.crosschainStatementDetail()
        let email = "xx@vite.rog"
        var str = ""
        if isVite {
            str = R.string.localizable.crosschainStatementViteDesc(name, name, name, detail, name, name, email)
        } else {
            str = R.string.localizable.crosschainStatementOtherDesc(name, name, name, name, name, detail, name, name, email)
        }
        topLabel.text = str

        var subs = str.components(separatedBy: detail)
        let (sub0, sub1) = (subs.first, subs.last)
        subs = (sub1?.components(separatedBy: email))!
        let (c0, c1, c2) = (sub0, subs.first, subs.last)

        let customType0 = ActiveType.custom(pattern: c0 ?? "")
        let customType1 = ActiveType.custom(pattern: c1 ?? "")
        let customType2 = ActiveType.custom(pattern: c2 ?? "")

        let detailType = ActiveType.custom(pattern: detail)
        let emailType = ActiveType.custom(pattern: email)
        topLabel.enabledTypes = [customType0, customType1, customType2, detailType, emailType, .mention, .hashtag, .url]
        topLabel.customize { label in
            label.lineSpacing = 8
            label.customColor[customType0] = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
            label.customColor[customType1] = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
            label.customColor[customType2] = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
            label.customColor[detailType] = UIColor.init(netHex: 0x007AFF)
            label.customColor[emailType] = UIColor.init(netHex: 0x007AFF)
            label.handleCustomTap(for: detailType) { [weak view] element in
                Toast.show("aaa")

            }
            label.handleCustomTap(for: emailType) { [weak view] element in
                Toast.show("aaa")
            }
        }

        let str2 = R.string.localizable.crosschainStatementAgree(name, name)
        bottomLabel.text = str2 + detail

        let customType4 = ActiveType.custom(pattern: str2 ?? "")
        bottomLabel.enabledTypes = [customType4, detailType]
        bottomLabel.customize { label in
            label.lineSpacing = 8
            label.customColor[customType4] = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
            label.customColor[detailType] = UIColor.init(netHex: 0x007AFF)
            label.handleCustomTap(for: detailType) { [weak view] element in
                Toast.show("aaa")
            }
        }
    }

}
