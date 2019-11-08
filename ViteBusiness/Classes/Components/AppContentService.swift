//
//  AppContentService.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/8.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import ObjectMapper

public class AppContentService {
    public static let instance = AppContentService()

    lazy var storageDriver: Driver<Storage> = self.storageBehaviorRelay.asDriver()
    fileprivate var storageBehaviorRelay: BehaviorRelay<Storage>!
    fileprivate var disposeBag = DisposeBag()
    private init() {

        if let storage: Storage = readMappable() {
            storageBehaviorRelay = BehaviorRelay(value: storage)
        } else {
            let item = MarketBannerItem(imageUrl: "http://129.226.74.210:1337/uploads/7a9a23cc0b2447f3913fd6792b5a7ba4.png", linkUrl: "https://forum.vite.net/topic/2655/vitex-%E4%BA%A4%E6%98%93%E6%89%80%E7%A7%BB%E5%8A%A8%E7%AB%AF%E6%93%8D%E4%BD%9C%E6%8C%87%E5%8D%97")
            storageBehaviorRelay = BehaviorRelay(value: Storage(marketBannerItems: [item]))
        }

        NotificationCenter.default.rx.notification(.languageChanged).asObservable().bind { [weak self] _ in
            self?.fetch()
        }.disposed(by: disposeBag)
    }

    public func start() {
        fetch()
    }

    fileprivate func fetch() {

        MarketConfigProvider.instance.getMarketBanner { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let marketBannerItems):
                let storage = Storage(marketBannerItems: marketBannerItems)
                self.storageBehaviorRelay.accept(storage)
                self.save(mappable: storage)
            case .failure(let error):
                plog(level: .warning, log: error.viteErrorMessage, tag: .getConfig)
                GCD.delay(2, task: { self.fetch() })
            }
        }
    }
}

extension AppContentService {

    public struct Storage: Mappable {
        fileprivate(set) var marketBannerItems: [MarketBannerItem] = []

        init(marketBannerItems: [MarketBannerItem]) {
            self.marketBannerItems = marketBannerItems
        }

        public init?(map: Map) { }

        public mutating func mapping(map: Map) {
            marketBannerItems <- map["marketBannerItems"]
        }
    }
}

extension AppContentService: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "AppContent", path: .app)
    }
}


