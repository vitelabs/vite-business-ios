//
//  SelectGrinNodeViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/5/16.
//

import UIKit

class SelectGrinNodeViewController: UIViewController {

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = R.string.localizable.grinNodeConfigNode()
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.textColor = UIColor.init(netHex: 0x3e4a59)
        return titleLabel
    }()

    let tableView = UITableView()

    let addNodeButton: UIButton = UIButton(style: .add, title: R.string.localizable.contactsHomePageAddButtonTitle())

    var nodes:(viteNode: GrinNode, CustomNodes: [GrinNode])!

    var selectedIndexPath: IndexPath?

    func updateNodes()  {
        let viteNode = GrinManager.default.viteGrinNode
        let customnNodes = GrinLocalInfoService.shared.getNodeAddress()
        viteNode.seleted =  !customnNodes.contains(where: { (node) -> Bool in
            node.seleted == true
        })
        nodes = (viteNode,customnNodes)
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateNodes()
        setUpView()
        kas_activateAutoScrollingForView(view)
    }

    func setUpView()  {

        view.backgroundColor = .white

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(addNodeButton)

        titleLabel.snp.makeConstraints { (m) in
            m.right.top.equalToSuperview()
            m.height.equalTo(28)
            m.left.equalToSuperview().offset(24)
        }

        tableView.snp.makeConstraints { (m) in
            m.bottom.left.right.equalToSuperview()
            m.top.equalTo(titleLabel.snp.bottom)
        }

        tableView.delegate = self
        tableView.dataSource = self

        addNodeButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
            m.height.equalTo(50)
            m.centerX.equalToSuperview()
        }

        addNodeButton.rx.tap.bind {[weak self] _ in
            self?.gotoEditVC(node: nil)
            }.disposed(by: rx.disposeBag)

        tableView.tableFooterView = UIView()

    }

    func gotoEditVC(node: GrinNode?) {
        let vc = EditGrinNodeViewController()
        vc.node = node
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateNodes()
    }
    
}

extension SelectGrinNodeViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return nodes.1.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell =  SelectGrinNodeCell()
        var node: GrinNode!
        if indexPath.section == 0 {
            cell = ViteGrinNodeCell()
            node = nodes.0
        } else {
            node = nodes.1[indexPath.row]
            cell.editNodeAction = { [weak self] in
                self?.gotoEditVC(node: node)
            }
        }
        cell.addressLabel.text = node.address
        if node.seleted {
            cell.statusImageView.image = R.image.grin_node_selected()
            selectedIndexPath = indexPath
        } else {
            cell.statusImageView.image = R.image.grin_node_unselected()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            return
        }
        if indexPath.section == 0 {
            GrinLocalInfoService.shared.deSelect()
        } else {
            let node = nodes.1[indexPath.row]
            GrinLocalInfoService.shared.select(node: node)
        }
        GrinManager.default.checkNodeApiHttpAddr = GrinManager.default.currentNode.address
        GrinManager.default.apiSecret = GrinManager.default.currentNode.apiSecret
        GrinManager.default.resetApiSecret()
        updateNodes()

        var shouldAlet = true
        view.displayLoading()
        let result = GrinManager.default.txsGet(refreshFromNode: true)
        view.hideLoading()
        switch result {
        case .success((let refreshed, let txs)):
            if refreshed == true {
                shouldAlet = false
            }
        case .failure(let error):
            break
        }
        if shouldAlet {
            Alert.show(into: self, title: R.string.localizable.grinNoticeTitle(), message: R.string.localizable.grinNodeSelectCanNotConnect(), actions: [
                (.default(title: R.string.localizable.confirm()), nil)])
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}
