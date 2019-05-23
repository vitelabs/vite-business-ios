//
//  AppNoticeService.swift
//  ViteBusiness
//
//  Created by Stone on 2019/4/2.
//

import Foundation
import ObjectMapper

class AppNoticeService: NSObject {

    struct NoticeInfo: Mappable {

        fileprivate var title: StringWrapper = StringWrapper(string: "")
        fileprivate var message: StringWrapper = StringWrapper(string: "")

        init?(map: Map) { }

        mutating func mapping(map: Map) {
            title <- map["title"]
            message <- map["message"]
        }
    }

    static func getNotice() {

        COSProvider.instance.getAppNotice { (result) in
            switch result {
            case .success(let jsonString):
                plog(level: .debug, log: "get app notice finished", tag: .getConfig)
                if let string = jsonString,
                    let info = NoticeInfo(JSONString: string) {
                    let title = info.title.string
                    let message = info.message.string
                    if !title.isEmpty && !message.isEmpty {
                        showNotice(title: title, message: message)
                    }
                }
            case .failure(let error):
                plog(level: .warning, log: error.viteErrorMessage, tag: .getConfig)
                GCD.delay(2, task: { getNotice() })
            }
        }
    }

    static func showNotice(title: String, message: String) {

        let bgView = UIView().then {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }

        let contentView = UIView().then {
            $0.layer.cornerRadius = 2
            $0.backgroundColor = UIColor.init(netHex: 0xFFFFFF)
        }

        let titleLabel = UILabel().then {
            $0.font = UIFont.boldSystemFont(ofSize: 17)
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.text = title
        }

        let messageLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.textColor = UIColor.init(netHex: 0x3e4a59)
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.text = message
        }

        UIApplication.shared.keyWindow?.addSubview(bgView)
        bgView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)

        bgView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { (m) in
            m.width.equalTo(270)
            m.center.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(24)
            m.left.equalToSuperview().offset(16)
            m.right.equalToSuperview().offset(-16)
        }

        messageLabel.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(12)
            m.left.equalToSuperview().offset(16)
            m.right.equalToSuperview().offset(-16)
            m.bottom.equalToSuperview().offset(-24)
        }

        bgView.alpha = 0
        UIView.animate(withDuration: 0.2) {
            bgView.alpha = 1
        }
    }
}

