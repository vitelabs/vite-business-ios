//
//  MnemonicTextView.swift
//  Vite
//
//  Created by Water on 2018/10/17.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import Vite_HDWalletKit

class MnemonicTextView: UIView {

    lazy var contentTextView: UITextView = {
        let contentTextView =  UITextView()
        contentTextView.backgroundColor = .clear
        contentTextView.font = Fonts.Font18
        contentTextView.textColor = Colors.descGray
        contentTextView.text = ""
        contentTextView.isEditable = true
        contentTextView.isScrollEnabled = true
        contentTextView.autocorrectionType = .no
        contentTextView.autocapitalizationType = .none
        contentTextView.inputAccessoryView = self.tipView
        contentTextView.delegate = self
        return contentTextView
    }()

    fileprivate let tipView = InputAccessoryView(frame: CGRect(x: 0, y: 0, width: 0, height: 42))

    init(isEditable: Bool) {
        super.init(frame: CGRect.zero)

        self.backgroundColor = Colors.bgGray
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 2

        addSubview(contentTextView)
        contentTextView.isEditable = isEditable

        contentTextView.snp.makeConstraints { (m) in
            m.top.left.equalTo(self).offset(10)
            m.bottom.right.equalTo(self).offset(-10)
        }

        for (index, b) in tipView.buttons.enumerated() {
            b.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                let array = self.contentTextView.text.components(separatedBy: " ")
                guard let last = array.last, !last.isEmpty else { return }
                let button = self.tipView.buttons[index]
                guard let word = button.titleLabel?.text, !word.isEmpty else { return }
                var text = self.contentTextView.text!
                self.contentTextView.text = "\(String(text.dropLast(last.count)))\(word) "
                self.tipView.buttons.forEach { $0.setTitle("", for: .normal) }
                }.disposed(by: rx.disposeBag)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var text: String {
        return contentTextView.text
    }
}

extension MnemonicTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let array = textView.text.components(separatedBy: " ")
        let words: [String]
        if let prefix = array.last, !prefix.isEmpty {
            words = Array(MnemonicCodeBook.english.words.filter { $0.hasPrefix(prefix) }.prefix(InputAccessoryView.count)).sorted()
        } else {
            words = [String]()
        }

        for (index, button) in tipView.buttons.enumerated() {
            if index < words.count {
                button.setTitle(words[index], for: .normal)
                button.isUserInteractionEnabled = true
            } else {
                button.setTitle("", for: .normal)
                button.isUserInteractionEnabled = false
            }
        }
    }
}

extension MnemonicTextView {
    fileprivate class InputAccessoryView: UIView {

        static let count = 3
        let buttons: [UIButton]
        override init(frame: CGRect) {

            var bs = [UIButton]()
            for index in 0..<type(of: self).count {
                let button = UIButton()
                button.setBackgroundImage(UIImage.image(withColor: UIColor.white, cornerRadius: 2).resizable, for: .highlighted)
                button.setTitleColor(UIColor(netHex: 0x3E4A59), for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                bs.append(button)
            }
            buttons = bs
            super.init(frame: frame)

            backgroundColor = UIColor(netHex: 0xEFF0F4)

            let stackView = UIView()
            addSubview(stackView)
            stackView.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(4)
                m.left.equalToSuperview().offset(2)
                m.right.equalToSuperview().offset(-2)
                m.bottom.equalToSuperview().offset(-4)
            }

            var leftView = stackView
            for (index, button) in buttons.enumerated() {
                stackView.addSubview(button)
                button.snp.makeConstraints({ (m) in
                    m.top.bottom.equalToSuperview()
                    if index == 0 {
                        m.left.equalTo(leftView)
                    } else {
                        m.left.equalTo(leftView.snp.right).offset(-1)
                        m.width.equalTo(leftView)
                    }

                    if index == type(of: self).count - 1 {
                        m.right.equalToSuperview()
                    }
                })
                leftView = button

                if index < type(of: self).count - 1 {
                    let line = UIView()
                    line.backgroundColor = Colors.lineGray
                    stackView.insertSubview(line, at: 0)
                    line.snp.makeConstraints { (m) in
                        m.top.equalToSuperview().offset(2)
                        m.bottom.equalToSuperview().offset(-3)
                        m.width.equalTo(CGFloat.singleLineWidth)
                        m.right.equalTo(button)
                    }
                }
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}


