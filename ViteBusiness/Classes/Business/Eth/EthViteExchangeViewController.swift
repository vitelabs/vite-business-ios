//
//  EthViteExchangeViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/4/24.
//

import UIKit
import ViteEthereum
import Web3swift
import BigInt
import PromiseKit

class EthViteExchangeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    let exchangeButton = UIButton(style: .blue, title: R.string.localizable.sendPageSendButtonTitle())

    func setupView() {
        view.addSubview(exchangeButton)

        exchangeButton.snp.makeConstraints { (m) in
//            m.top.greaterThanOrEqualTo(scrollView.snp.bottom).offset(10)
            m.left.equalTo(view).offset(24)
            m.right.equalTo(view).offset(-24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
            m.height.equalTo(50)
        }
    }

    func bind() {

        exchangeButton.rx.tap.bind {

            let blackHoleAddress = "0x1111111111111111111111111111111111111111"
            let amount = BigInt(3) * BigInt("1000000000000000000")!

            EthViteExchangeViewController.getTx(to: blackHoleAddress, amount: amount, gasPrice: nil, contractAddress: TokenInfo.viteERC20ContractAddress)
//                .then({ tx -> Promise<WriteTransaction> in
//                    let key = EtherWallet.account.privateKey!
//                    let chainID = tx.transaction.chainID!
//                    let hash = tx.transaction.hashForSignature(chainID: chainID)!
//                    let ethAddress = EtherWallet.account.address!
//                    let viteAddress = HDWalletManager.instance.account!.address.description
//                    let context = GatewayBindContext(ethPrivateKey: key, ethTxHash: hash, ethAddress: ethAddress, viteAddress: viteAddress, value: amount)
//                    return GatewayProvider.instance.bind(context).map { _ in tx }
//                })
                .then({ tx -> Promise<TransactionSendingResult> in
                    let xx = tx.transaction.encode(forSignature: true, chainID: BigUInt(3))?.sha3(.keccak256).toHexString()
//                    let xx = tx.transaction.hash
                    plog(level: .debug, log: xx, tag: .exchange)
                    return EthViteExchangeViewController.sendTx(tx)
                }).done({ (ret) in
                    plog(level: .debug, log: ret.hash, tag: .exchange)
                }).catch({ (error) in
                    plog(level: .warning, log: error.viteErrorMessage, tag: .exchange)
                })


        }.disposed(by: rx.disposeBag)
    }

}

extension EthViteExchangeViewController {
    static func getTx(to address: String, amount: BigInt, gasPrice: BigInt?, contractAddress: String) -> Promise<WriteTransaction> {
        return Promise { seal in
            EtherWallet.transaction.getSendTokenTransaction(to: address, amount: amount, gasPrice: gasPrice, contractAddress: contractAddress) { (r) in
                switch r {
                case .success(let t):
                    seal.fulfill(t)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    static func sendTx(_ tx: WriteTransaction) -> Promise<TransactionSendingResult> {
        return Promise { seal in
            EtherWallet.transaction.sendTransaction(tx, completion: { (r) in
                switch r {
                case .success(let t):
                    seal.fulfill(t)
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }
}

