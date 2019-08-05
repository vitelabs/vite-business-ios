//
//  QuicklyGetQuota.swift
//  Vite
//
//  Created by Stone on 2018/12/20.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import UIKit
import ViteWallet
import Vite_HDWalletKit
import PromiseKit
import BigInt
import enum Alamofire.Result

public extension Workflow {

    public static func quicklyGetQuota(completion: @escaping (Result<AccountBlock>) -> ()) {
        QuicklyGetQuotaConfirmView(completion: { (_, ret) in
            completion(ret)
        }, canceled: { (_) in
            completion(Result.failure(ViteError.cancel))
        }).show()
    }
}
