//
//  VitePodRawLocalizationService.swift
//  ViteBusiness
//
//  Created by Stone on 2018/12/14.
//

import Foundation
import ViteUtils

class VitePodRawLocalizationService: VitePodLocalizationService {}

class VitePodRawBundle: VitePodLanguageBundle {
    override class func podLocalizationServiceClass() -> AnyClass {
        return VitePodRawLocalizationService.self
    }
}
