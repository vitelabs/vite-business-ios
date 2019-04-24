//
//  MyVoteInfoViewReactor.swift
//  Vite
//
//  Created by Water on 2018/11/6.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import ReactorKit
import RxCocoa
import RxSwift
import NSObject_Rx

final class MyVoteInfoViewReactor: Reactor {
    let account = HDWalletManager.instance.account ??  Wallet.Account(secretKey: "", publicKey: "", address: Address(string: ""))
    var disposeBag = DisposeBag()
    var pollingVoteInfoTask: GCD.Task?

    enum Action {
        case refreshData(String)
        case voting(String, Balance?)
        case cancelVote()
    }

    enum Mutation {
        case replace(voteInfo: VoteInfo?, voteStatus: VoteStatus?, error: Error?)
    }

    struct State {
        var voteInfo: VoteInfo?
        var voteStatus: VoteStatus?
        var error: Error?
    }

    var initialState: State

    init() {
        self.initialState = State.init(voteInfo: nil, voteStatus: nil, error: nil)
        self.pollingVoteInfoTask = {cancel in
            self.action.onNext(.refreshData(HDWalletManager.instance.account?.address.description ?? ""))
        }
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshData((let address)):
            return
                self.fetchVoteInfo(address).map { Mutation.replace(voteInfo: $0.0, voteStatus: .voteSuccess, error: $0.1) }

        case .voting(let nodeName, let banlance):
            return
                self.createLocalVoteInfo(nodeName, banlance, false).map { Mutation.replace(voteInfo: $0.0, voteStatus: .voting, error: nil) }

        case .cancelVote():
            return
                    Observable.just(Mutation.replace(voteInfo: nil, voteStatus: .cancelVoting, error:nil))

        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.error = nil
        switch mutation {
        case let .replace(voteInfo: voteInfo, voteStatus: voteStatus, error: error):
                newState.voteInfo = voteInfo
                newState.error = error
                newState.voteStatus = voteStatus
        }
        return newState
    }

    func createLocalVoteInfo(_ nodeName: String, _ balance: Balance?, _ isCancel: Bool)-> Observable<(VoteInfo, VoteStatus)> {
        return Observable<(VoteInfo, VoteStatus)>.create({ (observer) ->
            Disposable in
            let voteInfo = VoteInfo(nodeName, .valid, balance)
            observer.onNext((voteInfo, isCancel ? .cancelVoting : .voting))
            observer.onCompleted()
            return Disposables.create()
        })
    }

    func fetchVoteInfo(_ address: String) -> Observable<(VoteInfo?, Error? )> {
        return Observable<(VoteInfo?, Error?)>.create({ (observer) -> Disposable in
            Provider.default.getVoteInfo(gid: ViteWalletConst.ConsensusGroup.snapshot.id, address: Address(string: address))
                .done { (voteInfo) in
                    plog(level: .debug, log: String.init(format: "fetchVoteInfo  success address=%@, voteInfo.nodeName = %@", address, voteInfo?.nodeName ?? ""), tag: .vote)
                    observer.onNext((voteInfo, nil))
                    observer.onCompleted()
                }
                .catch { (error) in
                    plog(level: .debug, log: String.init(format: "fetchVoteInfo error  error = %d=%@", error.viteErrorCode.description, error.localizedDescription), tag: .vote)
                    observer.onNext((nil, error))
                    observer.onCompleted()
                }.finally { [weak self] in
                    self?.pollingVoteInfoTask =  GCD.delay(3, task: {
                        self?.action.onNext(.refreshData(HDWalletManager.instance.account?.address.description ?? ""))
                    })
            }
            return Disposables.create()
        })
    }
}
