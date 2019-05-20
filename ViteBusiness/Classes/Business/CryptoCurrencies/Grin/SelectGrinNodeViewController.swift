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
        titleLabel.text = "配置全节点"
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.textColor = UIColor.init(netHex: 0x3e4a59)
        return titleLabel
    }()

    let nodes = GrinLocalInfoService.shared.getNodeAddress()

    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        let node = GrinNode()
        node.address = "https://grin.vite.net/fullnode"
        node.apiSecret = "Pbwnf9nJDEVcVPR8B42u"
        GrinLocalInfoService.shared.add(node: node)
        // Do any additional setup after loading the view.
    }

    func setUpView()  {

        view.backgroundColor = .white

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (m) in
            m.right.top.equalToSuperview()
            m.height.equalTo(28)
            m.left.equalToSuperview().offset(24)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.bottom.left.right.equalToSuperview()
            m.top.equalTo(titleLabel.snp.bottom)
        }

        tableView.delegate = self
        tableView.dataSource = self
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
            return nodes.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell =  SelectGrinNodeCell()
        var node: GrinNode!
        if indexPath.section == 0 {
            cell = ViteGrinNodeCell()
            node = GrinManager.default.viteGrinNode
        } else {
            node = nodes[indexPath.row]
        }
        cell.addressLabel.text = node.address
        if node.seleted {
            cell.statusImageView.image = R.image.grin_node_selected()
        } else {
            cell.statusImageView.image = R.image.grin_node_unselected()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            GrinLocalInfoService.shared.deSelect()
        } else {
            let node = nodes[indexPath.row]
            GrinLocalInfoService.shared.select(node: node)
        }
        GrinManager.default.checkNodeApiHttpAddr = GrinManager.default.currentNode.address
        GrinManager.default.apiSecret = GrinManager.default.currentNode.apiSecret
        GrinManager.default.resetApiSecret()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }


}
