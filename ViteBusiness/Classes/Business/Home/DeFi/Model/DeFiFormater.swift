//
//  DeFiFormater.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/9.
//

import ViteWallet

struct DeFiFormater {

    static func amount(_ amount: Amount, token: Token) -> NSAttributedString {
        let string = amount.amountShortWithGroupSeparator(decimals: token.decimals)
        return value(string, unit: token.symbol)
    }

    static func value(_ value: String, unit: String) -> NSAttributedString {
        let string = "\(value) \(unit)"
        let ret = NSMutableAttributedString(string: string)

        ret.addAttributes(
            text: string,
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.7),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        ret.addAttributes(
            text: unit,
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.45),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        return ret
    }

    static func loanDuration(text: String) -> NSAttributedString {
        let string = R.string.localizable.defiItemLoanDurationFormat(
            R.string.localizable.defiItemDurationPre(),
            text,
            R.string.localizable.defiItemDurationSuf())
        let ret = NSMutableAttributedString(string: string)

        ret.addAttributes(
            text: string,
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.7),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        ret.addAttributes(
            text: R.string.localizable.defiItemDurationSuf(),
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.45),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        return ret
    }

    static func subscriptionDuration(text: String) -> NSAttributedString {
        let string = R.string.localizable.defiItemSubscriptionDurationFormat(
            text,
            R.string.localizable.defiItemDurationSuf())
        let ret = NSMutableAttributedString(string: string)

        ret.addAttributes(
            text: string,
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.7),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        ret.addAttributes(
            text: R.string.localizable.defiItemDurationSuf(),
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.45),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        return ret
    }
}
