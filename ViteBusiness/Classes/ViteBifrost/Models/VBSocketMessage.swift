//
//  SocketMessage.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//


import Foundation

public struct VBEncryptionPayload: Codable {
    public let data: String
    public let hmac: String
    public let iv: String

    public init(data: String, hmac: String, iv: String) {
        self.data = data
        self.hmac = hmac
        self.iv = iv
    }
}

public struct VBSocketMessage<T: Codable>: Codable {
    public enum MessageType: String, Codable {
        case pub
        case sub
    }
    public let topic: String
    public let type: MessageType
    public let payload: T
}

public extension VBEncryptionPayload {
    static func extract(_ string: String) -> (topic: String, payload: VBEncryptionPayload)? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            if let message = try? decoder.decode(VBSocketMessage<VBEncryptionPayload>.self, from: data) {
                return (message.topic, message.payload)
            } else {
                let message = try decoder.decode(VBSocketMessage<String>.self, from: data)
                let payloadData = message.payload.data(using: .utf8)
                return  (message.topic, try decoder.decode(VBEncryptionPayload.self, from: payloadData!))
            }
        } catch let error {
            print(error)
        }
        return nil
    }
}
