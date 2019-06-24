//
//  GatewayBindContext.swift
//  Vite
//
//  Created by Stone on 2018/11/5.
//  Copyright © 2018 vite labs. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
import BigInt
import ViteWallet
import web3swift
import secp256k1
import CryptoSwift

struct GatewayBindContext: Mappable {

    public fileprivate(set) var publicKey: String = ""
    public fileprivate(set) var ethTxHash: String = ""
    public fileprivate(set) var ethAddress: String = ""
    public fileprivate(set) var viteAddress: String = ""
    public fileprivate(set) var value: BigInt = BigInt(0)
    public fileprivate(set) var signature: String = ""

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        publicKey <- map["pub_key"]
        ethTxHash <- map["eth_tx_hash"]
        ethAddress <- map["eth_addr"]
        viteAddress <- map["vite_addr"]
        value <- (map["value"], JSONTransformer.bigint)
        signature <- map["signature"]
    }

    init?(ethPrivateKey: Data, ethTxHash: String, ethAddress: String, viteAddress: String, value: BigInt) {
        guard let ecKey = SECP256K1.privateToPublic(privateKey: ethPrivateKey) else { return nil }
        let publicKey = "0x" + ecKey.toHexString()
        let source = "{\"pub_key\":\"\(publicKey)\",\"eth_tx_hash\":\"\(ethTxHash)\",\"eth_addr\":\"\(ethAddress)\",\"vite_addr\":\"\(viteAddress)\",\"value\":\"\(value.description)\"}"
        let hash = source.sha3(.keccak256)
        let s = SECP256K1.signForRecovery(hash: Data(hash.hex2Bytes), privateKey: ethPrivateKey)
        guard let serializedSignature = s.serializedSignature else { return nil }
        let signature = "0x" + serializedSignature.toHexString()
        
        self.publicKey = publicKey
        self.ethTxHash = ethTxHash
        self.ethAddress = ethAddress
        self.viteAddress = viteAddress
        self.value = value
        self.signature = signature
    }
}
