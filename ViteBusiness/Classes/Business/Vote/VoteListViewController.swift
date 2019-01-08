//
//  VoteListViewController.swift
//  Vite
//
//  Created by Water on 2018/11/5.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import RxCocoa
import RxSwift
import SnapKit
import NSObject_Rx
import RxDataSources
import ViteUtils

class VoteListViewController: BaseViewController {

    let reactor = VoteListReactor()
    let tableView = UITableView()
    let searchBar = SearchBar()
    let emptyView =  UILabel().then {
        $0.text = R.string.localizable.voteListSearchEmpty()
        $0.textAlignment = .center
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = R.string.localizable.voteListTitle()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = UIColor.init(netHex: 0x3e4a59)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24)
        }

        view.addSubview(searchBar)
        searchBar.placeholder = R.string.localizable.voteListSearch()
        searchBar.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(10)
            m.top.equalTo(titleLabel.snp.bottom).offset(14)
            m.right.equalToSuperview().offset(-10)
            m.height.equalTo(36+16)
        }

        view.addSubview(tableView)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 100
        tableView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.top.equalTo(searchBar.snp.bottom).offset(10)
        }
        tableView.register(CandidateCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()

        tableView.addSubview(emptyView)
        emptyView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(10)
            m.right.equalToSuperview().offset(-10)
            m.center.equalTo(tableView)
        }
        emptyView.isHidden = true
    }

    func bind() {
        searchBar.rx.text
            .bind(to: reactor.search)
            .disposed(by: rx.disposeBag)

        let result = reactor.result()

        self.view.displayLoading()
        result
            .filterNil()
            .map { $0.isEmpty }
            .filter { !$0 }
            .take(1)
            .bind { [weak self] _ in
                self?.view.hideLoading()
            }
            .disposed(by: rx.disposeBag)

        result
            .filterNil()
            .bind { [weak self] in
                let search = self?.searchBar.textField.text ?? ""
                if $0.isEmpty && !search.isEmpty {
                    self?.emptyView.isHidden = false
                } else {
                    self?.emptyView.isHidden = true
                }
            }
        .disposed(by: rx.disposeBag)

        typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Candidate>>
        let dataSource = DataSource(configureCell: { [weak self] (_, tableView, indexPath, candidate) -> UITableViewCell in
            let cell: CandidateCell = tableView.dequeueReusableCell(for: indexPath)
            cell.nodeNameLabel.text = candidate.name
            cell.voteCountLabel.text = candidate.voteNum.amountShort(decimals: TokenCacheService.instance.viteToken.decimals)
            cell.addressLabel.text = " " + candidate.nodeAddr.description
            cell.updateRank(candidate.rank)
            cell.disposeable?.dispose()
            cell.disposeable = cell.voteButton.rx.tap
                .bind {
                    self?.vote(nodeName: candidate.name)
                }
            cell.disposeable?.disposed(by: cell.rx.disposeBag)
            return cell
        })

        result
            .filterNil()
            .map { config -> [SectionModel<String, Candidate>] in
                return [SectionModel(model: "item", items: config)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        self.tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                if let item = (try? dataSource.model(at: indexPath)) as? Candidate {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    WebHandler.openSBPDetailPage(name: item.name)
                }
            }
            .disposed(by: rx.disposeBag)



        Observable.merge([
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification),
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            ])
            .filter { [weak self] _  in self?.appear ?? false }
            .subscribe(onNext: {[weak self] (notification) in
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
                let height =  min((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height, 128+55)
                UIView.animate(withDuration: duration, animations: {
                    if notification.name == UIResponder.keyboardWillShowNotification && self?.searchBar.textField.isFirstResponder ?? false {
                        self?.parent?.view.transform = CGAffineTransform(translationX: 0, y: -height)
                    } else if notification.name == UIResponder.keyboardWillHideNotification {
                        self?.parent?.view.transform = .identity
                    }
                })
            }).disposed(by: rx.disposeBag)

        self.reactor.fetchCandidateError.asObservable()
            .filterNil()
            .takeUntil(result)
            .bind { [weak self] e in
                self?.dataStatus = .networkError(e, { [weak self] in
                    self?.dataStatus = .normal
                    self?.reactor.fetchManually.onNext(Void())
                })
                self?.view.hideLoading()
            }.disposed(by: rx.disposeBag)

        self.reactor.fetchCandidateError.asObservable()
            .filter { $0 == nil }
            .skip(1)
            .bind { [weak self] _ in
                self?.view.hideLoading()
                self?.dataStatus = .normal
            }.disposed(by: rx.disposeBag)

    }

    func vote(nodeName: String) {
        if self.searchBar.textField.isFirstResponder {
            self.searchBar.textField.resignFirstResponder()
        }
        let (status, info) = self.reactor.lastVoteInfo.value
        let voted = status == .voteSuccess || status == .voting
        if voted {
            Alert.show(into: self,
                       title: R.string.localizable.vote(),
                       message: R.string.localizable.voteListAlertAlreadyVoted(info?.nodeName ?? ""),
                       actions: [
                        (.default(title:R.string.localizable.voteListConfirmRevote()), { [unowned self] _ in
                            self.vote(to: nodeName)
                        }),
                        (.cancel, { [unowned self] _ in
                            self.dismiss(animated: false, completion: nil)
                        })])
        } else {
            self.vote(to: nodeName)
        }
    }

    func vote(to nodeName: String) {
        self.reactor.vote(nodeName: nodeName)
    }

    var appear = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appear = false
    }

}

extension VoteListViewController: ViewControllerDataStatusable {

    func networkErrorView(error: Error, retry: @escaping () -> Void) -> UIView {
        return UIView.defaultNetworkErrorView(error: error) { [weak self] in
            self?.view.displayLoading()
            retry()
        }
    }

}
