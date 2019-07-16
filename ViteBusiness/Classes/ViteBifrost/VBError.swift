//
//  VBError.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//

import Foundation

public enum VBError: Error {
    case badServerResponse
    case badJSONRPCRequest
    case invalidSession
    case unknown
}
