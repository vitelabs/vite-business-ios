//
//  SpotViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit
import RxSwift
import RxCocoa

class SpotViewController: BaseTableViewController {

    let marketInfoBehaviorRelay: BehaviorRelay<MarketInfo?> = BehaviorRelay(value: nil)
    var viewModle: SpotOpenedOrderListViewModel?
    
    init(symbol: String) {
        if let marketInfo = MarketInfoService.shared.marketInfo(symbol: symbol) {
            self.marketInfoBehaviorRelay.accept(marketInfo)
        }
        super.init(.plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()

    }

    func setupView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = makeHeaderView()
        bubbleView.isHidden = true
    }

    func update(marketInfo: MarketInfo, isBuy: Bool) {
        self.marketInfoBehaviorRelay.accept(marketInfo)
        self.operationView.segmentView.isBuyBehaviorRelay.accept(isBuy)
    }

    func bind() {

        NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification).bind { [weak self] _ in
            guard let `self` = self else { return }
            self.bubbleView.isHidden = ((!self.operationView.priceTextField.textField.isFirstResponder) || self.bubbleView.textLabel.text == nil)
        }.disposed(by: rx.disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardDidHideNotification).bind { [weak self] _ in
            guard let `self` = self else { return }
            self.bubbleView.isHidden = true
        }.disposed(by: rx.disposeBag)

        navView.switchPair = { [weak self] in
            self?.marketInfoBehaviorRelay.accept($0)
        }

        depthView.priceClicked = { [weak self] ret in
            guard let `self` = self else { return }

            var num: Double? = nil
            if self.operationView.segmentView.isBuyBehaviorRelay.value != ret.isBuy {
                if let n = ret.vol {
                    num = n
                }
            }

            if let _ = num {
                self.operationView.setVol("")
            }

            self.operationView.setPrice(ret.price)

            if let num = num {
                self.operationView.setVol(num)
            }
        }

        ordersHeaderView.historyButton.rx.tap.bind {
            WebHandler.openMarketHistoryOrders()
        }.disposed(by: rx.disposeBag)

        MarketInfoService.shared.sortedMarketDataBehaviorRelay.bind { [weak self] array in
            guard let `self` = self else { return }
            let infos = array.flatMap { $0.infos }
            for info in infos where info.statistic.symbol == self.marketInfoBehaviorRelay.value?.statistic.symbol {
                self.marketInfoBehaviorRelay.accept(info)
                break
            }
        }.disposed(by: rx.disposeBag)

        self.marketInfoBehaviorRelay.bind { [weak self] in
            guard let `self` = self else { return }
            self.navView.bind(marketInfo: $0)
            self.depthView.bind(marketInfo: $0)
        }.disposed(by: rx.disposeBag)

        Driver.combineLatest(
            HDWalletManager.instance.accountDriver,
            self.marketInfoBehaviorRelay.asDriver().distinctUntilChanged { (left, right) -> Bool in
                left?.statistic.symbol == right?.statistic.symbol
        }).drive(onNext: { [weak self] (account, info) in
            guard let `self` = self else { return }
            guard let info = info else { return }
            self.operationView.bind(marketInfo: info)

            if let address = account?.address {
                let viewModle = SpotOpenedOrderListViewModel(tableView: self.tableView, marketInfo: info, address: address)
                viewModle.spotViewModelBehaviorRelay.bind { [weak self] in
                    guard let `self` = self else { return }
                    self.navView.setOpertionIcon($0?.operatorInfoIconUrlString)
                    self.operationView.bind(spotViewModel: $0)
                }.disposed(by: viewModle.rx.disposeBag)

                Driver.combineLatest(
                    self.operationView.segmentView.isBuyBehaviorRelay.asDriver(),
                    viewModle.depthListBehaviorRelay.asDriver()).drive(onNext: { [weak self] (isBuy, depthList) in
                        guard let `self` = self else { return }
                        if isBuy {
                            if let peerPriceString = depthList?.asks.first?.price,
                                let peerPrice = Double(peerPriceString),
                                let max = info.buyRangeMax {
                                var price = peerPrice - max * peerPrice
                                price = price - (0.51 / pow(10, Double(info.statistic.pricePrecision)))
                                let text = String(format: "%0.\(info.statistic.pricePrecision)f", price)
                                self.bubbleView.textLabel.text = R.string.localizable.spotPageBuyMiningTip(text)
                            } else {
                                self.bubbleView.textLabel.text = nil
                            }
                        } else {
                            if let peerPriceString = depthList?.bids.first?.price,
                                let peerPrice = Double(peerPriceString),
                                let max = info.sellRangeMax {
                                var price = peerPrice + max * peerPrice
                                price = price + (0.51 / pow(10, Double(info.statistic.pricePrecision)))
                                let text = String(format: "%0.\(info.statistic.pricePrecision)f", price)
                                self.bubbleView.textLabel.text = R.string.localizable.spotPageSellMiningTip((text))
                            } else {
                                self.bubbleView.textLabel.text = nil
                            }
                        }
                    }).disposed(by: viewModle.rx.disposeBag)
                Driver.combineLatest(
                    viewModle.depthListBehaviorRelay.asDriver(),
                    viewModle.orderListBehaviorRelay.asDriver()).drive(onNext: { [weak self] in
                        guard let `self` = self else { return }
                        self.depthView.bind(depthList: $0, myOrders: $1)
                }).disposed(by: viewModle.rx.disposeBag)

                self.viewModle = viewModle
            } else {
                self.viewModle = nil
            }


        }).disposed(by: rx.disposeBag)

        self.operationView.needReFreshVIPStateBehaviorRelay.filterNil().bind {[weak self] in
            guard let `self` = self else { return }
            self.viewModle?.fetchVIPState()
        }.disposed(by: rx.disposeBag)
    }


    let navView = SpotNavView()
    let operationView = SpotOperationView()
    let depthView = SpotDepthView()
    let ordersHeaderView = SpotOrdersHeaderView()
    let bubbleView = BubbleView()

    func makeHeaderView() -> UIView {
        let view = UIView()
        var height = SpotNavView.height
        height += 10
        height += max(SpotOperationView.height, SpotDepthView.height)
        height += 16
        height += 16
        height += SpotOrdersHeaderView.height
        view.frame = CGRect(x: 0, y: 0, width: 0, height: height)

        view.addSubview(navView)
        view.addSubview(operationView)
        view.addSubview(depthView)
        view.addSubview(ordersHeaderView)
        view.addSubview(bubbleView)

        navView.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
        }

        operationView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom).offset(10)
            m.left.equalToSuperview().offset(12)
            m.right.equalTo(view.snp.centerX)
        }

        depthView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom).offset(10)
            m.left.equalTo(view.snp.centerX).offset(8)
            m.right.equalToSuperview().offset(-12)
        }

        bubbleView.snp.makeConstraints { (m) in
            m.bottom.equalTo(operationView.priceTextField.snp.top)
            m.left.right.equalTo(operationView.priceTextField).inset(18)
        }

        let line = UIView()
        line.backgroundColor = UIColor(netHex: 0xF3F5F9)
        view.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.top.greaterThanOrEqualTo(operationView.snp.bottom).offset(16)
            m.top.greaterThanOrEqualTo(depthView.snp.bottom).offset(16)
            m.left.right.equalToSuperview()
            m.height.equalTo(16)
        }

        ordersHeaderView.snp.makeConstraints { (m) in
            m.top.equalTo(line.snp.bottom)
            m.left.right.equalToSuperview()
        }
        return view
    }
}

extension SpotViewController {
    class BubbleView: UIView {

        let leftView = UIImageView(image: R.image.icon_spot_bubble_left()?.resizable)
        let centerView = UIImageView(image: R.image.icon_spot_bubble_center()?.resizable)
        let rightView = UIImageView(image: R.image.icon_spot_bubble_right()?.resizable)
        let textLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.numberOfLines = 0
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(leftView)
            addSubview(centerView)
            addSubview(rightView)
            addSubview(textLabel)

            leftView.snp.makeConstraints { (m) in
                m.top.left.bottom.equalToSuperview()
            }

            rightView.snp.makeConstraints { (m) in
                m.top.right.bottom.equalToSuperview()
                m.width.equalTo(leftView)
            }

            centerView.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.equalTo(leftView.snp.right)
                m.right.equalTo(rightView.snp.left)
                m.width.equalTo(15)
            }

            textLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(10)
                m.left.equalToSuperview().offset(15)
                m.bottom.equalToSuperview().offset(-18)
                m.right.equalToSuperview().offset(-15)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
