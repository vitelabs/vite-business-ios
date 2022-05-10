//
//  DividendsViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/1.
//

import Foundation
import UIKit
import ActiveLabel
import ViteWallet

class DividendsViewController: BaseTableViewController {
    
    var viewModle: DividendsListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        
    }
    
    func setupView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = makeHeaderView()
        
        navigationItem.title = R.string.localizable.dividendsPageTitle()
    }
    
    let detailView = DetailView()
    let listHeaderView = ListHeaderView()
    
    func makeHeaderView() -> UIStackView {
        let view = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }
        var height: CGFloat = 0
        height += DetailView.height
        height += ListHeaderView.height
        view.frame = CGRect(x: 0, y: 0, width: 0, height: height)
        
        view.addArrangedSubview(detailView.padding(horizontal: 12))
        view.addArrangedSubview(listHeaderView.padding(horizontal: 12))
        
        return view
    }
    
    func bind() {
        HDWalletManager.instance.accountDriver.drive(onNext: {[weak self] (account) in
            guard let `self` = self else { return }
            if let address = account?.address {
                let vm = DividendsListViewModel(tableView: self.tableView, address: address)
                vm.isAutoLockMinedVxModelBehaviorRelay.bind { [weak self] ret in
                    guard let `self` = self else { return }
                    self.detailView.lockView.autoButton.checkButton.isSelected = ret
                }.disposed(by: vm.rx.disposeBag)
                
                vm.totalDividendInfoModelBehaviorRelay.bind { [weak self] in
                    guard let `self` = self else { return }
                    let (btc, price) = $0?.totalBtcAndPriceStrig() ?? ("--.--", "--.--")
                    self.detailView.totalView.titleView.amountLabel.text = btc
                    self.detailView.totalView.titleView.bottomLabel.text = price
                    self.detailView.totalView.btcItem.amountLabel.text = $0?.btcString ?? "--.--"
                    self.detailView.totalView.ethItem.amountLabel.text = $0?.ethString ?? "--.--"
                    self.detailView.totalView.usdtItem.amountLabel.text = $0?.usdtString ?? "--.--"
                }.disposed(by: vm.rx.disposeBag)
                
                vm.myDividendInfoModelBehaviorRelay.bind { [weak self] in
                    guard let `self` = self else { return }
                    let (btc, price) = $0?.totalBtcAndPriceStrig() ?? ("--.--", "--.--")
                    self.detailView.myView.titleView.amountLabel.text = btc
                    self.detailView.myView.titleView.bottomLabel.text = price
                    self.detailView.myView.btcItem.valueLabel.text = $0?.btcString ?? "--.--"
                    self.detailView.myView.ethItem.valueLabel.text = $0?.ethString ?? "--.--"
                    self.detailView.myView.usdtItem.valueLabel.text = $0?.usdtString ?? "--.--"
                }.disposed(by: vm.rx.disposeBag)
                self.viewModle = vm
            } else {
                self.viewModle = nil
            }
        }).disposed(by: rx.disposeBag)
        
        ViteBalanceInfoManager.instance.dexBalanceInfoDriver(forViteTokenId: TokenInfo.BuildIn.vx.value.viteTokenId).drive(onNext: {[weak self] (balance) in
            guard let `self` = self else { return }
            if let balance = balance {
                self.detailView.lockView.amountItemView.valueLabel.text = TokenInfo.BuildIn.vx.value.amountString(amount: balance.vxLocked, precision: .long)
                self.detailView.lockView.unlockingItemView.valueLabel.text = TokenInfo.BuildIn.vx.value.amountString(amount: balance.vxUnlocking, precision: .long)

            } else {
                self.detailView.lockView.amountItemView.valueLabel.text = "--.--"
                self.detailView.lockView.unlockingItemView.valueLabel.text = "--.--"
            }
        })
    }
}

extension DividendsViewController {
    
    class DetailView: UIView {
        
        static let height: CGFloat = 10+190+12+142+12+159
        
        let totalView = TotalView()
        let myView = MyView()
        let lockView = LockView()
            
        let viteView = ItemView(type: .VITE)
        let btcView = ItemView(type: .BTC)
        let ethView = ItemView(type: .ETH)
        let usdtView = ItemView(type: .USDT)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(totalView)
            addSubview(myView)
            addSubview(lockView)
            
            snp.makeConstraints { (m) in
                m.height.equalTo(type(of: self).height)
            }
            
            totalView.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(10)
                m.left.right.equalToSuperview()
            }
            
            myView.snp.makeConstraints { (m) in
                m.top.equalTo(totalView.snp.bottom).offset(12)
                m.left.right.equalToSuperview()
            }
            
            lockView.snp.makeConstraints { (m) in
                m.top.equalTo(myView.snp.bottom).offset(12)
                m.left.right.equalToSuperview()
            }
            
            totalView.titleView.titleLabel.text = R.string.localizable.dividendsPageTotalTitle()
            myView.titleView.titleLabel.text = R.string.localizable.dividendsPageMyTitle()
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        
        class TotalView: BGBView {
            
            let titleView = TitleView()
            let bgsView = BGSView()
            let btcItem = ItemView(type: .BTC)
            let ethItem = ItemView(type: .ETH)
            let usdtItem = ItemView(type: .USDT)

            override init(frame: CGRect) {
                super.init(frame: frame)
                addSubview(titleView)
                addSubview(bgsView)
                addSubview(btcItem)
                addSubview(ethItem)
                addSubview(usdtItem)
                
                titleView.snp.makeConstraints { make in
                    make.top.left.equalToSuperview().offset(12)
                    make.right.equalToSuperview().offset(-12)
                }
                
                bgsView.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(94)
                    make.left.right.equalToSuperview().inset(12)
                    make.height.equalTo(84)
                }
                
                btcItem.snp.makeConstraints { make in
                    make.top.equalTo(bgsView).offset(12)
                    make.left.equalTo(bgsView).inset(12)
                }
                
                ethItem.snp.makeConstraints { make in
                    make.top.equalTo(btcItem.snp.bottom).offset(6)
                    make.left.equalTo(bgsView).inset(12)
                }
                
                usdtItem.snp.makeConstraints { make in
                    make.top.equalTo(ethItem.snp.bottom).offset(6)
                    make.left.equalTo(bgsView).inset(12)
                }
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            class ItemView: UIView {
                
                enum ItemType: String {
                    case BTC
                    case ETH
                    case USDT
                    
                    var image: UIImage? {
                        switch self {
                        case .BTC:
                            return R.image.icon_mining_trading_btc()
                        case .ETH:
                            return R.image.icon_mining_trading_eth()
                        case .USDT:
                            return R.image.icon_mining_trading_usdt()
                        }
                    }
                    
                    var symbol: String { self.rawValue }
                }
                
                let iconImageView = UIImageView()

                let amountLabel = UILabel().then {
                    $0.textColor = UIColor(netHex: 0x24272B, alpha: 1)
                    $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                    $0.text = "--.--"
                }
                
                let symbolLabel = UILabel().then {
                    $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
                    $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                }
                
                
                init(type: ItemType) {
                    super.init(frame: .zero)
                    
                    iconImageView.image = type.image
                    
                    addSubview(iconImageView)
                    addSubview(amountLabel)
                    addSubview(symbolLabel)
                    
                    iconImageView.snp.makeConstraints { (m) in
                        m.centerY.equalToSuperview()
                        m.left.equalToSuperview()
                        m.size.equalTo(CGSize(width: 16, height: 16))
                    }
                    
                    amountLabel.snp.makeConstraints { (m) in
                        m.centerY.equalToSuperview()
                        m.left.equalTo(iconImageView.snp.right).offset(12)
                    }
                    
                    symbolLabel.snp.makeConstraints { (m) in
                        m.centerY.equalTo(amountLabel)
                        m.left.equalTo(amountLabel.snp.right).offset(6)
                    }
                    
                    iconImageView.image = type.image
                    symbolLabel.text = type.symbol
                    
                    self.snp.makeConstraints { (m) in
                        m.height.equalTo(16)
                    }
                }
                
                required init?(coder: NSCoder) {
                    fatalError("init(coder:) has not been implemented")
                }
            }
        }
        
        class MyView: BGBView {
            
            let titleView = TitleView()
            let lineImageView = UIImageView(image: R.image.dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))
            let btcItem = VItemView(title: "BTC", itemType: VItemView.ItemType.BTC)
            let ethItem = VItemView(title: "ETH", itemType: VItemView.ItemType.ETH)
            let usdtItem = VItemView(title: "USDT", itemType: VItemView.ItemType.USDT, isLeft: false)

            override init(frame: CGRect) {
                super.init(frame: frame)
                addSubview(titleView)
                addSubview(lineImageView)
                addSubview(btcItem)
                addSubview(ethItem)
                addSubview(usdtItem)
                
                snp.remakeConstraints { (m) in
                    m.height.equalTo(142)
                }
                
                titleView.snp.makeConstraints { make in
                    make.top.left.equalToSuperview().offset(12)
                    make.right.equalToSuperview().offset(-12)
                }
                
                lineImageView.snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(94)
                    make.left.right.equalToSuperview().inset(12)
                }
                
                btcItem.snp.makeConstraints { make in
                    make.top.equalTo(lineImageView).offset(5)
                    make.left.equalToSuperview().inset(12)
                }
                
                ethItem.snp.makeConstraints { make in
                    make.top.equalTo(btcItem)
                    make.left.equalTo(btcItem.snp.right)
                    make.width.equalTo(btcItem).multipliedBy(0.7)
                }
                
                usdtItem.snp.makeConstraints { make in
                    make.top.equalTo(btcItem)
                    make.left.equalTo(ethItem.snp.right)
                    make.right.equalToSuperview().inset(12)
                    make.width.equalTo(btcItem).multipliedBy(0.7)
                }
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        public class ConfirmView: UIView {

            let checkButton = UIButton()
            let label = ActiveLabel()

            override init(frame: CGRect) {
                super.init(frame: frame)

                checkButton.setImage(R.image.unselected(), for: .normal)
                checkButton.setImage(R.image.selected(), for: .selected)

                label.numberOfLines = 0
                label.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
                label.font = UIFont.systemFont(ofSize: 14, weight: .regular)

                addSubview(checkButton)
                addSubview(label)
                checkButton.snp.makeConstraints { (m) in
                    m.top.equalToSuperview().offset(3)
                    m.left.equalToSuperview()
                    m.size.equalTo(CGSize(width: 12, height: 12))
                }
                label.snp.makeConstraints { (m) in
                    m.top.right.bottom.equalToSuperview()
                    m.left.equalTo(checkButton.snp.right).offset(6)
                }
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        class LockView: UIView {

            static let height: CGFloat = 159

            let titleLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
                $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                $0.text = R.string.localizable.dividendsPageLockTitle()
            }
            
            let amountItemView = VItemView(title: R.string.localizable.dividendsPageLockAmount())
            let unlockingItemView = VItemView(title: R.string.localizable.dividendsPageUnlockingAmount())
            
            let autoButton = ConfirmView().then { view in
                view.label.text = R.string.localizable.dividendsPageLockAuto()
            }
            
            let detailButton = UIButton().then {
                $0.setTitleColor(UIColor.init(netHex: 0x007AFF), for: .normal)
                $0.setTitleColor(UIColor.init(netHex: 0x007AFF).highlighted, for: .highlighted)
                $0.setImage(R.image.icon_mining_trading_right_white()?.tintColor(UIColor.init(netHex: 0x007AFF)), for: .normal)
                $0.setImage(R.image.icon_mining_trading_right_white()?.tintColor(UIColor.init(netHex: 0x007AFF)).highlighted, for: .highlighted)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                $0.titleLabel?.adjustsFontSizeToFitWidth = true
                $0.transform = CGAffineTransform(scaleX: -1, y: 1)
                $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
                $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
                $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
                $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2)
                $0.setTitle(R.string.localizable.dividendsPageLockDetailButtonTitle(), for: .normal)
            }

            let lockButton = UIButton().then {
                $0.setBackgroundImage(R.image.icon_mining_staking_add_bg()?.resizable, for: .normal)
                $0.setBackgroundImage(R.image.icon_mining_staking_add_bg()?.highlighted.resizable, for: .highlighted)
                $0.setTitleColor(.white, for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                $0.setTitle(R.string.localizable.dividendsPageLockLockButtonTitle(), for: .normal)
            }

            let unlockButton = UIButton().then {
                $0.setBackgroundImage(R.image.icon_mining_staking_list_bg()?.resizable, for: .normal)
                $0.setBackgroundImage(R.image.icon_mining_staking_list_bg()?.highlighted.resizable, for: .highlighted)
                $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
                $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                $0.setTitle(R.string.localizable.dividendsPageLockUnlockButtonTitle(), for: .normal)
            }

            override init(frame: CGRect) {
                super.init(frame: frame)

                layer.masksToBounds = true
                layer.cornerRadius = 2
                backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: CGRect(x: 0, y: 0, width: kScreenW - 24, height: type(of: self).height), colors: [
                    UIColor(netHex: 0xE3F0FF),
                    UIColor(netHex: 0xF2F8FF),
                ])

                addSubview(titleLabel)
                addSubview(amountItemView)
                addSubview(unlockingItemView)
                addSubview(detailButton)
                addSubview(autoButton)
                addSubview(lockButton)
                addSubview(unlockButton)
                
                titleLabel.snp.makeConstraints { m in
                    m.top.equalToSuperview().inset(12)
                    m.left.equalToSuperview().inset(12)
                }
                
                detailButton.snp.makeConstraints { m in
                    m.top.equalToSuperview().inset(12)
                    m.right.equalToSuperview().inset(16)
                }

                amountItemView.snp.makeConstraints { (m) in
                    m.top.equalTo(titleLabel.snp.bottom).offset(12)
                    m.left.equalToSuperview().inset(12)
                }

                unlockingItemView.snp.makeConstraints { (m) in
                    m.top.equalTo(amountItemView)
                    m.right.equalToSuperview().inset(12)
                    m.left.equalTo(amountItemView.snp.right)
                    m.width.equalTo(amountItemView)
                }

                snp.makeConstraints { (m) in
                    m.height.equalTo(type(of: self).height)
                }

                lockButton.snp.makeConstraints { (m) in
                    m.left.equalToSuperview().offset(12)
                    m.bottom.equalToSuperview().offset(-12)
                    m.height.equalTo(26)
                }

                unlockButton.snp.makeConstraints { (m) in
                    m.left.equalTo(lockButton.snp.right).offset(13)
                    m.width.equalTo(lockButton)
                    m.bottom.equalToSuperview().offset(-12)
                    m.size.equalTo(lockButton)
                    m.right.equalToSuperview().offset(-12)
                }
                
                autoButton.snp.makeConstraints { m in
                    m.left.equalToSuperview().offset(12)
                    m.bottom.equalTo(lockButton.snp.top).offset(-12)
                }

                lockButton.rx.tap.bind {
                    DividendsVXLockConfirmView().show()
                }.disposed(by: rx.disposeBag)
                
                unlockButton.rx.tap.bind {
                    DividendsVXUnlockConfirmView().show()
                }.disposed(by: rx.disposeBag)
                
                autoButton.checkButton.rx.tap.bind { [weak self] in
                    guard let `self` = self else { return }
                    self.checkButtonClicked()
                }.disposed(by: rx.disposeBag)
                
                let customType = ActiveType.custom(pattern: autoButton.label.text!)
                autoButton.label.enabledTypes = [customType]
                autoButton.label.customize { [weak self] label in
                    guard let `self` = self else { return }
                    label.customColor[customType] = self.autoButton.label.textColor
                    label.customSelectedColor[customType] = self.autoButton.label.textColor
                    label.handleCustomTap(for: customType) { [weak self] element in
                        self?.checkButtonClicked()
                    }
                }
                
                detailButton.rx.tap.bind {
                    let vc = DividendsVXUnlockListViewController()
                    UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                }.disposed(by: rx.disposeBag)
                
            }
            
            func checkButtonClicked() {
                if self.autoButton.checkButton.isSelected {
                    Workflow.dexSwitchConfigOffWithConfirm(account: HDWalletManager.instance.account!, completion: {[weak self] (r) in
                        guard let `self` = self else { return }
                        if case .success = r {
                            self.autoButton.checkButton.isSelected = false
                        }
                    })
                } else {
                    Workflow.dexSwitchConfigOnWithConfirm(account: HDWalletManager.instance.account!, completion: {[weak self] (r) in
                        guard let `self` = self else { return }
                        if case .success = r {
                            self.autoButton.checkButton.isSelected = true
                        }
                    })
                }
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

//            func bind(vm: (DexMiningStakeInfo, DexCancelStakeInfo)?) {
//                if let info = vm {
//                    amountItemView.valueLabel.text = info.0.totalStakeAmount.amount(decimals: 18, count: 6, groupSeparator: true)
//                    unlockingItemView.valueLabel.text = info.1.totalCancellingAmount.amount(decimals: 18, count: 6, groupSeparator: true)
//                } else {
//                    amountItemView.valueLabel.text = "--.--"
//                    unlockingItemView.valueLabel.text = "--.--"
//                }
//            }
        }
        
        class VItemView: UIView {
            
            static let height: CGFloat = 16+16+4
            
            enum ItemType: String {
                case BTC
                case ETH
                case USDT
                
                var image: UIImage? {
                    switch self {
                    case .BTC:
                        return R.image.icon_mining_trading_btc()
                    case .ETH:
                        return R.image.icon_mining_trading_eth()
                    case .USDT:
                        return R.image.icon_mining_trading_usdt()
                    }
                }
                
                var symbol: String { self.rawValue }
            }
            
            let iconImageView = UIImageView()
            
            let titleLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            }

            let valueLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x24272B)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                $0.text = "--.--"
            }
            
            init(title: String, itemType:ItemType? = nil, isLeft: Bool = true) {
                super.init(frame: .zero)
                
                addSubview(titleLabel)
                addSubview(valueLabel)
                
                titleLabel.text = title
                
                if isLeft {
                    
                    if let type = itemType {
                        addSubview(iconImageView)
                        iconImageView.image = type.image
                        
                        iconImageView.snp.makeConstraints { m in
                            m.size.equalTo(CGSize(width: 14, height: 14))
                            m.centerY.equalTo(titleLabel)
                            m.left.equalToSuperview()
                        }
                        
                        titleLabel.snp.makeConstraints { (m) in
                            m.top.equalToSuperview()
                            m.left.equalTo(iconImageView.snp.right).offset(5)
                            m.right.lessThanOrEqualToSuperview()
                        }
                    } else {
                        titleLabel.snp.makeConstraints { (m) in
                            m.top.left.equalToSuperview()
                            m.right.lessThanOrEqualToSuperview()
                        }
                    }
                    
                    
                    
                    valueLabel.snp.makeConstraints { (m) in
                        m.bottom.left.equalToSuperview()
                        m.right.lessThanOrEqualToSuperview()
                    }
                } else {
                    
                    if let type = itemType {
                        addSubview(iconImageView)
                        iconImageView.image = type.image
                        
                        iconImageView.snp.makeConstraints { m in
                            m.size.equalTo(CGSize(width: 14, height: 14))
                            m.centerY.equalTo(titleLabel)
                            m.left.greaterThanOrEqualToSuperview()
                            m.right.equalTo(titleLabel.snp.left).offset(-5)
                        }
                        
                        titleLabel.snp.makeConstraints { (m) in
                            m.top.right.equalToSuperview()
                            
                        }
                    } else {
                        titleLabel.snp.makeConstraints { (m) in
                            m.top.right.equalToSuperview()
                            m.left.greaterThanOrEqualToSuperview()
                        }
                    }
                    
                    valueLabel.snp.makeConstraints { (m) in
                        m.bottom.right.equalToSuperview()
                        m.left.greaterThanOrEqualToSuperview()
                    }
                }
                
                
                
                snp.makeConstraints { (m) in
                    m.height.equalTo(type(of: self).height)
                }
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        class TitleView: UIView {
            
            let titleLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
                $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            }
            
            let amountLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x24272B, alpha: 1)
                $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
                $0.text = "--.--"
            }
            
            let bottomLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                $0.text = "--.--"
            }

            override init(frame: CGRect) {
                super.init(frame: frame)

                addSubview(titleLabel)
                addSubview(amountLabel)
                addSubview(bottomLabel)
                
                titleLabel.snp.makeConstraints { make in
                    make.top.left.equalToSuperview()
                }
                
                amountLabel.snp.makeConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom).offset(6)
                    make.left.equalToSuperview()
                }
                
                bottomLabel.snp.makeConstraints { make in
                    make.top.equalTo(amountLabel.snp.bottom).offset(6)
                    make.bottom.left.equalToSuperview()
                }
                
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            
        }
        
        class BGBView: UIView {

            static let height: CGFloat = 190

            override init(frame: CGRect) {
                super.init(frame: frame)

                layer.masksToBounds = true
                layer.cornerRadius = 2
                backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: CGRect(x: 0, y: 0, width: kScreenW - 24, height: type(of: self).height), colors: [
                    UIColor(netHex: 0xE3F0FF),
                    UIColor(netHex: 0xF2F8FF),
                ])
                
                snp.makeConstraints { (m) in
                    m.height.equalTo(type(of: self).height)
                }
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

        }
        
        class BGSView: UIView {

            static let height: CGFloat = 84

            override init(frame: CGRect) {
                super.init(frame: frame)

                layer.masksToBounds = true
                layer.cornerRadius = 2
                backgroundColor = UIColor(netHex: 0x007AFF, alpha: 0.04)
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

        }
        
        class ItemView: UIView {
            
            enum ItemType: String {
                case VITE
                case BTC
                case ETH
                case USDT
                
                var image: UIImage? {
                    switch self {
                    case .VITE:
                        return R.image.icon_mining_trading_vite()
                    case .BTC:
                        return R.image.icon_mining_trading_btc()
                    case .ETH:
                        return R.image.icon_mining_trading_eth()
                    case .USDT:
                        return R.image.icon_mining_trading_usdt()
                    }
                }
                
                var symbol: String { self.rawValue }
            }
            
            let iconImageView = UIImageView()
            
            let earningsTitleLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                $0.text = R.string.localizable.miningOrderPageHeaderEstimate()
            }
            
            let earningsLabel = UILabel().then {
                $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 1)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
                $0.text = "--.-- VX"
            }
            
            
            init(type: ItemType) {
                super.init(frame: .zero)
                
                iconImageView.image = type.image
                
                addSubview(iconImageView)
                addSubview(earningsTitleLabel)
                addSubview(earningsLabel)
                
                backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: CGRect(x: 0, y: 0, width: kScreenW - 24, height: 48), colors: [
                    UIColor(netHex: 0xE3F0FF),
                    UIColor(netHex: 0xF2F8FF),
                ])
                
                iconImageView.snp.makeConstraints { (m) in
                    m.centerY.equalToSuperview()
                    m.left.equalToSuperview().offset(12)
                    m.size.equalTo(CGSize(width: 24, height: 24))
                }
                
                earningsTitleLabel.snp.makeConstraints { (m) in
                    m.centerY.equalToSuperview()
                    m.left.equalTo(iconImageView.snp.right).offset(12)
                }
                
                earningsLabel.snp.makeConstraints { (m) in
                    m.centerY.equalTo(earningsTitleLabel)
                    m.left.equalTo(earningsTitleLabel.snp.right).offset(5)
                }
                
                self.snp.makeConstraints { (m) in
                    m.height.equalTo(48)
                }
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }
    
    class ListHeaderView: UIView {
        
        static let height: CGFloat = 38
        
        let titleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.text = R.string.localizable.dividendsPageLockHeaderTitle()
        }
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(14)
                m.left.right.equalToSuperview()
            }
            
            snp.makeConstraints { (m) in
                m.height.equalTo(type(of: self).height)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension ViteWallet.DexDividendInfo {
    var btcString: String {
        btc.amountFullWithGroupSeparator(decimals: 8)
    }
    
    var ethString: String {
        eth.amountFullWithGroupSeparator(decimals: 18)
    }
    
    var usdtString: String {
        usdt.amountShortStringForDeFiWithGroupSeparator(decimals: 6)
    }
    
    func totalBtcAndPriceStrig() -> (String, String) {
        
        guard let ethDic = ExchangeRateManager.instance.rateMap["1352"],
              let ethString = ethDic["btc"] as? String,
              let eth2btcRate = BigDecimal(ethString) else {
            return ("--.--", "--.--")
        }
        
        guard let usdtDic = ExchangeRateManager.instance.rateMap["1353"],
              let usdtString = usdtDic["btc"] as? String,
              let usdt2btcRate = BigDecimal(usdtString) else {
            return ("--.--", "--.--")
        }
        
        let bigDecimal = BigDecimal(number: btc, digits: 8) +
                         BigDecimal(number: eth, digits: 18) * eth2btcRate +
                         BigDecimal(number: usdt, digits: 6) * usdt2btcRate
        
        let btc = BigDecimalFormatter.format(bigDecimal: bigDecimal, style: .decimalRound(8), padding: .none, options: [.groupSeparator])
        let price = "≈" + ExchangeRateManager.instance.rateMap.btcPriceString(btc: bigDecimal)
        return (btc, price)
    }
    
    
}
