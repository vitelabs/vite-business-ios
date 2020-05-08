//
//  TokenInfoDetailViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/5/8.
//

import Foundation

class TokenInfoDetailViewController: BaseTableViewController {

    let tokenInfo: TokenInfo
    init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        super.init(.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    var cells: [BaseTableViewCell] = []

    var tokenInfoDetail: TokenInfoDetail? = nil {
        didSet {

            cells = []
            if let detail = tokenInfoDetail {
                cells.append({
                    let cell = InfoTitleValueCell()
                    let text = "\(detail.name) (\(detail.uniqueSymbol))"
                    var u = "https://explorer.vite.net"
                    if LocalizationService.sharedInstance.currentLanguage == .chinese {
                        u.append("/zh")
                    }
                    u.append("/token/\(detail.id)")
                    let url = URL(string: u)
                    cell.setTitle(R.string.localizable.tokenInfoDetailPageName(), text: text, url: url)
                    return cell
                }())

                cells.append({
                    let cell = InfoTitleValueCell()
                    let text = detail.id
                    var u = "https://explorer.vite.net"
                    if LocalizationService.sharedInstance.currentLanguage == .chinese {
                        u.append("/zh")
                    }
                    u.append("/token/\(detail.id)")
                    let url = URL(string: u)
                    cell.setTitle(R.string.localizable.tokenInfoDetailPageId(), text: text, url: url)
                    return cell
                }())

                cells.append({
                    let cell = InfoTitleValueCell()
                    let text = detail.overviewString
                    cell.setTitle(R.string.localizable.tokenInfoDetailPageBrief(), text: text)
                    return cell
                }())

                cells.append({
                    let cell = InfoTitleValueCell()
                    let text = detail.total
                    cell.setTitle(R.string.localizable.tokenInfoDetailPageTotal(), text: text)
                    return cell
                }())

                cells.append({
                    let cell = InfoTitleValueCell()
                    let text = detail.gatewayInfo == nil ? R.string.localizable.tokenInfoDetailPageTypeValueNative() : R.string.localizable.tokenInfoDetailPageTypeValueOther()
                    cell.setTitle(R.string.localizable.tokenInfoDetailPageType(), text: text)
                    return cell
                }())

                cells.append({
                    let cell = InfoTitleValueCell()
                    let gatewayName = detail.gatewayInfo?.name ?? "--"
                    let gatewayUrlString = detail.gatewayInfo?.website
                    let gatewayUrl = gatewayUrlString.map { URL(string: $0)! }
                    cell.setTitle(R.string.localizable.tokenInfoDetailPageGateway(), text: gatewayName, url: gatewayUrl)
                    return cell
                }())

                cells.append({
                    let cell = InfoTitleValueCell()
                    let text = detail.website
                    let url = URL(string: text)
                    cell.setTitle(R.string.localizable.tokenInfoDetailPageWebside(), text: text, url: url)
                    return cell
                }())

                cells.append({
                    let cell = InfoTitleValueCell()
                    let text = detail.whitepaper
                    let url = URL(string: text)
                    cell.setTitle(R.string.localizable.tokenInfoDetailPagePaper(), text: text, url: url)
                    return cell
                }())

                if !detail.links.explorer.isEmpty {
                    cells.append(contentsOf: detail.links.explorer.map {
                        let cell = InfoTitleValueCell()
                        let text = $0
                        let url = URL(string: text)
                        cell.setTitle(R.string.localizable.tokenInfoDetailPageBrowser(), text: text, url: url)
                        return cell
                    })
                }

                cells.append({
                    let cell = InfoTitleValueCell()
                    let text = detail.links.github.first
                    let url = text == nil ? nil : URL(string: text!)
                    cell.setTitle(R.string.localizable.marketDetailPageTokenInfoGithub(), text: text ?? "--", url: url)
                    return cell
                }())

                cells.append({
                    let cell = SocialCell()
                    cell.titleLabel.text = R.string.localizable.marketDetailPageTokenInfoSocial()
                    var values: [(image: UIImage?, url: URL)] = []
                    if let urlString = detail.links.twitter.first, let url = URL(string: urlString) {
                        let image = R.image.icon_market_detail_twitter()
                        values.append((image: image, url: url))
                    }

                    if let urlString = detail.links.facebook.first, let url = URL(string: urlString) {
                        let image = R.image.icon_market_detail_facebook()
                        values.append((image: image, url: url))
                    }

                    if let urlString = detail.links.telegram.first, let url = URL(string: urlString) {
                        let image = R.image.icon_market_detail_telegram()
                        values.append((image: image, url: url))
                    }

                    if let urlString = detail.links.reddit.first, let url = URL(string: urlString) {
                        let image = R.image.icon_market_detail_reddit()
                        values.append((image: image, url: url))
                    }

                    if let urlString = detail.links.discord.first, let url = URL(string: urlString) {
                        let image = R.image.icon_market_detail_discord()
                        values.append((image: image, url: url))
                    }
                    cell.set(values)
                    return cell
                }())
            }
            self.tableView.reloadData()
        }
    }

    func setupView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension

        let nav = NavigationTitleView(title: R.string.localizable.tokenInfoDetailPageTitle())
        let tokenIconView = TokenIconView()
        nav.addSubview(tokenIconView)
        tokenIconView.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalTo(nav.titleLabel)
            m.size.equalTo(CGSize(width: 50, height: 50))
        }
        tokenIconView.tokenInfo = tokenInfo
        navigationTitleView = nav

        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }

        fetch()
    }

    func fetch() {
        self.dataStatus = .loading
        UnifyProvider.vitex.getTokenInfoDetail(tokenCode: tokenInfo.tokenCode).done { [weak self] (tokenInfoDetail) in
            guard let `self` = self else { return }
            self.tokenInfoDetail = tokenInfoDetail
            self.dataStatus = .normal
        }.catch { [weak self] (error) in
            self?.dataStatus = .networkError(error, { [weak self] in
                self?.fetch()
            })
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
}

extension TokenInfoDetailViewController: ViewControllerDataStatusable {
    func networkErrorView(error: Error, retry: @escaping () -> Void) -> UIView {
        return UIView.defaultNetworkErrorView(error: error, retry: retry)
    }
}
