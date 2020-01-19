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
        let width = (kScreenW-48-15)/2.0
        let height = 77

        self.addSubview(self.contactsBtn)
        self.contactsBtn.snp.makeConstraints {  (make) -> Void in
            make.top.equalTo(self).offset(12)
            make.left.equalTo(self).offset(margin)
            make.height.equalTo(height)
            make.width.equalTo(width)
        }

        self.addSubview(mnemonicBtn)
        self.mnemonicBtn.snp.makeConstraints {  (make) -> Void in
            make.top.equalTo(self).offset(12)
            make.right.equalTo(self).offset(-margin)
            make.height.equalTo(height)
            make.width.equalTo(width)
        }
    }

    lazy var contactsBtn: UIButton = {
        let contactsBtn = UIButton.topImage(R.image.icon_contacts(), bottomTitle: R.string.localizable.myPageContactsCellTitle())
        contactsBtn.addTarget(self, action: #selector(contactsBtnAction), for: .touchUpInside)
        return contactsBtn
    }()

    lazy var mnemonicBtn: UIButton = {
        let mnemonicBtn = UIButton.topImage(R.image.icon_mnemonic(), bottomTitle: R.string.localizable.myPageMnemonicCellTitle())
        mnemonicBtn.addTarget(self, action: #selector(mnemonicBtnAction), for: .touchUpInside)
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
