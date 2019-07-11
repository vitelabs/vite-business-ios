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
    let finalizeTxSuccess: PublishSubject<Void> = PublishSubject()
    let sendTxSuccess: PublishSubject<Void> = PublishSubject()
    let message: PublishSubject<String> = PublishSubject()
    let sendButtonEnabled: BehaviorRelay<Bool> = BehaviorRelay(value: true)

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

    func txStrategies(amountString: String?, completion: ((String?) -> Void)? = nil) {
        GrinManager.queue.async {
            guard let amount = self.amountFrom(string: amountString) else {
                self.txFee.accept("")
                return
            }
            let result = GrinManager.default.txStrategies(amount: amount)
            DispatchQueue.main.async {
                switch result {
                case .success(let strategies):
                    let fee = Amount(strategies.smallest.fee).amountFull(decimals: 9)
                    self.txFee.accept(fee)
                    completion?(fee)
                case .failure(let error):
                    self.txFee.accept("")
                    completion?(nil)
                    self.message.onNext(error.message)
                }
            }
        }
    }

    func creatTxFile(_ amount: UInt64) {
        grin_async({ () in
            GrinManager.default.txCreate(amount: amount, selectionStrategyIsUseAll: false, message: "")
        },  { (result) in
            switch result {
            case .success(let sendSlate):
                GrinLocalInfoService.shared.addSendInfo(slateId: sendSlate.id, method: "File", creatTime: Int(Date().timeIntervalSince1970))
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
        grin_async({ () in
            GrinManager.default.txReceive(slatePath: slateUrl.path, message: "Received")
        },  { (result) in
            switch result {
            case .success(let receviedSlate):
                do {
                    GrinLocalInfoService.shared.set(receiveTime: Int(Date().timeIntervalSince1970), with: receviedSlate.id)
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
//        Statistics.log(eventId: "Vite_app_wallet_TransferGrin_File_3", attributes: ["uuid": UUID.stored])
        grin_async({ () in
           GrinManager.default.txFinalize(slatePath: slateUrl.path)
        },  { (result) in
            switch result {
            case .success(let slate):
                let result = GrinManager.default.txRepost(slateID: slate.id)
                switch result {
                case .success:
                    self.message.onNext(R.string.localizable.grinFinalizedAlertDesc())
                    self.finalizeTxSuccess.onNext(Void())
                    guard let data = JSON(FileManager.default.contents(atPath: slateUrl.path)).rawValue as? [String: Any],
                        let slate = Slate(JSON:data) else { return }
                    GrinManager.default.setFinalizedTx(slate.id)
                    GrinLocalInfoService.shared.set(finalizeTime: Int(Date().timeIntervalSince1970), with: slate.id)
                case .failure(let error):
                    self.message.onNext(error.message)
                }
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
           if destnation.isViteAddress {
                self.sendButtonEnabled.accept(false)
                self.sendTxByVite(amount: amount, destnation: destnation)
            } else if let url = URL(string: destnation) {
                self.sendButtonEnabled.accept(false)
                self.sendTxByHttp(anmout: amount, destnation: destnation)
            } else {
                self.message.onNext("Wrong Address")
            }
        } else {
            self.creatTxFile(amount)
        }
    }

    func sendTxByHttp(anmout: UInt64, destnation: String) {
        grin_async({ () in
            GrinManager.default.txSend(amount: anmout, selectionStrategyIsUseAll: false, message: "Sent", dest: destnation)
        },  { (result) in
            switch result {
            case .success(let slate):
                let result = GrinManager.default.txRepost(slateID: slate.id)
                switch result {
                case .success:
                    self.message.onNext(R.string.localizable.grinSentHttpSuccess())
                    self.sendTxSuccess.onNext(Void())
                    GrinLocalInfoService.shared.addSendInfo(slateId: slate.id, method: "Http", creatTime: Int(Date().timeIntervalSince1970))
                    GrinLocalInfoService.shared.set(getResponseFileTime: Int(Date().timeIntervalSince1970), with: slate.id)
                    GrinLocalInfoService.shared.set(finalizeTime: Int(Date().timeIntervalSince1970), with: slate.id)
                case .failure(let error):
                    self.message.onNext(error.message)
                }
            case .failure(let error):
                self.sendButtonEnabled.accept(true)
                self.message.onNext(error.message)
            }
        })
    }

    func sendTxByVite(amount: UInt64, destnation: String)  {
        viteService.sendGrin(amount: amount, to: destnation)
            .done {
                plog(level: .info, log: "grin-3-sendGrin-sendGrinSuccess.amount:\(amount),destnation:\(destnation)", tag: .grin)
                self.message.onNext(R.string.localizable.grinSentViteSuccess())
                self.sendTxSuccess.onNext(Void())
            }
            .catch { (error) in
                plog(level: .info, log: "grin-3-sendGrin-sendGrinFailed.amount:\(amount),destnation:\(destnation),error:\(error)", tag: .grin)
                self.sendButtonEnabled.accept(true)
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
            self.message.onNext(R.string.localizable.grinSendIllegalAmmount())
            return nil
        }
        let nanoDecimal = decimal * BigDecimal(BigInt(10).power(9))
        guard nanoDecimal.digits == 0 else {
            self.message.onNext(R.string.localizable.grinSendIllegalAmmount())
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
