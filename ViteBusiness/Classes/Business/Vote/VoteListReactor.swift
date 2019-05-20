//
//  VoteListReactor.swift
//  Vite
//
//  Created by haoshenyang on 2018/11/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import ReactorKit
import RxCocoa
import RxSwift
import APIKit

final class VoteListReactor {

    let search = Variable<String?>("")
    let vote = Variable<String>("")
    let fetchManually = PublishSubject<Void>()

    var fetchCandidateError = Variable<Error?>(nil)
    var voteSuccess = PublishSubject<Void>()
    var lastVoteInfo = Variable<(VoteStatus, VoteInfo?)>((.voteInvalid, nil))

    let account = DisposeBag()

    init() {
        vote.asObservable().skip(1).bind {
            self.vote(nodeName: $0)
        }.disposed(by: account)
    }

    func result() -> Observable<[Candidate]?> {
        let polling = Observable.concat([
                Observable<[Candidate]?>.create({ (observer) -> Disposable in
                    ViteNode.vote.info.getCandidateList(gid: ViteWalletConst.ConsensusGroup.snapshot.id)
                        .done { (candidates) in
                            observer.onNext(candidates)
                            observer.onCompleted()
                        }
                        .catch { [weak self] (error) in
                            self?.fetchCandidateError.value = error
                            observer.onCompleted()
                    }
                    return Disposables.create()
                }),

                Observable<Int>.interval(30, scheduler: MainScheduler.instance)
                .flatMap { [weak self] _ in
                    Observable<[Candidate]?>.create({ (observer) -> Disposable in
                        ViteNode.vote.info.getCandidateList(gid: ViteWalletConst.ConsensusGroup.snapshot.id)
                            .done { [weak self] (candidates) in
                                self?.fetchCandidateError.value = nil
                                observer.onNext(candidates)
                            }
                            .catch { [weak self] (error) in
                                self?.fetchCandidateError.value = error
                        }
                        return Disposables.create()
                    })
                }
        ])

        let statusChanged = NotificationCenter.default.rx.notification(.userVoteInfoChange)
            .map { notification -> (VoteStatus, VoteInfo?) in
                let info = notification.object as! [String: Any]
                return (info["voteStatus"] as! VoteStatus, info["voteInfo"] as? VoteInfo)
            }
            .distinctUntilChanged({ $0.0 == $1.0 && $0.1?.nodeName == $1.1?.nodeName })

        statusChanged.bind { self.lastVoteInfo.value = $0 }.disposed(by: account)

        let fetchWhenStatusChange = statusChanged
            .flatMapLatest({ (_, _)  in
                Observable<[Candidate]?>.create({ (observer) -> Disposable in
                    ViteNode.vote.info.getCandidateList(gid: ViteWalletConst.ConsensusGroup.snapshot.id)
                        .done { (candidates) in
                            observer.onNext(candidates)
                            observer.onCompleted()
                        }
                        .catch { (error) in
                            observer.onCompleted()
                    }
                    return Disposables.create()
                })
            })

        let fetchManually = self.fetchManually
            .flatMap({ [weak self] (_)  in
                Observable<[Candidate]?>.create({ (observer) -> Disposable in
                    ViteNode.vote.info.getCandidateList(gid: ViteWalletConst.ConsensusGroup.snapshot.id)
                        .done { (candidates) in
                            observer.onNext(candidates)
                            observer.onCompleted()
                        }
                        .catch { (error) in
                            self?.fetchCandidateError.value = error
                            observer.onCompleted()
                    }
                    return Disposables.create()
                })
            })

        let fetch = Observable.merge([fetchWhenStatusChange, fetchManually])

        return Observable.combineLatest(Observable.merge([polling, fetch]), self.search.asObservable())
            .map { [unowned self] (candidates, world) in
                return self.search(candidates: candidates, with: world)
            }.share()
    }

    func search(candidates: [Candidate]?, with world: String?) -> [Candidate]? {
        guard let candidates = candidates else {
            return nil
        }
        var result = candidates.sorted(by: {
            return $0.voteNum > $1.voteNum
        })

        for (index, candidate) in result.enumerated() {
            candidate.updateRank(index + 1)
        }

        if let world = world?.lowercased(), !world.isEmpty {
            result = []
            for candidate in candidates where candidate.name.lowercased().contains(world) || candidate.nodeAddr.description.lowercased().contains(world) {
                result.append(candidate)
            }
        }

        return result
    }

    func vote(nodeName: String) {
        Workflow.voteWithConfirm(account: HDWalletManager.instance.account!, name: nodeName) { (result) in
            if case .success = result {
                NotificationCenter.default.post(name: .userDidVote, object: nodeName)
                self.voteSuccess.onNext(Void())
            }
        }
    }

}
