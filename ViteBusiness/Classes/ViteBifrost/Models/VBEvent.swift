//
//  VBEvent.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//

import Foundation

public enum VBEvent: String {
    case sessionRequest = "vc_sessionRequest"
    case sessionUpdate = "vc_sessionUpdate"
    case sessionPeerPing = "vc_peerPing"
    case viteSendTx = "vite_signAndSendTx"
    case viteSignMessage = "vite_signMessage"
}

extension VBEvent {
    func decode<T: Codable>(_ data: Data) throws -> JSONRPCRequest<T> {
        return try JSONDecoder().decode(JSONRPCRequest<T>.self, from: data)
    }
}
