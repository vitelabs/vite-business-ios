//
//  AddressTextViewView.swift
//  Vite
//
//  Created by Stone on 2018/10/25.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import RxSwift
import RxCocoa
import NSObject_Rx

class AddressTextViewView: SendAddressViewType {

    let addButton = UIButton()
    let placeholderStr: String?

    init(placeholder: String = "") {
        self.placeholderStr = placeholder
        super.init(frame: CGRect.zero)

        self.placeholderLab.textColor = Colors.lineGray
        self.placeholderLab.font = AppStyle.descWord.font
        self.placeholderLab.text = placeholder

        titleLabel.text = R.string.localizable.sendPageToAddressTitle()
        textView.delegate = self
        addSubview(titleLabel)
        addSubview(textView)
        addSubview(placeholderLab)
        addSubview(addButton)

        addButton.setImage(R.image.icon_button_address_add(), for: .normal)
        addButton.setImage(R.image.icon_button_address_add()?.highlighted, for: .highlighted)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self)
            m.left.equalTo(self)
            m.right.equalTo(self)
        }

        textView.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(10)
            m.left.equalTo(titleLabel)
            m.right.equalTo(addButton.snp.left).offset(-16)
//            m.height.equalTo(55)
            m.bottom.equalTo(self)
        }

        placeholderLab.snp.makeConstraints { (m) in
            m.right.left.equalTo(textView)
            m.centerY.equalTo(addButton)
        }

        addButton.snp.makeConstraints { (m) in
            m.right.equalTo(titleLabel)
            m.bottom.equalTo(self).offset(-10)
            m.size.equalTo(CGSize(width: 28, height: 28))
        }

        textView.textColor = UIColor(netHex: 0x24272B)
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        let separatorLine = UIView()
        separatorLine.backgroundColor = Colors.lineGray
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.right.equalTo(titleLabel)
            m.bottom.equalTo(self)
        }

        textView.rx.text.asObservable().bind { [weak self] string in
            self?.placeholderLab.text = (string ?? "").isEmpty ? self?.placeholderStr : ""
        }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension AddressTextViewView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.placeholderLab.isHidden = true
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.placeholderLab.isHidden = false
    }
}
