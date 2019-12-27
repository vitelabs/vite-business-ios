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
//            case 已付利息退款 = 2
            case 认购金额 = 3
            case 到期认购金额 = 4
            case 认购收益 = 5
            case 认购失败退款 = 6
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
            case 借币到期还款 = 18
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
    case getSubscriptionDetail(address: ViteAddress, productHash: String)
    case getLoanUsageOptions(hash: String, userAmount: Amount, currentSnapshotHeight: UInt64, loanEndSnapshotHeight: UInt64)
    case getDeFiProfits(address: ViteAddress)

    var baseURL: URL {
//        return URL(string: "http://192.168.31.213:8081/dev/")!
        return URL(string: "http://132.232.65.121:8081/test/")!
        return URL(string: ViteConst.instance.vite.x)!
    }

    var path: String {
        switch self {
        case .getDeFiLoans:
            return "api/v1/defi/products/loan"
        case .getSubscriptions:
            return "api/v1/defi/products/subscription"
        case .getSubscriptionDetail:
            return "api/v1/defi/product/subscription"
        case .getProductDetail:
            return "api/v1/defi/product/loan"
        case .getBills:
            return "api/v1/defi/account/bills"
        case .getUsage:
            return "api/v1/defi/assets/usage"
        case .getLoanUsageOptions:
            return "api/v1/defi/usage/options"
        case .getDeFiProfits:
            return "api/v1/defi/account/profits"
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

        case .getSubscriptionDetail(let address, let productHash):
            let parameters: [String: Any] = [
                "address": address,
                "productHash": productHash
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getLoanUsageOptions(hash, userAmount, currentSnapshotHeight, loanEndSnapshotHeight):
            let parameters: [String: Any] = [
                "productHash": hash,
                "userAmount": userAmount.description,
                "currentSnapshotHeight": currentSnapshotHeight,
                "loanEndSnapshotHeight": loanEndSnapshotHeight
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getDeFiProfits(address):
            let parameters: [String: Any] = [
                "address": address
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    static var testStatus = DeFiProductStatus.onSale

    var sampleData: Data {
        switch self {
        case .getDeFiLoans:
            let str = "{ \"code\": 0, \"msg\": \"ok\", \"data\": [ { \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\", \"subscriptionEndTime\": 1554722699, \"subscriptionFinishTime\": 1554722699, \"subscriptionFinishHeight\": 1554722699, \"loanEndSnapshotHeight\": 1554722699, \"loanEndTime\": 1554722699, \"yearRate\": \"0.02\", \"dayRate\": \"0.02\", \"loanAmount\": \"100000000000000000000\", \"loanPayable\": \"100000000000000000000\", \"loanUsedAmount\": \"100000000000000000000\", \"singleCopyAmount\": \"10.000000000000000000\", \"loanDuration\": 3, \"subscribedAmount\": \"100000000000000000000\", \"loanCompleteness\": \"0.10\", \"productStatus\": 1, \"refundStatus\": 1 } ] }"
            return str.data(using: .utf8, allowLossyConversion: false) ?? Data()
        case .getSubscriptions:
           let str =  "{ \"msg\" : \"success\", \"data\" : [ { \"singleCopyAmount\" : \"1000000000000000000000\", \"loanCompleteness\" : \"0.98\", \"productStatus\" : 2, \"loanAmount\" : \"2000000000000000000000000\", \"refundStatus\" : 0, \"subscribedAmount\" : \"1950000000000000000000000\", \"yearRate\" : \"0.182500\", \"mySubscribedAmount\" : \"1950000000000000000000000\", \"loanDuration\" : 12, \"productHash\" : \"1\", \"subscriptionEndTime\" : 259200 }, { \"singleCopyAmount\" : \"1000000000000000000000\", \"loanCompleteness\" : \"0.98\", \"productStatus\" : 1, \"loanAmount\" : \"2000000000000000000000000\", \"refundStatus\" : 0, \"subscribedAmount\" : \"1950000000000000000000000\", \"yearRate\" : \"0.182500\", \"mySubscribedAmount\" : \"1950000000000000000000000\", \"loanDuration\" : 12, \"productHash\" : \"1\", \"subscriptionEndTime\" : 259200 }, { \"singleCopyAmount\" : \"100000000000000000000\", \"loanCompleteness\" : \"1.00\", \"productStatus\" : 3, \"loanAmount\" : \"10000000000000000000000\", \"refundStatus\" : 0, \"subscribedAmount\" : \"10000000000000000000000\", \"yearRate\" : \"0.365000\", \"mySubscribedAmount\" : \"10000000000000000000000\", \"loanDuration\" : 360, \"productHash\" : \"3\", \"subscriptionEndTime\" : 604800 }, { \"singleCopyAmount\" : \"10000000000000000000\", \"loanCompleteness\" : \"1.00\", \"productStatus\" : 3, \"loanAmount\" : \"20000000000000000000\", \"refundStatus\" : 0, \"subscribedAmount\" : \"20000000000000000000\", \"yearRate\" : \"0.450410\", \"mySubscribedAmount\" : \"20000000000000000000\", \"loanDuration\" : 1, \"productHash\" : \"4\", \"subscriptionEndTime\" : 86400 } ], \"code\" : 0 }"
            return str.data(using: .utf8, allowLossyConversion: false) ?? Data()
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
            let str = "{  \"code\": 0,  \"msg\": \"ok\",  \"data\": [{    \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",    \"accountType\": 1,    \"billType\": 2,    \"billAmount\": \"1000000000000000000000\",    \"billTime\": 1554722699   },   {    \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",    \"accountType\": 2,    \"billType\": 3,    \"billAmount\": \"-1000000000000000000000\",    \"billTime\": 1554722699   },   {    \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",    \"accountType\": 1,    \"billType\": 2,    \"billAmount\": \"1000000000000000000000\",    \"billTime\": 1554722699   }  ] }"
            return str.data(using: .utf8, allowLossyConversion: false) ?? Data()
        case .getUsage:
            let str = "{ \"msg\": \"success\", \"data\": [{ \"usageType\": 1, \"usageHash\": \"1\", \"usageInfo\": \"{\\\"pledgeAmount\\\":\\\"100000000000000000000\\\",\\\"pledgeDueHeight\\\":15438,\\\"pledgeDueTime\\\":1577331783,\\\"pledgeTime\\\":1577331183,\\\"quoteAddress\\\":\\\"vite_02113a18a29e92b92ec4997da1b772cc00eb2c3afd0bb685bd\\\",\\\"svipAddress\\\":\\\"vite_02113a18a29e92b92ec4997da1b772cc00eb2c3afd0bb685bd\\\"}\", \"amountInfo\": \"{\\\"baseAmount\\\":\\\"100000000000000000000\\\",\\\"loanAmount\\\":\\\"100000000000000000000\\\"}\", \"usageTime\": 1577331183, \"productHash\": \"3\" }, { \"usageType\": 2, \"usageHash\": \"2\", \"usageInfo\": \"{\\\"svipAddress\\\":\\\"vite_02113a18a29e92b92ec4997da1b772cc00eb2c3afd0bb685bd\\\",\\\"pledgeAmount\\\":\\\"10000000000000000\\\",\\\"pledgeTime\\\":100200240,\\\"pledgeDueTime\\\":100200240,\\\"pledgeDueHeight\\\":100200240}\", \"amountInfo\": \"{\\\"baseAmount\\\":\\\"100000000000000000000\\\",\\\"loanAmount\\\":\\\"9000000000000000000000\\\"}\", \"usageTime\": 1577331183, \"productHash\": \"3\" }, { \"usageType\": 3, \"usageHash\": \"2\", \"usageInfo\": \"{\\\"sbpName\\\":\\\"OK\\\",\\\"pledgeAmount\\\":\\\"10000000000000\\\",\\\"blockProducingAddress\\\":\\\"vite_02113a18a29e92b92ec4997da1b772cc00eb2c3afd0bb685bd\\\",\\\"rewardWithdrawAddress\\\":\\\"vite_02113a18a29e92b92ec4997da1b772cc00eb2c3afd0bb685bd\\\",\\\"pledgeTime\\\":100200240,\\\"pledgeDueTime\\\":100200240,\\\"pledgeDueHeight\\\":100200240}\", \"amountInfo\": \"{\\\"baseAmount\\\":\\\"100000000000000000000\\\",\\\"loanAmount\\\":\\\"9000000000000000000000\\\"}\", \"usageTime\": 1577331183, \"productHash\": \"3\" }, { \"usageType\": 4, \"usageHash\": \"2\", \"usageInfo\": \"{\\\"pledgeAmount\\\":\\\"10000000000000\\\",\\\"pledgeTime\\\":100200240,\\\"pledgeDueTime\\\":100200240,\\\"pledgeDueHeight\\\":100200240}\", \"amountInfo\": \"{\\\"baseAmount\\\":\\\"100000000000000000000\\\",\\\"loanAmount\\\":\\\"9000000000000000000000\\\"}\", \"usageTime\": 1577331183, \"productHash\": \"3\" } ], \"code\": 0 }"
            return str.data(using: .utf8, allowLossyConversion: false) ?? Data()
        case .getSubscriptionDetail:
            let str = "{ \"code\": 0, \"msg\": \"ok\", \"data\": [{ \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\", \"yearRate\": \"0.02\", \"loanAmount\": \"100000000000000000000\", \"subscribedAmount\": \"100000000000000000000\", \"subscriptionBeginTime\": 1, \"subscriptionEndTime\": 2, \"subscriptionFinishTime\": 3, \"singleCopyAmount\": \"10.000000000000000000\", \"subscriptionCopies\": 3, \"subscribedCopies\": 1, \"leftCopies\": 2, \"mySubscribedAmount\": \"100000000000000000000\", \"mySubscribedCopies\": 1, \"totalProfits\": \"10.000000000000000000\", \"dayProfits\": \"3.000000000000000000\", \"earnProfits\": \"3.000000000000000000\", \"loanDuration\": 3, \"loanCompleteness\": \"0.10\", \"productStatus\": 1, \"refundStatus\": 1 }] }"
            return str.data(using: .utf8, allowLossyConversion: false) ?? Data()
        default:
            return Data()
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
