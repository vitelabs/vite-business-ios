//
//  SpotHistorySelectPairViewController.swift
//  ViteBusiness
//
//  Created by stone on 2021/9/24.
//

import UIKit
import RxSwift
import RxCocoa

class SpotHistorySelectPairViewController: BaseTableViewController {
    
    let selectedPair: (Pair) -> Void
    init(selectedPair: @escaping (Pair) -> Void) {
        self.selectedPair = selectedPair
        super.init(.plain)
    }
    
    let allBTC = MarketInfoService.shared.sortedMarketDataBehaviorRelay.value[1].infos.map { Pair(symbol: $0.statistic.symbol, tradeTokenSymbol: $0.statistic.tradeTokenSymbol, quoteTokenSymbol: $0.statistic.quoteTokenSymbol)}
    let allETH = MarketInfoService.shared.sortedMarketDataBehaviorRelay.value[2].infos.map { Pair(symbol: $0.statistic.symbol, tradeTokenSymbol: $0.statistic.tradeTokenSymbol, quoteTokenSymbol: $0.statistic.quoteTokenSymbol)}
    let allVITE = MarketInfoService.shared.sortedMarketDataBehaviorRelay.value[3].infos.map { Pair(symbol: $0.statistic.symbol, tradeTokenSymbol: $0.statistic.tradeTokenSymbol, quoteTokenSymbol: $0.statistic.quoteTokenSymbol)}
    let allUSDT = MarketInfoService.shared.sortedMarketDataBehaviorRelay.value[4].infos.map { Pair(symbol: $0.statistic.symbol, tradeTokenSymbol: $0.statistic.tradeTokenSymbol, quoteTokenSymbol: $0.statistic.quoteTokenSymbol)}
    
    var items: [Pair] = []
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        updateItems()
    }
    
    func updateItems() {
        var ret: [Pair] = []
        if let q = quoteTokenSymbol {
            if q == "BTC-000" {
                ret.append(contentsOf: allBTC)
            } else if q == "ETH-000" {
                ret.append(contentsOf: allETH)
            } else if q == "USDT-000" {
                ret.append(contentsOf: allUSDT)
            } else if q == "VITE" {
                ret.append(contentsOf: allVITE)
            }
        } else {
            ret.append(Pair(symbol: "", tradeTokenSymbol: nil, quoteTokenSymbol: nil))
            ret.append(contentsOf: allBTC)
            ret.append(contentsOf: allETH)
            ret.append(contentsOf: allVITE)
            ret.append(contentsOf: allUSDT)
        }
        
        let text = navView.textField.text ?? ""
        
        if text.count > 0 {
            items = ret.filter { $0.symbol.lowercased().contains(text) }
        } else {
            items = ret
        }
        
        tableView.reloadData()
    }

    let navView = ViteXTokenSelectorViewController.NavView()
    lazy var segmentView = SegmentView() { [weak self] in
        self?.quoteTokenSymbol = $0
        self?.updateItems()
    }
    var quoteTokenSymbol: String? = nil
    
    func setupView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(navView)
        view.addSubview(segmentView)
        navView.snp.makeConstraints { m in
            m.top.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(56)
        }
        
        segmentView.snp.makeConstraints { m in
            m.left.right.equalToSuperview()
            m.top.equalTo(navView.snp.bottom)
        }
        
        tableView.snp.remakeConstraints { m in
            m.top.equalTo(segmentView.snp.bottom)
            m.left.right.bottom.equalToSuperview()
        }
        
        
    }
    
    func bind() {
        
        navView.cancelButton.rx.tap.bind { [weak self] in
            self?.dismiss()
        }.disposed(by: rx.disposeBag)

        navView.textField.rx.text.bind { [weak self] _ in
            self?.updateItems()
        }.disposed(by: rx.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Cell.cellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(pair: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedPair(items[indexPath.row])
        self.dismiss()
    }
}

extension SpotHistorySelectPairViewController {
    
    struct Pair {
        let symbol: String
        let tradeTokenSymbol: String?
        let quoteTokenSymbol: String?
    }
    
    class SegmentView: UIView {
        
        let btcButton = SegmentView.makeButton(title: "BTC-000")
        let ethButton = SegmentView.makeButton(title: "ETH-000")
        let usdtButton = SegmentView.makeButton(title: "USDT-000")
        let viteButton = SegmentView.makeButton(title: "VITE")
        
        init(selected: @escaping (String) -> Void) {
            super.init(frame: .zero)

            addSubview(btcButton)
            addSubview(ethButton)
            addSubview(usdtButton)
            addSubview(viteButton)

            btcButton.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(11)
                m.bottom.equalToSuperview()
                m.left.equalToSuperview().offset(24)
                m.size.equalTo(CGSize(width: 71, height: 26))
            }
            
            ethButton.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(11)
                m.bottom.equalToSuperview()
                m.left.equalTo(btcButton.snp.right).offset(12)
                m.size.equalTo(btcButton)
            }
            
            usdtButton.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(11)
                m.bottom.equalToSuperview()
                m.left.equalTo(ethButton.snp.right).offset(12)
                m.size.equalTo(btcButton)
            }
            
            viteButton.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(11)
                m.bottom.equalToSuperview()
                m.left.equalTo(usdtButton.snp.right).offset(12)
                m.size.equalTo(btcButton)
            }

            btcButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                selected("BTC-000")
                self.btcButton.isEnabled = false
                self.ethButton.isEnabled = true
                self.usdtButton.isEnabled = true
                self.viteButton.isEnabled = true
            }.disposed(by: rx.disposeBag)
            
            ethButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                selected("ETH-000")
                self.btcButton.isEnabled = true
                self.ethButton.isEnabled = false
                self.usdtButton.isEnabled = true
                self.viteButton.isEnabled = true
            }.disposed(by: rx.disposeBag)
            
            usdtButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                selected("USDT-000")
                self.btcButton.isEnabled = true
                self.ethButton.isEnabled = true
                self.usdtButton.isEnabled = false
                self.viteButton.isEnabled = true
            }.disposed(by: rx.disposeBag)
            
            viteButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                selected("VITE")
                self.btcButton.isEnabled = true
                self.ethButton.isEnabled = true
                self.usdtButton.isEnabled = true
                self.viteButton.isEnabled = false
            }.disposed(by: rx.disposeBag)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        static func makeButton(title: String) -> UIButton {
            let button =  UIButton()
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            
            button.setBackgroundImage(R.image.background_button_blue()?.resizable, for: .disabled)
            button.setTitleColor(.white, for: .disabled)
                
            button.setBackgroundImage(R.image.background_button_gray()?.resizable, for: .normal)
            button.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            
            button.setBackgroundImage(R.image.background_button_blue()?.resizable, for: .highlighted)
            button.setTitleColor(.white, for: .highlighted)
            return button
        }
    }
    
    class Cell: BaseTableViewCell {

        static let cellHeight: CGFloat = 50

        let tradeLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(netHex: 0x24272B)
        }

        let quoteLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            contentView.addSubview(tradeLabel)
            contentView.addSubview(quoteLabel)

            let hLine = UIView().then {
                $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
            }

            contentView.addSubview(hLine)


            tradeLabel.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.left.equalToSuperview().offset(24)
            }

            quoteLabel.snp.makeConstraints { (m) in
                m.bottom.equalTo(tradeLabel)
                m.left.equalTo(tradeLabel.snp.right).offset(2)
            }

            hLine.snp.makeConstraints { (m) in
                m.height.equalTo(CGFloat.singleLineWidth)
                m.bottom.equalToSuperview()
                m.left.right.equalToSuperview().inset(24)
            }

        }
        
        func bind(pair: Pair) {
            if let t = pair.tradeTokenSymbol, let q = pair.quoteTokenSymbol {
                tradeLabel.text = t
                quoteLabel.text = "/" + q
            } else {
                tradeLabel.text = R.string.localizable.spotHistoryPageFilterAll()
                quoteLabel.text = ""
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }
}
