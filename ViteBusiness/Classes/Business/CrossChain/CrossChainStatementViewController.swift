//
//  CrossChainStatementViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/7/30.
//

import Foundation
import ActiveLabel

class CrossChainStatementViewController: BaseViewController {

    let tokenInfo: TokenInfo

    var isWithDraw = true

    let titleView = PageTitleView.titleView(style: .onlyTitle).then {
        $0.titleLabel.text = R.string.localizable.crosschainStatementTitle()

    }

    let topLabel0 = ActiveLabel()
    let topLabel1 = ActiveLabel()
    let topLabel2 = ActiveLabel()
    let bottomLabel = ActiveLabel()
    let agreeButton = UIButton.init(style: .blueWithShadow,title: R.string.localizable.grinSentNext())

    init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topLabel0.numberOfLines = 0
        topLabel1.numberOfLines = 0
        topLabel2.numberOfLines = 0
        bottomLabel.numberOfLines = 0
        topLabel0.font = UIFont.systemFont(ofSize: 12)
        topLabel1.font = UIFont.systemFont(ofSize: 12)
        topLabel2.font = UIFont.systemFont(ofSize: 12)
        bottomLabel.font = UIFont.systemFont(ofSize: 12)

        view.addSubview(titleView)
        view.addSubview(topLabel0)
        view.addSubview(topLabel1)
        view.addSubview(topLabel2)

        view.addSubview(bottomLabel)
        view.addSubview(agreeButton)

        titleView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.height.equalTo(64)
        }

        topLabel0.snp.makeConstraints { (m) in
            m.top.equalTo(titleView.snp.bottom).offset(6)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }

        topLabel1.snp.makeConstraints { (m) in
            m.top.equalTo(topLabel0.snp.bottom).offset(18)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }

        topLabel2.snp.makeConstraints { (m) in
            m.top.equalTo(topLabel1.snp.bottom).offset(18)
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
        }

        agreeButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
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

        agreeButton.rx.tap.bind { [unowned self] _ in
            guard var vcs = self.navigationController?.viewControllers else {
                return
            }
            vcs.removeLast()
            var vc: UIViewController!
            if self.isWithDraw {
                vc = GatewayWithdrawViewController.init(gateWayInfoService: CrossChainGatewayInfoService.init(tokenInfo: self.tokenInfo))
            } else {
                vc = GatewayDepositViewController.init(gatewayInfoService: CrossChainGatewayInfoService.init(tokenInfo: self.tokenInfo))
            }
            vcs.append(vc)
            self.navigationController?.setViewControllers(vcs, animated: true)
        }
    }

    func createNavigationTitleView() -> UIView {
        return titleView
    }

    func setStatementInfo()  {

        var isVite = tokenInfo.gatewayInfo?.isOfficial ?? false

        let name = tokenInfo.gatewayInfo?.name ?? "--"
        let detail = R.string.localizable.crosschainStatementDetail()
        let email = tokenInfo.gatewayInfo?.support ?? ""
        let isZH = LocalizationService.sharedInstance.currentLanguage == .chinese

        let policy = (isZH ? (tokenInfo.gatewayInfo?.policy["zh"] ?? tokenInfo.gatewayInfo?.policy["en"]) : tokenInfo.gatewayInfo?.policy["en"] ) ?? ""

        var str0 = ""
        var str1 = ""
        var str2 = ""

        if isVite {
            str0 = R.string.localizable.crosschainStatementViteDesc0(name)
            str1 = R.string.localizable.crosschainStatementViteDesc1(name, name, detail,name)
            str2 = R.string.localizable.crosschainStatementViteDesc2(name, email)
        } else {
            str0 = R.string.localizable.crosschainStatementOtherDesc0(name, name, name)
            str1 = R.string.localizable.crosschainStatementOtherDesc1(name, name, detail, name)
            str2 = R.string.localizable.crosschainStatementOtherDesc2(name, email)
        }

        topLabel0.text = str0
        topLabel1.text = str1
        topLabel2.text = str2

        let c0 = str0
        let (c1, c2) = (str1.components(separatedBy: detail).first, str1.components(separatedBy: detail).last )
        let (c3, c4) = (str2.components(separatedBy: email).first, str2.components(separatedBy: email).last )

        let customType0 = ActiveType.custom(pattern: c0 ?? "")
        let customType1 = ActiveType.custom(pattern: c1 ?? "")
        let customType2 = ActiveType.custom(pattern: c2 ?? "")
        let customType3 = ActiveType.custom(pattern: c3 ?? "")
        let customType4 = ActiveType.custom(pattern: c4 ?? "")

        let detailType = ActiveType.custom(pattern: detail)

        let emailType = ActiveType.custom(pattern: email)

        for label in [topLabel0, topLabel1, topLabel2] {
            label.enabledTypes = [customType0, customType1, customType2,customType3, customType4, detailType, emailType, .mention, .hashtag, .url]
            label.customize { label in
                label.lineSpacing = 8
                label.customColor[customType0] = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
                label.customColor[customType1] = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
                label.customColor[customType2] = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
                label.customColor[customType3] = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
                label.customColor[customType4] = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
                label.customColor[detailType] = UIColor.init(netHex: 0x007AFF)
                label.customColor[emailType] = UIColor.init(netHex: 0x007AFF)
                label.handleCustomTap(for: detailType) { [weak view] element in
                    guard let url = URL.init(string: policy) else {
                        return
                    }
                    let vc = WKWebViewController.init(url: url)
                    UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                }
                label.handleCustomTap(for: emailType) { [weak view] element in
                    guard let url = URL.init(string: "mailto:" + email) else {
                        return
                    }
                     UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }

        let str3 = R.string.localizable.crosschainStatementAgree(name, detail)
        bottomLabel.text = str3

        let customType5 = ActiveType.custom(pattern: R.string.localizable.crosschainStatementAgree(name, "") ?? "")
        let detailType2 = ActiveType.custom(pattern: detail)

        bottomLabel.enabledTypes = [customType5, detailType2]
        bottomLabel.customize { label in
            label.lineSpacing = 8
            label.customColor[customType5] = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
            label.customColor[detailType2] = UIColor.init(netHex: 0x007AFF)
            label.handleCustomTap(for: detailType2) { [weak view] element in
                guard let url = URL.init(string: policy) else {
                    return
                }
                let vc = WKWebViewController.init(url: url)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }


}
