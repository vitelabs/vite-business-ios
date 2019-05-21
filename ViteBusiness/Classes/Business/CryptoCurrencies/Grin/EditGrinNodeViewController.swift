//
//  EditGrinNodeViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/5/20.
//

import UIKit

class EditGrinNodeViewController: UIViewController {

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = R.string.localizable.grinNodeConfigNode()
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.textColor = UIColor.init(netHex: 0x3e4a59)
        return titleLabel
    }()

    let grinNodeTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = R.string.localizable.grinNodeEditNodeAddressTitle()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor.init(netHex: 0x3e4a59)
        return titleLabel
    }()

    let grinNodeTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        return textField
    }()

    let apiSecretTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = R.string.localizable.grinNodeEditApiSecretTitle()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor.init(netHex: 0x3e4a59)
        return titleLabel
    }()

    let apiSecretTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        return textField
    }()

    let deletButton = UIButton(style: .whiteWithShadow, title: R.string.localizable.delete())

    let confirmButton = UIButton(style: .blueWithShadow, title: R.string.localizable.confirm())

    var node: GrinNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let seperator0 = UIView()
        seperator0.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
        let seperator1 = UIView()
        seperator1.backgroundColor = UIColor.init(netHex: 0xD3DFEF)

        view.addSubview(titleLabel)
        view.addSubview(grinNodeTitleLabel)
        view.addSubview(grinNodeTextField)
        view.addSubview(apiSecretTitleLabel)
        view.addSubview(apiSecretTextField)
        view.addSubview(deletButton)
        view.addSubview(confirmButton)
        view.addSubview(seperator0)
        view.addSubview(seperator1)

        titleLabel.snp.makeConstraints { (m) in
            m.right.top.equalToSuperview()
            m.height.equalTo(28)
            m.left.equalToSuperview().offset(24)
        }

        grinNodeTitleLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview()
            m.top.equalTo(titleLabel.snp.bottom).offset(30)
            m.height.equalTo(18)
            m.left.equalToSuperview().offset(24)
        }

        grinNodeTextField.snp.makeConstraints { (m) in
            m.right.equalToSuperview()
            m.top.equalTo(grinNodeTitleLabel.snp.bottom).offset(30)
            m.height.equalTo(20)
            m.left.equalToSuperview().offset(24)
        }

        seperator0.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalTo(grinNodeTextField.snp.bottom).offset(10)
            m.height.equalTo(1)
            m.left.equalToSuperview().offset(24)
        }

        apiSecretTitleLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview()
            m.top.equalTo(grinNodeTextField.snp.bottom).offset(30)
            m.height.equalTo(18)
            m.left.equalToSuperview().offset(24)
        }

        apiSecretTextField.snp.makeConstraints { (m) in
            m.right.equalToSuperview()
            m.top.equalTo(apiSecretTitleLabel.snp.bottom).offset(30)
            m.height.equalTo(20)
            m.left.equalToSuperview().offset(24)
        }

        seperator1.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalTo(apiSecretTextField.snp.bottom).offset(10)
            m.height.equalTo(1)
            m.left.equalToSuperview().offset(24)
        }

        let buttonWidth = (kScreenW - 24*3) / 2

        deletButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
            m.width.equalTo(buttonWidth)
            m.height.equalTo(50)
            m.left.equalToSuperview().offset(24)
        }

        confirmButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
            m.width.equalTo(buttonWidth)
            m.height.equalTo(50)
            m.right.equalToSuperview().offset(-24)
        }

        apiSecretTextField.delegate = self
        grinNodeTextField.delegate = self

        deletButton.addTarget(self, action: #selector(delet), for: UIControl.Event.touchUpInside)
        confirmButton.addTarget(self, action: #selector(edit), for: UIControl.Event.touchUpInside)

        if let node =  self.node  {
            self.grinNodeTextField.text = node.address
            self.apiSecretTextField.text = node.apiSecret
        }
    }

    @objc func edit()  {
        guard let address = self.grinNodeTextField.text,
        let apiSecret = self.apiSecretTextField.text,
            !address.isEmpty && !apiSecret.isEmpty else {
                return
        }
        if let node = self.node  {
            node.address = address
            node.apiSecret = apiSecret
            GrinLocalInfoService.shared.update(node: node)
            if node.seleted {
                GrinManager.default.checkNodeApiHttpAddr = GrinManager.default.currentNode.address
                GrinManager.default.apiSecret = GrinManager.default.currentNode.apiSecret
                GrinManager.default.resetApiSecret()
            }
        } else {
            let node = GrinNode()
            node.address = address
            node.apiSecret = apiSecret
            GrinLocalInfoService.shared.add(node: node)
        }
        navigationController?.popViewController(animated: true)
    }

    @objc func delet() {
        if let node =  self.node  {
            GrinLocalInfoService.shared.remove(node: node)
            navigationController?.popViewController(animated: true)
        }
    }

}

extension EditGrinNodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()
        return true
    }
}
