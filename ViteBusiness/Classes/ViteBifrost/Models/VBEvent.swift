//
//  VBEvent.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//

import Foundation

public enum VBEvent: String {
    case sessionRequest = "vb_sessionRequest"
    case sessionUpdate = "vb_sessionUpdate"
    case exchangeKey = "vb_exchangeKey"

    case sessionPeerPing = "vb_peerPing"
    case viteSendTx = "vite_signAndSendTx"
}

extension VBEvent {
    func decode<T: Codable>(_ data: Data) throws -> JSONRPCRequest<T> {
        return try JSONDecoder().decode(JSONRPCRequest<T>.self, from: data)
    }
}
