//
//  Token.swift
//  Vite
//
//  Created by Stone on 2018/9/9.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet

extension Token {
    var backgroundColors: [UIColor] {
        return TokenCacheService.instance.backgroundColorsForId(id)
    }

    var icon: ImageWrapper {
        return TokenCacheService.instance.iconForId(id)
    }
}
