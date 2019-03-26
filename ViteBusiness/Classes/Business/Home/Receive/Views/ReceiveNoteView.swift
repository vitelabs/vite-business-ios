//
//  ReceiveNoteView.swift
//  Vite
//
//  Created by Stone on 2018/9/26.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

class ReceiveNoteView: UIView {

    let noteTitleTextFieldView = TitleTextFieldView(title: R.string.localizable.receivePageTokenNoteLabel())

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(noteTitleTextFieldView)

        noteTitleTextFieldView.snp.makeConstraints { (m) in
            m.top.equalTo(self).offset(20)
            m.left.equalTo(self).offset(24)
            m.right.equalTo(self).offset(-24)
            m.bottom.equalTo(self).offset(-10)
        }

        noteTitleTextFieldView.textField.kas_setReturnAction(.done(block: {
            $0.resignFirstResponder()
        }), delegate: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReceiveNoteView: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // maxCount is 120, about 40 Chinese characters
        let ret = InputLimitsHelper.allowText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, maxCount: 120)
        if !ret {
            Toast.show(R.string.localizable.sendPageToastNoteTooLong())
        }
        return ret
    }
}
