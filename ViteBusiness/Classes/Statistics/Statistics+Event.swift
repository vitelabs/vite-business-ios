//
//  Statistics+Event.swift
//  Vite
//
//  Created by Stone on 2018/10/23.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation

public extension Statistics {

    public enum Page {

        enum Debug: String {
            case test = "debug_page_test"
            static var name = "debug_page"
        }

        enum Common {
        }

        enum WalletHome: String {
            static var name = "wallet_home_page"

            case scanClicked = "home_scan"
            case addTokenclicked = "home_addToken"
            case enterTokenDetails = "home_%@Details"
            case tokenDetailsSendClicked = "home_%@Details_tx"
            case tokenDetailsReceiveClicked = "home_%@Details_receive"
            case voteClicked = "home_vite_viteDetails_vote"
            case quotaClicked = "home_vite_viteDetails_quota"
            case changeAddressClicked = "home_vite_viteDetails_changeAddress"
            case ethViteConversionClicked = "home_eth_viteDetails_conversion"
        }

        enum MyHome: String {
            static var name = "my_home_page"

            case contactClicked = "personal_contact"
            case contactAddClicked = "personal_contact_add"
            case contactAddSaveClicked = "personal_contact_add_save"
            case mnemonicClicked = "personal_mnemonic"
            case mnemonicDeriveClicked = "personal_mnemonic_derive"
            case mnemonicConfirmClicked = "personal_mnemonic_confirm"
            case settingClicked = "personal_setting"
            case inviteClicked = "personal_invite"
            case forumClicked = "personal_forum"
            case aboutClicked = "personal_about"
            case logoutClicked = "personal_logout"
        }

        enum WalletQuota: String {
            case submit = "wqp_submit_quota"
            case confirm = "wqp_confirm_quota"

            static var name = "wallet_quota_page"
        }
    }
}

extension TokenInfo {

    var statisticsId: String {
        if isViteCoin {
            return "\(coinType.rawValue.lowercased())_vite"
        } else if isEtherCoin {
            return "\(coinType.rawValue.lowercased())_eth"
        } else if isViteERC20 {
            return "\(coinType.rawValue.lowercased())_vite"
        } else if coinType == .vite && symbol == "VX" {
            return "\(coinType.rawValue.lowercased())_vx"
        } else if coinType == .grin {
            return "\(coinType.rawValue.lowercased())_grin"
        } else {
            return "\(coinType.rawValue.lowercased())_\(tokenCode)"
        }
    }
}
