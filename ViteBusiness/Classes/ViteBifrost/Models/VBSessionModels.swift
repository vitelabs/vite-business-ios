
//
//  VBSessionUpdate.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//


import Foundation

public struct VBSessionRequestParam: Codable {
    let peerId: String
    let peerMeta: VBPeerMeta
    let chainId: String?
}

public struct VBSessionPingParam: Codable {}

public struct VBSessionPingResponse: Codable {}

public struct VBSessionUpdateParam: Codable {
    public let approved: Bool
    public let chainId: Int?
    public let accounts: [String]?

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(approved, forKey: .approved)
        try container.encode(chainId, forKey: .chainId)
        try container.encode(accounts, forKey: .accounts)
    }
}

public struct VBApproveSessionResponse: Codable {
    public let approved: Bool
    public let chainId: Int
    public let accounts: [String]

    public let peerId: String?
    public let peerMeta: VBClientMeta?
}

