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

enum TransferMethod: String {
    case vite
    case http
    case file
}

class GrinTransactVM {

    enum Action {
        case inputTx(amount: String?)
        case creatTxFile(amount: String?)
        case receiveTx(slateUrl: URL)
        case finalizeTx(slateUrl: URL)
        case sentTx(amountString: String?, destnation: String?)
    }

    let action = PublishSubject<GrinTransactVM.Action>()
    
    let txFee: BehaviorRelay<String> = BehaviorRelay(value: "")
    let sendSlateCreated: PublishSubject<(Slate, URL)> = PublishSubject()
    let receiveSlateCreated: PublishSubject<(Slate, URL)> = PublishSubject()
    let message: PublishSubject<String> = PublishSubject()

    lazy var viteService = GrinTxByViteService()

    init() {
        action.asObservable().subscribe(onNext: { [weak self] (action) in
            switch action {
            case .inputTx(let amountString):
                self?.txStrategies(amountString: amountString)
            case .creatTxFile(let amountString):
                self?.sentTx(amountString: amountString, destnation: nil)
            case .receiveTx(let slateUrl):
                self?.receiveTx(slateUrl: slateUrl)
            case .finalizeTx(let slateUrl):
                self?.finalizeTx(slateUrl: slateUrl)
            case .sentTx(let amountString, let destnation):
                self?.sentTx(amountString: amountString, destnation: destnation)
            }
        })
    }

    func support(method: TransferMethod) -> Bool {
        if method == .file { return true }
        return HDWalletManager.instance.account?.address == HDWalletManager.instance.accounts.first?.address
    }

    func txStrategies(amountString: String?, completion: ((String) -> Void)? = nil) {
        DispatchQueue.global().async {
            guard let amount = self.amountFrom(string: amountString) else {
                self.txFee.accept("")
                return
            }
            let result = GrinManager.default.txStrategies(amount: amount)
            DispatchQueue.main.async {
                switch result {
                case .success(let strategies):
                    let fee = Balance(value: BigInt(strategies.smallest.fee)).amountFull(decimals: 9)
                    self.txFee.accept(fee)
                    completion?(fee)
                case .failure(let error):
                    self.txFee.accept("")
                    self.message.onNext(error.message)
                }
            }
        }
    }

    func creatTxFile(_ amount: UInt64) {
        async({ () in
            GrinManager.default.txCreate(amount: amount, selectionStrategyIsUseAll: false, message: "")
        },  { (result) in
            switch result {
            case .success(let sendSlate):
                do {
                    let url = try self.save(slate: sendSlate, isResponse: false)
                    self.sendSlateCreated.onNext((sendSlate, url))
                } catch {
                    self.message.onNext(error.localizedDescription)
                }
            case .failure(let error):
                self.message.onNext(error.message)
            }
        })
    }

    func receiveTx(slateUrl: URL) {
        async({ () in
            GrinManager.default.txReceive(slatePath: slateUrl.path, message: "Received")
        },  { (result) in
            switch result {
            case .success(let receviedSlate):
                do {
                    let receviedSlateUrl =  try self.save(slate: receviedSlate, isResponse: true)
                    self.receiveSlateCreated.onNext((receviedSlate, receviedSlateUrl))
                } catch {
                    self.message.onNext(error.localizedDescription)
                }
            case .failure(let error):
                self.message.onNext(error.message)
            }
        })
    }

    func finalizeTx(slateUrl: URL) {
        async({ () in
           GrinManager.default.txFinalize(slatePath: slateUrl.path)
        },  { (result) in
            switch result {
            case .success:
                self.message.onNext("Success")
                guard let data = JSON(FileManager.default.contents(atPath: slateUrl.path)).rawValue as? [String: Any],
                    let slate = Slate(JSON:data) else { return }
                GrinManager.default.setFinalizedTx(slate.id)
            case .failure(let error):
                self.message.onNext(error.message)
            }
        })
    }

    func sentTx(amountString: String?, destnation: String?) {
        guard let amount = amountFrom(string: amountString) else {
            return
        }
        if let destnation = destnation {
            if let url = URL(string: destnation) {
                self.sendTxByHttp(anmout: amount, destnation: destnation)
            } else if Address.isValid(string: destnation) {
                self.sendTxByVite(anmout: amount, destnation: destnation)
            } else {
                self.message.onNext("Wrong Address")
            }
        } else {
            self.creatTxFile(amount)
        }
    }

    func sendTxByHttp(anmout: UInt64, destnation: String) {
        async({ () in
            GrinManager.default.txSend(amount: anmout, selectionStrategyIsUseAll: false, message: "Sent", dest: destnation)
        },  { (result) in
            switch result {
            case .success:
                self.message.onNext("Success")
            case .failure(let error):
                self.message.onNext(error.message)
            }
        })
    }

    func sendTxByVite(anmout: UInt64, destnation: String)  {
        viteService.sentGrin(amount: anmout, to: destnation)
            .done {
                self.message.onNext("success")
            }
            .catch { (error) in
                self.message.onNext(error.localizedDescription)
        }
    }

    func save(slate: Slate, isResponse: Bool) throws -> URL {
        let slateUrl = GrinManager.default.getSlateUrl(slateId: slate.id, isResponse: isResponse)
        do {
            try slate.toJSONString()?.write(to: slateUrl, atomically: true, encoding: .utf8)
            return slateUrl
        } catch {
            throw error
        }
    }

    func amountFrom(string: String?) -> UInt64? {
        guard let string = string, !string.isEmpty else {
            return nil
        }
        guard let decimal = BigDecimal(string) else {
            self.message.onNext("wrong amount")
            return nil
        }
        let nanoDecimal = decimal * BigDecimal(BigInt(10).power(9))
        guard nanoDecimal.digits == 0 else {
            self.message.onNext("wrong amount")
            return nil
        }
        guard nanoDecimal.number <= BigInt(UInt64.max) else {
            self.message.onNext("too big")
            return nil
        }
        let uInt = UInt64(nanoDecimal.number.description)
        return uInt
    }

}
