//
//  ImportAccountVM.swift
//  Vite
//
//  Created by Water on 2018/9/10.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import Action
import RxCocoa
import RxSwift
import Vite_HDWalletKit

final class ImportAccountVM {


    var language: MnemonicCodeBook?
    let submitBtnEnable: Driver<Bool>
    lazy var submitAction: Action<(String, String, String, String), CreateWalletResult> = Action {(content, name, pwd, rePwd) in

        if content.isEmpty || name.isEmpty || pwd.isEmpty || rePwd.isEmpty {
            return Observable.just(.empty(message: R.string.localizable.mnemonicBackupPageErrorTypeName()))
        }

        var contentMnemonic =  ViteInputValidator.handleMnemonicStrSpacing(content)

        guard let language = Mnemonic.mnemonic_check(contentMnemonic) else {
            self.language = nil
            return Observable.just(.empty(message:R.string.localizable.importPageSubmitInvalidMnemonic()))
        }

        self.language = language

        if !ViteInputValidator.isValidWalletName(str: name) {
            return Observable.just(.failed(message: R.string.localizable.mnemonicBackupPageErrorTypeNameValid()))
        }
        if !ViteInputValidator.isValidWalletNameCount(str: name) {
            return Observable.just(.failed(message: R.string.localizable.mnemonicBackupPageErrorTypeValidWalletNameCount()))
        }
        if pwd != rePwd {
            return Observable.just(.empty(message:R.string.localizable.mnemonicBackupPageErrorTypeDifference()))
        }
        if ViteInputValidator.isValidWalletPassword(str: pwd) {
            return Observable.just(.empty(message:R.string.localizable.mnemonicBackupPageErrorTypePwdIllegal()))
        }

        return Observable.just(.ok(message:""))
    }

    var accountNameTF: UITextField
    private var passwordTF: UITextField
    private var repeatePwdTF: UITextField

    init(input:(contentTextView: UITextView, accountNameTF: UITextField, passwordTF: UITextField, repeatePwdTF: UITextField)) {
        accountNameTF = input.accountNameTF
        passwordTF = input.passwordTF
        repeatePwdTF = input.repeatePwdTF

        let contentTextViewDriver = input.contentTextView.rx.text.orEmpty.asDriver()
        let accountDriver = input.accountNameTF.rx.text.orEmpty.asDriver()
        let passwordDriver = input.passwordTF.rx.text.orEmpty.asDriver()
        let repeatePwdTFDriver = input.repeatePwdTF.rx.text.orEmpty.asDriver()

        let createAccountIsOK = Driver.combineLatest(contentTextViewDriver, accountDriver, passwordDriver, repeatePwdTFDriver) {
            return ($0, $1, $2, $3)
        }

        submitBtnEnable = createAccountIsOK.flatMap { (arg) -> SharedSequence<DriverSharingStrategy, Bool> in
            let (content, account, password, rePwd) = arg
            return ImportAccountVM.handleLoginBtnEnable(content, name: account, pwd: password, rePwd: rePwd).asDriver(onErrorJustReturn: false)
        }
    }

    static func handleLoginBtnEnable(_ content: String, name: String, pwd: String, rePwd: String) -> Observable<Bool> {
        if content.isEmpty || name.isEmpty || pwd.isEmpty || rePwd.isEmpty {
            return Observable.just(false)
        }

        return Observable.just(true)
    }
}
