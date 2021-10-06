//
//  SpotHistoryViewController.swift
//  ViteBusiness
//
//  Created by stone on 2021/9/16.
//

import UIKit
import RxSwift
import RxCocoa

class SpotHistoryViewController: BaseTableViewController {
    
    init() {
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
    var viewModle: SpotHistoryListViewModel!
    let segmentView = SegmentView()
    let filterBehaviorRelay: BehaviorRelay<Filter> = BehaviorRelay(value: Filter())
    
    func setupView() {
        
        navigationItem.title = R.string.localizable.spotHistoryPageTitle()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_spot_filter(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(self.onFilter))
        
        view.addSubview(segmentView)
        segmentView.snp.makeConstraints { m in
            m.centerX.equalToSuperview()
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(4)
        }
        
        tableView.snp.remakeConstraints { m in
            m.top.equalTo(segmentView.snp.bottom).offset(14)
            m.left.right.bottom.equalToSuperview()
        }
        
        self.viewModle = SpotHistoryListViewModel(tableView: self.tableView, address: HDWalletManager.instance.account!.address)
    }
    
    func bind() {
        Driver.combineLatest(
            segmentView.isOpenBehaviorRelay.asDriver(),
            filterBehaviorRelay.asDriver()).drive(onNext: { [weak self] (isOpen, filter) in
                guard let `self` = self else { return }
                if isOpen {
                    self.viewModle.showOpen(tradeTokenSymbol: filter.tradeTokenSymbol, quoteTokenSymbol: filter.quoteTokenSymbol, startTime: filter.startTime, side: filter.side)
                } else {
                    self.viewModle.showHistory(tradeTokenSymbol: filter.tradeTokenSymbol, quoteTokenSymbol: filter.quoteTokenSymbol, startTime: filter.startTime, side: filter.side, status: filter.status)
                }
        }).disposed(by: rx.disposeBag)
    }
    
    @objc func onFilter() {
        SpotHistoryFilterView(superview: self.navigationController!.view, isShowStatus: !self.viewModle.isShowOpen, filter: self.filterBehaviorRelay.value, completion: { ret in
            self.filterBehaviorRelay.accept(ret)
        }).show()
    }
}


extension SpotHistoryViewController {
    
    class Filter {
        
        enum Data: Int {
            case all = 0
            case m3 = 1
            case m1 = 2
            case w1 = 3
            case d1 = 4
        }
        
        var quoteTokenSymbol: String? = nil
        var tradeTokenSymbol: String? = nil
        private(set) var side: Int32? = nil
        private(set) var status: MarketOrder.Status? = nil
        
        var startTime: TimeInterval? {
            switch data {
            case .all: return nil
            case .m3: return Date().timeIntervalSince1970 - 90 * 24 * 60 * 60
            case .m1: return Date().timeIntervalSince1970 - 30 * 24 * 60 * 60
            case .w1: return Date().timeIntervalSince1970 - 7 * 24 * 60 * 60
            case .d1: return Date().timeIntervalSince1970 - 24 * 60 * 60
            }
        }
        
        private(set) var data: Data = .all
        var dataIndex: Int {
            data.rawValue
        }
        
        var sideIndex: Int {
            if let s = side {
                return s == 0 ? 1 : 2
            } else {
                return 0
            }
        }
        
        var statusIndex: Int {
            if let s = status {
                switch s {
                case .open: return 1
                case .closed: return 2
                case .canceled: return 3
                case .failed: return 4
                }
            } else {
                return 0
            }
        }
        
        func updateData(_ index: Int) {
            data = Data(rawValue: index)!
        }
        
        func updateSide(_ index: Int) {
            if index == 0 {
                side = nil
            } else if index == 1 {
                side = 0
            } else if  index == 2  {
                side = 1
            }
        }
        
        func updateStatus(_ index: Int) {
            if index == 0 {
                status = nil
            } else if  index == 1 {
                status = .open
            } else if  index == 2  {
                status = .closed
            } else if  index == 3  {
                status = .canceled
            } else if  index == 4  {
                status = .failed
            }
        }
    }
    
    class SegmentView: UIView {

        let openButton = UIButton().then {
            $0.setTitle(R.string.localizable.spotHistoryPageSegmentOpen(), for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
            $0.setBackgroundImage(R.image.background_button_blue()?.resizable, for: .disabled)
            $0.setTitleColor(.white, for: .disabled)
            
            
            $0.setBackgroundImage(nil, for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        }

        let historyButton = UIButton().then {
            $0.setTitle(R.string.localizable.spotHistoryPageSegmentHistory(), for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
            $0.setBackgroundImage(R.image.background_button_blue()?.resizable, for: .disabled)
            $0.setTitleColor(.white, for: .disabled)
            
            
            $0.setBackgroundImage(nil, for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        }

        let isOpenBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: true)

        override init(frame: CGRect) {
            super.init(frame: frame)

            layer.cornerRadius = 2
            layer.borderColor = UIColor(netHex: 0x007AFF).cgColor
            layer.borderWidth = 0.5

            addSubview(openButton)
            addSubview(historyButton)

            openButton.snp.makeConstraints { (m) in
                m.top.bottom.left.equalToSuperview()
                m.height.equalTo(30)
            }

            historyButton.snp.makeConstraints { (m) in
                m.top.bottom.right.equalToSuperview()
                m.left.equalTo(openButton.snp.right)
                m.width.equalTo(openButton)
            }

            isOpenBehaviorRelay.bind { [weak self] isOpen in
                guard let `self` = self else { return }
                self.openButton.isEnabled = !isOpen
                self.historyButton.isEnabled = isOpen
            }.disposed(by: rx.disposeBag)

            openButton.rx.tap.bind { [weak self] in
                self?.isOpenBehaviorRelay.accept(true)
            }.disposed(by: rx.disposeBag)

            historyButton.rx.tap.bind { [weak self] in
                self?.isOpenBehaviorRelay.accept(false)
            }.disposed(by: rx.disposeBag)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
