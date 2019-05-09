//
//  MyVoteInfoViewController.swift
//  Vite
//
//  Created by Water on 2018/11/5.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import BigInt
import RxSwift
import ReactorKit
import RxDataSources

class MyVoteInfoViewController: BaseViewController, View {
    // FIXME: Optional
    let account = HDWalletManager.instance.account!
    var disposeBag = DisposeBag()
    var balance: Balance?
    var oldVoteInfo: VoteInfo?

    init() {
        super.init(nibName: nil, bundle: nil)
        self.reactor = MyVoteInfoViewReactor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self._setupView()
        self._bindView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self._pollingInfoData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GCD.cancel(self.reactor?.pollingVoteInfoTask)
    }

    private func _pollingInfoData () {
        self.reactor?.action.onNext(.refreshData(HDWalletManager.instance.account?.address.description ?? ""))

    }

    private func _bindView() {
        //home page vite balance
        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: ViteWalletConst.viteToken.id)
            .drive(onNext: { [weak self] balanceInfo in
                guard let `self` = self else { return }
                if let balanceInfo = balanceInfo {
                    self.balance = balanceInfo.balance
                } else {
                    if self.viewInfoView.voteStatus == .voting {
                        // no balanceInfo, set 0.0
                        self.viewInfoView.nodePollsLab.text = Balance().amountFull(decimals: ViteWalletConst.viteToken.decimals)
                    }
                }
            }).disposed(by: rx.disposeBag)

        //change address
        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] _ in
            self?.viewInfoView.resetView()
            self?.viewInfoView.isHidden = true
            self?.voteInfoEmptyView.isHidden = false
        }).disposed(by: disposeBag)

        self.viewInfoView.nodeStatusLab.tipButton.rx.tap.bind {
            let htmlString = R.string.localizable.popPageTipVoteLoser(self.viewInfoView.voteInfo?.nodeName ?? "", self.viewInfoView.voteInfo?.nodeName ?? "")
            let vc = PopViewController(htmlString: htmlString)
            vc.modalPresentationStyle = .overCurrentContext
            let delegate =  StyleActionSheetTranstionDelegate()
            vc.transitioningDelegate = delegate
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        }.disposed(by: rx.disposeBag)

        //handle cancel vote
        self.viewInfoView.operationBtn.rx.tap.bind {[weak self] _ in
            self?.cancelVoteAction()
        }.disposed(by: rx.disposeBag)

        //vote success
        _ = NotificationCenter.default.rx.notification(.userDidVote).takeUntil(self.rx.deallocated).observeOn(MainScheduler.instance).subscribe({[weak self] (notification)   in
            let nodeName = notification.element?.object
             plog(level: .debug, log: String.init(format: "notification  userDidVote voteInfo.nodeName = %@",  nodeName as! String), tag: .vote)
            self?.reactor?.action.onNext(.voting(nodeName as! String, self?.balance))
        })
    }

    private func _setupView() {
        self._addViewConstraint()
    }

    private func _addViewConstraint() {
        view.backgroundColor = .clear

        view.addSubview(self.viewInfoView)
        self.viewInfoView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }

        view.addSubview(self.voteInfoEmptyView)
        self.voteInfoEmptyView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        self.viewInfoView.isHidden = true
        self.voteInfoEmptyView.isHidden = false
    }

    lazy var viewInfoView: VoteInfoView = {
        let viewInfoView = VoteInfoView()
        return viewInfoView
    }()

    lazy var voteInfoEmptyView: VoteInfoEmptyView = {
        let voteInfoEmptyView = VoteInfoEmptyView()
        return voteInfoEmptyView
    }()
}

extension MyVoteInfoViewController {
    private func refreshVoteInfoView(_ voteInfo: VoteInfo, _ voteStatus: VoteStatus) {
        UIView.animate(withDuration: 0.3) {
            self.viewInfoView.isHidden = false
            self.voteInfoEmptyView.isHidden = true
        }
        self.viewInfoView.reloadData(voteInfo, voteInfo.nodeStatus == .invalid ? .voteInvalid :voteStatus)

        self.notificationList(voteInfo, voteStatus)
    }

    private func notificationList(_ voteInfo: VoteInfo?, _ voteStatus: VoteStatus) {
        var status = voteStatus
        if voteInfo?.nodeStatus == .invalid {
            status = .voteInvalid
        }
        NotificationCenter.default.post(name: .userVoteInfoChange, object: ["voteInfo": voteInfo ?? VoteInfo(), "voteStatus": status])
        plog(level: .info, log: String.init(format: " voteStatus = %d voteInfo.nodeName  = %@", status.rawValue, voteInfo?.nodeName ?? ""), tag: .vote)
    }

    func bind(reactor: MyVoteInfoViewReactor) {
        //handle new vote data coming
        reactor.state
            .map { ($0.voteInfo, $0.voteStatus, $0.error) }
            .bind {[weak self] in
                guard let voteStatus = $1 else {
                    return
                }
                //handle cancel vote
                if voteStatus == .cancelVoting {
                    self?.viewInfoView.changeInfoCancelVoting()
                    HUD.hide()
                    return
                }
                guard let error = $2 else {
                    guard let voteInfo = $0 else {
                        //voteInfo == nil && old voteStatus = voting
                        if self?.viewInfoView.voteStatus != .voting {
                            UIView.animate(withDuration: 0.3, animations: {
                                self?.viewInfoView.resetView()
                                self?.viewInfoView.isHidden = true
                                self?.voteInfoEmptyView.isHidden = false
                            })
                        }
                        self?.oldVoteInfo = nil
                        self?.notificationList(nil, .noVote)
                        return
                    }
                    //server node can't affirm
                    if self?.oldVoteInfo?.nodeName == voteInfo.nodeName &&
                        (self?.viewInfoView.voteStatus == .cancelVoting) {
                        return
                    }
                    //voteInfo != nil && new voteStatus = voting, old  voteInfo
                    if voteStatus != .voting && voteStatus != .cancelVoting {
                        self?.oldVoteInfo = voteInfo
                    }

                    plog(level: .debug, log: String.init(format: "self?.oldVoteInfo=%@  , voteInfo.nodeName = %@, voteStatus=%@ ", self?.oldVoteInfo?.nodeName ?? "", voteInfo.nodeName ?? "", voteStatus.display ), tag: .vote)
                    self?.refreshVoteInfoView(voteInfo, voteStatus)
                    return
                }
                self?.oldVoteInfo = nil
            }.disposed(by: disposeBag)
    }
}

extension MyVoteInfoViewController {
    private func cancelVoteAction() {
         DispatchQueue.main.async {
            Workflow.cancelVoteWithConfirm(account: self.reactor!.account, name: self.viewInfoView.voteInfo?.nodeName ?? "", completion: { (r) in
                if case .success = r {
                    self.reactor?.action.onNext(.cancelVote())
                }
            })
         }
    }

}
