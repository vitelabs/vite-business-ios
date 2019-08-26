//
//  SASConfirmViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/22.
//

import PromiseKit
import ViteWallet

// MARK: Protocol
protocol SASConfirmViewModel {
    func confirmInfo(uri: ViteURI, tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo>
}

protocol SASConfirmViewModelContract: SASConfirmViewModel {
    var abi: ABI.BuildIn { get }
}

protocol SASConfirmViewModelTransfer: SASConfirmViewModel {
    func match(uri: ViteURI) -> Bool
}

extension SASConfirmViewModelTransfer {

    func match(uri: ViteURI, contentTypeInUInt16: UInt16) -> Bool {
        if let data = uri.data, data.contentTypeInUInt16 == contentTypeInUInt16 {
            return true
        } else {
            return false
        }
    }
}

// MARK: Factory
struct SASConfirmViewModelFactory {

    static public func generateViewModel(_ uri: ViteURI) -> Promise<(BifrostConfirmInfo, TokenInfo)> {
        return Promise<TokenInfo> { seal in
            MyTokenInfosService.instance.tokenInfo(forViteTokenId: uri.tokenId) { result in
                switch result {
                case .success(let r):
                    seal.fulfill(r)
                case .failure(let e):
                    seal.reject(e)
                }
            }
            }.then({ (tokenInfo) -> Promise<(BifrostConfirmInfo, TokenInfo)> in

                switch uri.type {
                case .transfer:
                    if let type = BuildInTransfer.matchType(uri: uri) {
                        return type.viewModel.confirmInfo(uri: uri, tokenInfo: tokenInfo).map { ($0, tokenInfo) }
                    } else {
                        return SASConfirmViewModelTransferNormal().confirmInfo(uri: uri, tokenInfo: tokenInfo).map { ($0, tokenInfo) }
                    }
                case .contract:
                    let map = BuildInContract.toAddressAndDataPrefixMap
                    if let data = uri.data, data.count >= 4,
                        let type = map["\(uri.address)_\(data[0..<4].toHexString())"] {
                        return type.viewModel.confirmInfo(uri: uri, tokenInfo: tokenInfo).map { ($0, tokenInfo) }
                    } else {
                        return SASConfirmViewModelContractOther().confirmInfo(uri: uri, tokenInfo: tokenInfo).map { ($0, tokenInfo) }
                    }
                }
            })
    }

    enum BuildInTransfer: CaseIterable {

        case viteStore

        fileprivate var viewModel: SASConfirmViewModelTransfer {
            switch self {
            case .viteStore:
                return SASConfirmViewModelTransferViteStore()
            }
        }

        fileprivate static func matchType(uri: ViteURI) -> BuildInTransfer? {
            for type in BuildInTransfer.allCases {
                if type.viewModel.match(uri: uri) {
                    return type
                }
            }
            return nil
        }
    }


    enum BuildInContract: CaseIterable {

        case vote

        fileprivate var viewModel: SASConfirmViewModelContract {
            switch self {
            case .vote:
                return SASConfirmViewModelContractVote()
            }
        }

        fileprivate static let toAddressAndDataPrefixMap: [String: BuildInContract] =
            BuildInContract.allCases.reduce([String: BuildInContract]()) { (r, c) -> [String: BuildInContract] in
                var ret = r
                let abi = c.viewModel.abi
                let key = "\(abi.toAddress)_\(abi.encodedFunctionSignature.toHexString())"
                ret[key] = c
                return ret
        }
    }
}
