//
//  CrossChainExchange.swift
//  Action
//
//  Created by haoshenyang on 2019/6/13.
//

import Foundation


protocol CrossChainDeposit{

    var gatewayInfoService: CrossChainGatewayInfoService { get }

    //Send rival Tx
    func deposit(viteAddress: String, totId: String, amount: String)

}

