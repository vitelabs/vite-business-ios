//
//  VBJSONRPC.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//

import Foundation
import ObjectMapper

public struct VBJSONRPCRequest<T: Mappable>: Mappable {
    public var id: Int64!
    public var jsonrpc: String!
    public var method: String!
    public var params: [T]!

    public init?(map: Map) {
        guard let jsonrpc = map.JSON["jsonrpc"] as? String, jsonrpc == "2.0" else {
            return nil
        }

        guard let method = map.JSON["method"] as? String, !method.isEmpty else {
            return nil
        }
    }

    public mutating func mapping(map: Map) {
        id <- map["id"]
        jsonrpc <- map["jsonrpc"]
        method <- map["method"]
        params <- map["params"]
    }
}

struct VBJSONRPCResponse<T: Mappable>: Mappable {

    public var jsonrpc = "2.0"
    public var id: Int64!
    public var result: T!

    init(id: Int64, result: T) {
        self.id = id
        self.result = result
    }

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        jsonrpc <- map["jsonrpc"]
        result <- map["result"]
    }
}
