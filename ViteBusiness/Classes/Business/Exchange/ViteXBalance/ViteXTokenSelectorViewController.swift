//
//  ViteXTokenSelectorViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/7/29.
//

import Foundation
import ViteWallet

class ViteXTokenSelectorViewController: BaseTableViewController, ViewControllerDataStatusable {

    enum PType {
        case wallet
        case vitex
    }

    var tokenInfo: TokenInfo
    let type: PType
    let block: (TokenInfo) -> Void
    var vms: [ViteXTokenSelectorViewModel] = []

    init(tokenInfo: TokenInfo, type: PType, block: @escaping (TokenInfo) -> Void) {
        self.tokenInfo = tokenInfo
        self.type = type
        self.block = block
        super.init(.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    let navView = NavView()

    func setupUI() {
        view.addSubview(navView)

        navView.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(56)
        }

        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom)
            m.left.right.bottom.equalTo(view)
        }


        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
    }

    func bind() {
        navView.cancelButton.rx.tap.bind {
            UIViewController.current?.navigationController?.popViewController(animated: true)
        }.disposed(by: rx.disposeBag)

        navView.textField.rx.text.bind { [weak self] _ in
            self?.update()
        }.disposed(by: rx.disposeBag)
    }

    func update() {
        var valuable: [ViteXTokenSelectorViewModel] = []
        var unvaluable: [ViteXTokenSelectorViewModel] = []
        var mine: [ViteXTokenSelectorViewModel] = []

        let dexTokenInfos = TokenInfoCacheService.instance.dexTokenInfos
        for tokenInfo in dexTokenInfos {

            let amount: Amount
            switch self.type {
            case .wallet:
                amount = ViteBalanceInfoManager.instance.balanceInfo(forViteTokenId: tokenInfo.viteTokenId)?.balance ?? Amount(0)
            case .vitex:
                amount = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: tokenInfo.viteTokenId)?.available ?? Amount(0)
            }
            let vm = ViteXTokenSelectorViewModel(tokenInfo: tokenInfo, balanceString: amount.amountShortWithGroupSeparator(decimals: tokenInfo.decimals))
            if amount > 0 {
                valuable.append(vm)
            } else {
                unvaluable.append(vm)
            }
        }

        let set = Set(dexTokenInfos.map { $0.tokenCode })
        let mineTokenInfos = MyTokenInfosService.instance.tokenInfos.filter { $0.coinType == .vite }

        for tokenInfo in mineTokenInfos where set.contains(tokenInfo.tokenCode) == false {
            let amount: Amount
            switch self.type {
            case .wallet:
                amount = ViteBalanceInfoManager.instance.balanceInfo(forViteTokenId: tokenInfo.viteTokenId)?.balance ?? Amount(0)
            case .vitex:
                amount = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: tokenInfo.viteTokenId)?.available ?? Amount(0)
            }
            let vm = ViteXTokenSelectorViewModel(tokenInfo: tokenInfo, balanceString: amount.amountShortWithGroupSeparator(decimals: tokenInfo.decimals))
            mine.append(vm)
        }

        let all = valuable.sorted { $0.tokenInfo.uniqueSymbol < $1.tokenInfo.uniqueSymbol } +
            unvaluable.sorted { $0.tokenInfo.uniqueSymbol < $1.tokenInfo.uniqueSymbol } +
            mine.sorted { $0.tokenInfo.uniqueSymbol < $1.tokenInfo.uniqueSymbol }

        if let key = self.navView.textField.text?.lowercased(), key.isNotEmpty {
            vms = all.filter { $0.tokenInfo.uniqueSymbol.lowercased().contains(key) }
        } else {
            vms = all
        }

        tableView.reloadData()

        self.dataStatus = vms.isEmpty ? .empty : .normal
    }
}

extension ViteXTokenSelectorViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vms.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ViteXTokenSelectorCell.cellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ViteXTokenSelectorCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(vm: vms[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let model = vms[indexPath.row]
        block(model.tokenInfo)
        dismiss()
    }

    func emptyView() -> UIView {
        return UIView.defaultPlaceholderView(text: R.string.localizable.transactionListPageEmpty())
    }
}

extension ViteXTokenSelectorViewController {
    class NavView: UIView {
        let searchImageView = UIImageView(image: R.image.icon_nav_search())
        let textField = UITextField().then {
            $0.textColor = UIColor(netHex: 0x24272B)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.placeholder = R.string.localizable.transferSearchPlaceholder()
            $0.clearButtonMode = .whileEditing
        }
        let cancelButton = UIButton().then {
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.setTitle(R.string.localizable.cancel(), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.45), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.45).highlighted, for: .highlighted)
            $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 24)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(searchImageView)
            addSubview(textField)
            addSubview(cancelButton)

            searchImageView.snp.makeConstraints { (m) in
                m.left.equalToSuperview().offset(24)
                m.bottom.equalToSuperview().offset(-16)
                m.size.equalTo(CGSize(width: 14, height: 14))
            }

            textField.snp.makeConstraints { (m) in
                m.left.equalTo(searchImageView.snp.right).offset(8)
                m.centerY.equalTo(searchImageView)
            }

            cancelButton.snp.makeConstraints { (m) in
                m.left.equalTo(textField.snp.right).offset(8)
                m.right.equalToSuperview()
                m.centerY.equalTo(searchImageView)
            }


            let separatorLine = UIView().then {
                $0.backgroundColor = Colors.lineGray
            }
            addSubview(separatorLine)
            separatorLine.snp.makeConstraints { (m) in
                m.height.equalTo(CGFloat.singleLineWidth)
                m.bottom.left.right.equalTo(self)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
