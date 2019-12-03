//
//  DeFiSubscription.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import Foundation
import ObjectMapper
import BigInt
import ViteWallet

struct DeFiSubscription: Mappable {

    enum Status: Int {
        case onSale = 1
        case failed = 2
        case success = 3
        case refunding = 4
        case refunded = 5
    }

    fileprivate var productStatus: DeFiProductStatus!
    fileprivate var refundStatus: DeFiRefundStatus!

    var status: Status {
        switch productStatus! {
        case .onSale:
            return .onSale
        case .failed:
            return .failed
        case .success:
            return .success
        case .cancel:
            switch refundStatus! {
            case .invalid, .refunding:
                return .refunding
            case .refunded:
                return .refunded
            }
        }
    }

    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        productStatus <- map["productStatus"]
        refundStatus <- map["refundStatus"]
    }
}
