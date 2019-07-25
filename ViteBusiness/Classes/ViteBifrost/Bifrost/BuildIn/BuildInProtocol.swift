//
//  BuildInProtocol.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

protocol BuildInProtocol {
//    var description: VBViteSendTx.Description { get }
    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo>
}

protocol BuildInContractProtocol: BuildInProtocol {
    var abi: ABI.BuildIn { get }
}

protocol BuildInTransferProtocol: BuildInProtocol {
    func match(_ sendTx: VBViteSendTx) -> Bool
}

