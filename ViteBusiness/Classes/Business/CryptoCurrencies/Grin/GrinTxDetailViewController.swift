//
//  GrinTxDetailViewController.swift
//  Pods
//
//  Created by haoshenyang on 2019/5/7.
//

import UIKit
import Vite_GrinWallet
import ViteWallet
import BigInt
import RxSwift
import RxCocoa

class GrinTxDetailViewController: UIViewController {

    let titleView = GrinTransactionTitleView()
    let txMethodLabel = UILabel()
    let pointView = UIView()
    let descLabel = UILabel()
    let amountInfoView = UIView()
    let infoview = EthSendPageTokenInfoView.init(address: "")
    let txInfoTableView = UITableView()
    var bottomView = UIView()
    lazy var button0 = UIButton()
    lazy var button1 = UIButton()

    let txDetailVM = GrinTxDetailVM()

    var fullInfo: GrinFullTxInfo? {
        didSet {
            guard let fullInfo = fullInfo else { return }
            self.txDetailVM.fullInfo = fullInfo
        }
    }

    var pageInfo: GrinDetailPageInfo {
        return self.txDetailVM.pageInfo.value
    }

    override func viewDidLoad() {
        setUpViews()
        self.bind()
    }

    func setUpViews()  {
        view.backgroundColor = .white

        view.addSubview(titleView)
        titleView.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
            m.height.equalTo(50)
        }
        titleView.tokenIconView.tokenInfo = GrinManager.tokenInfo
        titleView.tokenIconView.set(cornerRadius: 25)

        view.addSubview(txMethodLabel)
        txMethodLabel.snp.makeConstraints { (m) in
            m.top.equalTo(titleView.snp.bottom)
            m.left.equalToSuperview().offset(26)
        }
        txMethodLabel.backgroundColor = UIColor.init(netHex: 0xDFEEFF,alpha: 0.61)
        txMethodLabel.font = UIFont.systemFont(ofSize: 12)
        txMethodLabel.textColor = UIColor.init(netHex: 0x007aff)


        pointView.backgroundColor = UIColor.init(netHex: 0x007aff)
        view.addSubview(pointView)
        pointView.layer.cornerRadius = 3
        pointView.layer.masksToBounds = true
        pointView.snp.makeConstraints { (m) in
            m.width.height.equalTo(6)
            m.left.equalToSuperview().offset(26)
            m.top.equalTo(txMethodLabel.snp.bottom).offset(20)
        }

        view.addSubview(descLabel)
        descLabel.numberOfLines = 0
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.snp.makeConstraints { (m) in
            m.left.equalTo(pointView.snp.right).offset(5)
            m.top.equalTo(txMethodLabel.snp.bottom).offset(16)
            m.right.equalToSuperview().offset(-10)
        }

        view.addSubview(infoview)

        infoview.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.top.equalTo(descLabel.snp.bottom).offset(10)
        }

        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.height.equalTo(50)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }

        view.addSubview(txInfoTableView)
        txInfoTableView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalTo(bottomView.snp.top)
            m.top.equalTo(infoview.snp.bottom).offset(5)
        }

        txInfoTableView.delegate = self
        txInfoTableView.dataSource = self
        txInfoTableView.separatorStyle = .none

        txInfoTableView.register(GrinTxInfoTitleCell.self, forCellReuseIdentifier: "GrinTxInfoTitleCell")
        txInfoTableView.register(GrinTxInfoCell.self, forCellReuseIdentifier: "GrinTxInfoCell")
    }

    func bindDetailPageInfo(_ pageInfo: GrinDetailPageInfo) {
        titleView.symbolLabel.text = pageInfo.title
        txMethodLabel.text = pageInfo.methodString
        if let desc = pageInfo.desc, desc.count > 0 {
            descLabel.text = pageInfo.desc
            pointView.isHidden = false
        } else {
            pointView.isHidden = true
        }

        if let amount = pageInfo.amount {
            if let fee = pageInfo.fee {
                infoview.addressTitleLabel.text = R.string.localizable.grinSentAmount()
                infoview.addressLabel.text = pageInfo.amount
                infoview.balanceTitleLabel.text = R.string.localizable.grinSentFee()
                infoview.balanceLabel.text = pageInfo.fee
            } else {
                infoview.addressTitleLabel.text = R.string.localizable.grinSentFee()
                infoview.addressLabel.text = pageInfo.amount
                infoview.balanceTitleLabel.text = nil
                infoview.balanceLabel.text = nil
            }
        }

        txInfoTableView.reloadData()

        if pageInfo.actions.count == 0 {
            self.bottomView.isHidden = true
        } else {
            self.bottomView.isHidden = false
            if pageInfo.actions.count == 1 {
                button0.layer.cornerRadius = 2
                button0.backgroundColor = UIColor.init(netHex: 0x007aff)
                if button0.superview == nil {
                    bottomView.addSubview(button0)
                    button0.snp.makeConstraints { (m) in
                        m.left.equalToSuperview().offset(24)
                        m.right.equalToSuperview().offset(-24)
                        m.height.equalTo(50)
                        m.bottom.equalTo(bottomView.safeAreaLayoutGuideSnpBottom)
                    }
                } else {
                    button0.snp.remakeConstraints { (m) in
                        m.left.equalToSuperview().offset(24)
                        m.right.equalToSuperview().offset(-24)
                        m.height.equalTo(50)
                        m.bottom.equalTo(bottomView.safeAreaLayoutGuideSnpBottom)
                    }
                }
                button0.setTitle(pageInfo.actions.first?.0, for: .normal)
                bottomView.addSubview(button0)
                button0.rx.tap.bind {[weak self] _ in
                    self?.pageInfo.actions.first?.1()
                }.disposed(by:rx.disposeBag)
            } else if pageInfo.actions.count == 2 {
                if button0.superview == nil {
                    bottomView.addSubview(button0)
                    button0.snp.makeConstraints { (m) in
                        m.left.equalToSuperview().offset(24)
                        m.width.equalTo(kScreenW/2-36)
                        m.height.equalTo(50)
                        m.bottom.equalTo(bottomView.safeAreaLayoutGuideSnpBottom)
                    }
                } else {
                    button0.snp.remakeConstraints { (m) in
                        m.left.equalToSuperview().offset(24)
                        m.width.equalTo(kScreenW/2-36)
                        m.height.equalTo(50)
                        m.bottom.equalTo(bottomView.safeAreaLayoutGuideSnpBottom)
                    }
                }
                button0.layer.cornerRadius = 2
                button0.backgroundColor = UIColor.init(netHex: 0x007aff)
                button0.setTitle(pageInfo.actions.first?.0, for: .normal)
                bottomView.addSubview(button0)

                button0.rx.tap.bind {[weak self] _ in
                    self?.pageInfo.actions.first?.1()
                }.disposed(by:rx.disposeBag)

                button1.backgroundColor = UIColor.init(netHex: 0x007aff)
                button1.layer.cornerRadius = 2
                button1.setTitle(pageInfo.actions.last?.0, for: .normal)
                if button1.superview == nil {
                    bottomView.addSubview(button1)
                    button1.snp.makeConstraints { (m) in
                        m.right.equalToSuperview().offset(-24)
                        m.width.equalTo(kScreenW/2-36)
                        m.height.equalTo(50)
                        m.bottom.equalTo(bottomView.safeAreaLayoutGuideSnpBottom)
                    }
                } else {
                    button1.snp.remakeConstraints { (m) in
                        m.right.equalToSuperview().offset(-24)
                        m.width.equalTo(kScreenW/2-36)
                        m.height.equalTo(50)
                        m.bottom.equalTo(bottomView.safeAreaLayoutGuideSnpBottom)
                    }
                }
                button1.rx.tap.bind {[weak self] _ in
                    self?.pageInfo.actions.last?.1()
                }.disposed(by:rx.disposeBag)
            } else {
                fatalError()
            }
        }
    }

    func bind() {
        self.txDetailVM.pageInfo.asObservable()
            .bind { [weak self] pageInfo in
                self?.bindDetailPageInfo(pageInfo)
            }
            .disposed(by: rx.disposeBag)

        let transferVM = self.txDetailVM.txVM
        transferVM.receiveSlateCreated.asObserver()
            .bind { [weak self] (slate,url) in

            }
            .disposed(by: rx.disposeBag)

        transferVM.message.asObservable()
            .bind { message in
                Toast.show(message)
            }
            .disposed(by: rx.disposeBag)

        transferVM.finalizeTxSuccess.asObserver()
            .delay(1.5, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                
            }
            .disposed(by: rx.disposeBag)
    }

}


extension GrinTxDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pageInfo.cellInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = self.pageInfo.cellInfo[indexPath.row]
        if cellInfo.isTitle {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GrinTxInfoTitleCell") as! GrinTxInfoTitleCell
            cell.statusImageView.image = cellInfo.statusImage
            cell.lineImageView.image = cellInfo.lineImage
            if let slateId = cellInfo.slateId {
                cell.slateContainerView.isHidden = false
                cell.slateLabel.text = "Slate ID：\(slateId)"
            } else {
                cell.slateContainerView.isHidden = true
            }
            cell.statusLabel.attributedText = cellInfo.statusAttributeStr
            cell.copyAction = {
                UIPasteboard.general.string = cellInfo.slateId
                Toast.show("已复制Slate ID")
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GrinTxInfoCell") as! GrinTxInfoCell
            cell.statusImageView.image = cellInfo.statusImage
            cell.lineImageView.image = cellInfo.lineImage
            cell.timeLabel.text = cellInfo.timeStr
            cell.statusLabel.attributedText = cellInfo.statusAttributeStr
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

}


