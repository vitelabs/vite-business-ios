//
//  TransactionDetailHolder.swift
//  ViteBusiness
//
//  Created by Stone on 2020/5/14.
//

import Foundation
import PromiseKit

class TransactionDetailHolder {

    let initialState: PageState
    let fetch: (() -> Promise<ViewModel>)?

    init(vm: ViewModel) {
        initialState = .success(vm: vm)
        fetch = nil
    }

    init(fetch: @escaping () -> Promise<ViewModel>) {
        self.initialState = .loading
        self.fetch = fetch
    }

    func bind(u: @escaping (PageState) -> Void) {
        u(initialState)

        if let fetch = fetch {
            tryFetch(u: u)
        }
    }

    func tryFetch(u: @escaping (PageState) -> Void) {
        guard let fetch = self.fetch else { return }

        fetch().done { [weak self] (vm) in
            guard let `self` = self else { return }
            u(.success(vm: vm))
        }.catch { [weak self] (error) in
            guard let `self` = self else { return }
            u(.failed(error, { [weak self ] in
                guard let `self` = self else { return }
                self.tryFetch(u: u)
            }))
        }
    }

}

extension TransactionDetailHolder {

    enum PageState {
        case loading
        case success(vm: ViewModel)
        case failed(Error, () -> Void)
    }

    enum Item {
        case address(title: String, text: String, hasSeparator: Bool)
        case ammount(title: String, text: String, symbol: String)
        case copyable(title: String, text: String, rawText: String)
        case height(title: String, text: String)
        case note(title: String, text: String)
    }

    struct Link {
        let text: String
        let url: URL
    }

    struct ViewModel {
        let headerImage: UIImage
        let stateString: String
        let timeString: String
        let items: [Item]
        let link: Link
    }
}
