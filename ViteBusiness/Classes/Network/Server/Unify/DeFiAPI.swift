//
//  DeFiAPI.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/13.
//

import Moya
import ViteWallet

enum DeFiAPI: TargetType {

    enum ProductSortType: String, CaseIterable {
        case PUB_TIME_DESC
        case SUB_TIME_REMAINING_ASC
        case YEAR_RATE_DESC
        case LOAN_DURATION_ASC
        case LOAN_COMPLETENESS_DESC
    }

    enum ProductStatus: Int, CaseIterable {
        case all = 0
        case onSale = 1
        case failed = 2
        case success = 3
        case cancel = 4
    }


    struct Bill {
        enum BillType: Int, CaseIterable {
            case 全部 = 0
            case 已付利息 = 1
            case 已付利息退款 = 2
            case 认购金额 = 3
            case 到期认购金额 = 4
            case 认购收益 = 5
            case 认购金额退款 = 6
            case 注册SBP = 7
            case 注册SBP退款 = 8
            case 开通交易所SVIP = 9
            case 开通交易所SVIP退款 = 10
            case 获取配额 = 11
           case 获取配额退款 = 12
           case 抵押挖矿 = 13
           case 抵押挖矿退款 = 14
           case 划转收入 = 15
            case 划转支出 = 16
            case 成功借币 = 17
        }

        enum AccountType: Int, CaseIterable {
            case 全部 = 0
            case 基础账户 = 1
            case 借币账户 = 2
        }
    }

    case getDeFiLoans(sortType: ProductSortType?, status: ProductStatus, address: ViteAddress?, offset: Int, limit: Int)
    case getSubscriptions(status: ProductStatus, address: ViteAddress?, offset: Int, limit: Int)

    case getProductDetail(hash: String)

    case getBills(address: ViteAddress,accountType: DeFiAPI.Bill.AccountType,billType: DeFiAPI.Bill.BillType,productHash: String?, offset: Int, limit: Int)
    case getUsage(address: ViteAddress,productHash: String?)

    var baseURL: URL {
        return URL(string: ViteConst.instance.vite.x)!
    }

    var path: String {
        switch self {
        case .getDeFiLoans:
            return "api/v1/defi/products/loan"
        case .getSubscriptions:
            return "api/v1/defi/products/subscription"
        case .getProductDetail:
            return "api/v1/defi/product/loan"
        case .getBills:
            return "api/v1/defi/account/bills"
        case .getUsage:
            return "api/v1/defi/assets/usage"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .getDeFiLoans(sortType, status, address, offset, limit):
            var parameters: [String: String] = [
                "productStatus": String(status.rawValue),
                "offset": String(offset),
                "limit": String(limit)
            ]

            if let sortType = sortType {
                parameters["orderBy"] = sortType.rawValue
            }

            if let address = address {
                parameters["address"] = address
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getSubscriptions(status, address, offset, limit):
            var parameters: [String: String] = [
                "productStatus": String(status.rawValue),
                "offset": String(offset),
                "limit": String(limit)
            ]

            if let address = address {
                parameters["address"] = address
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getProductDetail(hash):
            let parameters: [String: String] = [
                "productHash": hash,
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getBills(address, accountType, billType, productHash, offset, limit):
            var parameters: [String: Any] = [
                "address": address,
                "accountType": accountType.rawValue,
                "billType": billType.rawValue,
                "offset": String(offset),
                "limit": String(limit)
            ]
            if let productHash = productHash {
                parameters["productHash"] = productHash
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getUsage(address, productHash):
           var parameters: [String: String] = [
               "address": address,
           ]
           if let productHash = productHash {
               parameters["productHash"] = productHash
           }
           return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

        }
    }

    static var testStatus = DeFiProductStatus.onSale

    var sampleData: Data {
        switch self {
        case .getDeFiLoans:
            return Data()
        case .getSubscriptions:
            return Data()
        case .getProductDetail:

            let str: String
            switch type(of: self).testStatus {
            case .onSale:
                type(of: self).testStatus = .failed
                str = "{  \"code\": 0,  \"msg\": \"ok\",  \"data\": {   \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",   \"subscriptionBeginTime\": 1554722699,   \"subscriptionEndTime\": 1585893380,   \"subscriptionFinishTime\": 1554722699,   \"yearRate\": \"0.02\",   \"loanAmount\": \"1000000000000000000000\",   \"subscriptionCopies\": 10000,   \"singleCopyAmount\": \"10000000000000000000\",   \"loanDuration\": 3,   \"subscribedAmount\": \"1000000000000000000000\",   \"loanCompleteness\": \"0.10\",   \"productStatus\": 1,   \"refundStatus\": 1  } }"
            case .failed:
                type(of: self).testStatus = .success
                str = "{  \"code\": 0,  \"msg\": \"ok\",  \"data\": {   \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",   \"subscriptionBeginTime\": 1554722699,   \"subscriptionEndTime\": 1585893380,   \"subscriptionFinishTime\": 1554722699,   \"yearRate\": \"0.02\",   \"loanAmount\": \"1000000000000000000000\",   \"subscriptionCopies\": 10000,   \"singleCopyAmount\": \"10000000000000000000\",   \"loanDuration\": 3,   \"subscribedAmount\": \"1000000000000000000000\",   \"loanCompleteness\": \"0.10\",   \"productStatus\": 2,   \"refundStatus\": 1  } }"
            case .success:
                type(of: self).testStatus = .cancel
                str = "{  \"code\": 0,  \"msg\": \"ok\",  \"data\": {   \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",   \"subscriptionBeginTime\": 1554722699,   \"subscriptionEndTime\": 1585893380,   \"subscriptionFinishTime\": 1554722699,   \"yearRate\": \"0.02\",   \"loanAmount\": \"1000000000000000000000\",   \"subscriptionCopies\": 10000,   \"singleCopyAmount\": \"10000000000000000000\",   \"loanDuration\": 3,   \"subscribedAmount\": \"1000000000000000000000\",   \"loanCompleteness\": \"0.10\",   \"productStatus\": 3,   \"loanUsedAmount\": 3000000000000000000000, \"refundStatus\": 1  } }"
            case .cancel:
                type(of: self).testStatus = .onSale
                str = "{  \"code\": 0,  \"msg\": \"ok\",  \"data\": {   \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",   \"subscriptionBeginTime\": 1554722699,   \"subscriptionEndTime\": 1585893380,   \"subscriptionFinishTime\": 1554722699,   \"yearRate\": \"0.02\",   \"loanAmount\": \"1000000000000000000000\",   \"subscriptionCopies\": 10000,   \"singleCopyAmount\": \"10000000000000000000\",   \"loanDuration\": 3,   \"subscribedAmount\": \"1000000000000000000000\",   \"loanCompleteness\": \"0.10\",   \"productStatus\": 4,   \"refundStatus\": 1  } }"
            }

            return str.data(using: .utf8, allowLossyConversion: false) ?? Data()
        case .getBills:
            let str = "{  \"code\": 0,  \"msg\": \"ok\",  \"data\": [{    \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",    \"accountType\": 1,    \"billType\": 2,    \"billAmount\": \"1000.000000000000000000\",    \"billTime\": 1554722699   },   {    \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",    \"accountType\": 2,    \"billType\": 3,    \"billAmount\": \"-1000.000000000000000000\",    \"billTime\": 1554722699   },   {    \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",    \"accountType\": 1,    \"billType\": 2,    \"billAmount\": \"1000.000000000000000000\",    \"billTime\": 1554722699   }  ] }"
            return str.data(using: .utf8, allowLossyConversion: false) ?? Data()
        case .getUsage:
            let str = "{ \"code\": 0, \"msg\": \"ok\", \"data\": [{ \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\", \"usageHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\", \"usageType\": 1, \"usageInfo\": { \"bsseAmount\": \"10000000000000\", \"loanAmount\": \"10000000000000\" }, \"amountInfo\": { \"sbpName\": \"OK\", \"pledgeAmount\": \"10000000000000\", \"blockProducingAddress\": \"vite_ssss\", \"rewardWithdrawAddress\": \"vite_aas\", \"pledgeTime\": 100200240, \"pledgeDueTime\": 100200240, \"pledgeDueHeight\": 100200240 }, \"usage_status\": 1, \"usageTime\": 1554722699 }, { \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\", \"usageHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\", \"usageType\": 2, \"usageInfo\": { \"bsseAmount\": \"10000000000000\", \"loanAmount\": \"10000000000000\" }, \"amountInfo\": { \"quotaAddress\": \"OK\", \"pledgeAmount\": \"10000000000000\", \"pledgeTime\": 100200240, \"pledgeDueTime\": 100200240, \"pledgeDueHeight\": 100200240 }, \"usage_status\": 1, \"usageTime\": 1554722699 }, { \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\", \"usageHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\", \"usageType\": 3, \"usageInfo\": { \"bsseAmount\": \"10000000000000\", \"loanAmount\": \"10000000000000\" }, \"amountInfo\": { \"sbpName\": \"OK\", \"pledgeAmount\": \"10000000000000\", \"blockProducingAddress\": \"vite_ssss\", \"rewardWithdrawAddress\": \"vite_aas\", \"pledgeTime\": 100200240, \"pledgeDueTime\": 100200240, \"pledgeDueHeight\": 100200240 }, \"usage_status\": 1, \"usageTime\": 1554722699 }, { \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\", \"usageHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\", \"usageType\": 4, \"usageInfo\": { \"bsseAmount\": \"10000000000000\", \"loanAmount\": \"10000000000000\" }, \"amountInfo\": { \"pledgeAmount\": \"10000000000000\", \"pledgeTime\": 100200240, \"pledgeDueTime\": 100200240, \"pledgeDueHeight\": 100200240 }, \"usage_status\": 1, \"usageTime\": 1554722699 } ] }"
            return str.data(using: .utf8, allowLossyConversion: false) ?? Data()
        default:
            return Data()
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
