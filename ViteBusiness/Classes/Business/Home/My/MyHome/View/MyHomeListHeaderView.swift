//
//  MyHomeListHeaderView.swift
//  Vite
//
//  Created by Water on 2018/9/12.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit

protocol MyHomeListHeaderViewDelegate: class {
    func contactsBtnAction()
    func mnemonicBtnAction()
}

class MyHomeListHeaderView: UIView {

    weak var delegate: MyHomeListHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let margin = 24
        let width = (kScreenW-48)/2.0
        let height = 88.0 * (kScreenW / 375.0)

        self.addSubview(self.contactsBtn)
        self.contactsBtn.snp.makeConstraints {  (make) -> Void in
            make.left.equalTo(self).offset(margin)
            make.top.equalTo(self).offset(12)
            make.height.equalTo(height)
            make.width.equalTo(width)
        }

        self.addSubview(mnemonicBtn)
        self.mnemonicBtn.snp.makeConstraints {  (make) -> Void in
            make.top.equalTo(self).offset(12)
            make.height.equalTo(height)
            make.width.equalTo(width)
            make.right.equalTo(self).offset(-margin)
        }
    }

    lazy var contactsBtn: IconBtnView = {
        let contactsBtn = IconBtnView.init(iconImg: R.image.icon_wallet()!, text: R.string.localizable.myPageContactsCellTitle())
        contactsBtn.btn.addTarget(self, action: #selector(contactsBtnAction), for: .touchUpInside)
        return contactsBtn
    }()

    lazy var mnemonicBtn: IconBtnView = {
        let mnemonicBtn = IconBtnView.init(iconImg: R.image.icon_transrecord()!, text: R.string.localizable.myPageMnemonicCellTitle())
        mnemonicBtn.btn.addTarget(self, action: #selector(mnemonicBtnAction), for: .touchUpInside)
        return mnemonicBtn
    }()

    @objc func mnemonicBtnAction() {
        self.delegate?.mnemonicBtnAction()
    }

    @objc func contactsBtnAction() {
        self.delegate?.contactsBtnAction()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
