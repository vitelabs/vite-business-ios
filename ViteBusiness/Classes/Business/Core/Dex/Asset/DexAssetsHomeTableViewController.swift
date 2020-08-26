//
//  DexAssetsHomeTableViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/26.
//

import Foundation

class DexAssetsHomeTableViewController: BaseTableViewController {

    lazy var headerCell = DexAssetsHomeHeaderViewCell(type: self.type)

    let type: DexAssetsHomeViewController.PType
    init(type: DexAssetsHomeViewController.PType) {
        self.type = type
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        tableView.backgroundColor = .white
        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(view).offset(38)
            m.left.right.bottom.equalToSuperview()
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        bind()
    }

    func bind() {
        HDWalletManager.instance.accountDriver.filterNil().map { $0.address }.drive(headerCell.addressButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)

        headerCell.addressButton.rx.tap.bind {
            let vc = MyAddressManageViewController(tableViewModel: MyViteAddressManagerTableViewModel())
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        headerCell.transferButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let vc = ViteXTokenSelectorViewController(type: .wallet, filter: .none) { (tokenInfo, vc) in
                let transferVC = ManageViteXBanlaceViewController(tokenInfo: tokenInfo)
                UIViewController.current?.navigationController?.pushViewController(transferVC, animated: true)
                GCD.delay(0.3) {
                    var vcs = vc.navigationController!.viewControllers
                    vcs.remove(at: vcs.count - 2)
                    vc.navigationController!.setViewControllers(vcs, animated: false)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        headerCell.depositButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let vc = ViteXTokenSelectorViewController(type: .vitex, filter: .gateway) { (tokenInfo, vc) in
                let ccVC = CrossChainStatementViewController(tokenInfo: tokenInfo)
                ccVC.isWithDraw = false
                UIViewController.current?.navigationController?.pushViewController(ccVC, animated: true)
                GCD.delay(0.3) {
                    var vcs = vc.navigationController!.viewControllers
                    vcs.remove(at: vcs.count - 2)
                    vc.navigationController!.setViewControllers(vcs, animated: false)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        headerCell.withdrawButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let vc = ViteXTokenSelectorViewController(type: .vitex, filter: .gateway) { (tokenInfo, vc) in
                let ccVC = CrossChainStatementViewController(tokenInfo: tokenInfo)
                ccVC.isWithDraw = true
                UIViewController.current?.navigationController?.pushViewController(ccVC, animated: true)
                GCD.delay(0.3) {
                    var vcs = vc.navigationController!.viewControllers
                    vcs.remove(at: vcs.count - 2)
                    vc.navigationController!.setViewControllers(vcs, animated: false)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)
    }
}

extension DexAssetsHomeTableViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 10
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return headerCell
        } else {
            let cell: DexAssetsHomeCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 199 : 66
    }
}
