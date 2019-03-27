//
//  VitePodRawLocalizationService.swift
//  ViteBusiness
//
//  Created by Stone on 2018/12/14.
//

import Foundation

class VitePodRawLocalizationService: VitePodLocalizationService {
    static let  sharedInstance = VitePodRawLocalizationService()
}

class VitePodRawBundle: VitePodLanguageBundle {
    override class func podLocalizationServicesharedInstance() -> VitePodLocalizationService {
        return VitePodRawLocalizationService.sharedInstance
    }
}
