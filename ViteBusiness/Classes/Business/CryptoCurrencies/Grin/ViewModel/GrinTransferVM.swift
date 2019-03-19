//
//  GrinTransferVM.swift
//  Action
//
//  Created by haoshenyang on 2019/3/14.
//

import UIKit
import RxSwift
import RxCocoa
import Vite_GrinWallet
import ReactorKit
import ViteWallet
import BigInt
import SwiftyJSON

enum TransferMethod {
    case viteAddress
    case httpURL
    case file
}

class GrinTransferVM {

    enum Action {
        case inputTx(amount: String?)
        case creatTxFile(amount: String?)
        case receiveTx(slateUrl: URL)
        case finalizeTx(slateUrl: URL)
    }

    let action = PublishSubject<GrinTransferVM.Action>()
    
    let txFee: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let sendTxCreated: PublishSubject<Slate?> = PublishSubject()
    let receiveTxCreated: PublishSubject<URL> = PublishSubject()
    let errorMessage: PublishSubject<String> = PublishSubject()

    init() {
        action.asObservable().subscribe(onNext: { [weak self] (action) in
            switch action {
            case .inputTx(let amountString):
                self?.txStrategies(amountString)
            case .creatTxFile(let amountString):
                self?.creatTx(amountString)
            case .receiveTx(let slateUrl):
                self?.receiveTx(slateUrl: slateUrl)
            case .finalizeTx(let slateUrl):
                self?.finalizeTx(slateUrl: slateUrl)
            }
        })
    }

    func support(method:TransferMethod) -> Bool {
        if method == .file { return true }
        return HDWalletManager.instance.account?.address == HDWalletManager.instance.accounts.first?.address
    }

    func txStrategies(_ amountString: String?) {
        guard let amountString = amountString,
            let amount = Double(amountString) else {
                txFee.accept(nil)
                return
        }
        let result = GrinManager.default.txStrategies(amount: UInt64(amount * 100000000))
        switch result {
        case .success(let strategies):
            let fee = Balance(value: BigInt(strategies.smallest.fee)).amountFull(decimals: 9)
            txFee.accept(fee)
        case .failure(let error):
            txFee.accept("")
            errorMessage.onNext(error.message)
        }
    }

    func creatTx(_ amountString: String?) {
        guard let amountString = amountString,
            let amount = Double(amountString) else {
                return
        }
        let result = GrinManager.default.txCreate(amount: UInt64(amount * 100000000), selectionStrategyIsUseAll: false, message: "")
        switch result {
        case .success(let sendSlate):
            let sendSlateUrl = GrinManager.default.getSlateUrl(slateId: sendSlate.id, isResponse: false)
            do {
                try sendSlate.toJSONString()?.write(to: sendSlateUrl, atomically: true, encoding: .utf8)
                sendTxCreated.onNext(sendSlate)
            } catch {
                errorMessage.onNext(error.localizedDescription)
            }
            break
        case .failure(let error):
             errorMessage.onNext(error.message)
        }
    }

    func receiveTx(slateUrl: URL) {
        let result = GrinManager.default.txReceive(slatePath: slateUrl.path, message: "Received")
        switch result {
        case .success(let receviedSlate):
            let receviedSlateUrl = GrinManager.default.getSlateUrl(slateId: receviedSlate.id, isResponse: true)
            do {
                try receviedSlate.toJSONString()?.write(to: receviedSlateUrl, atomically: true, encoding: .utf8)
                receiveTxCreated.onNext(receviedSlateUrl)
            } catch {
                 errorMessage.onNext(error.localizedDescription)
            }
            break
        case .failure(let error):
             errorMessage.onNext(error.message)
        }
    }

    func finalizeTx(slateUrl: URL) {
        let result = GrinManager.default.txFinalize(slatePath: slateUrl.path)
        switch result {
        case .success:
            errorMessage.onNext("Success")
            guard let data = JSON(FileManager.default.contents(atPath: slateUrl.path)).rawValue as? [String: Any],
                let slate = Slate(JSON:data) else { return }
            GrinManager.default.setFinalizedTx(slate.id)
        case .failure(let error):
             errorMessage.onNext(error.message)
        }
    }

}
