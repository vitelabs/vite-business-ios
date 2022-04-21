//
//  DividendsItemCell.swift
//  ViteBusiness
//
//  Created by vite on 2022/4/20.
//

import Foundation
import UIKit

struct DividendsItemCellViewModel {
    let vx: String
    let btc: String
    let eth: String
    let usdt: String
    let price: String
    let date: Int64
}

class DividendsItemCell: BaseTableViewCell {
    static let cellHeight: CGFloat = 110
    
    let vxLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B, alpha: 1)
    }

    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }
    
    let lineImageView = UIImageView(image: R.image.dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))
    
    
    let btcItem = DividendsViewController.DetailView.VItemView(title: "BTC")
    let ethItem = DividendsViewController.DetailView.VItemView(title: "ETH")
    let usdtItem = DividendsViewController.DetailView.VItemView(title: "USDT", isLeft: false)

    let totalLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
    }
    
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        selectionStyle = .none

        contentView.addSubview(lineImageView)
        contentView.addSubview(btcItem)
        contentView.addSubview(ethItem)
        contentView.addSubview(usdtItem)
        contentView.addSubview(totalLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(vxLabel)

        let hLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
        }

        addSubview(hLine)
        
        timeLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(8)
            m.left.equalToSuperview().offset(12)
        }
        
        vxLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(8)
            m.right.equalToSuperview().offset(-12)
        }

        lineImageView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(30)
            m.left.right.equalToSuperview().inset(12)
        }
        
        btcItem.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(36)
            m.left.equalToSuperview().offset(12)
        }
        
        ethItem.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(36)
            m.left.equalTo(btcItem.snp.right)
            m.width.equalTo(btcItem).multipliedBy(0.7)
        }
        
        usdtItem.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(36)
            m.left.equalTo(ethItem.snp.right)
            m.width.equalTo(btcItem).multipliedBy(0.7)
            m.right.equalToSuperview().offset(-12)
        }

        totalLabel.snp.makeConstraints { (m) in
            m.top.equalTo(btcItem.snp.bottom).offset(6)
            m.left.equalToSuperview().offset(12)
        }

        hLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.bottom.equalToSuperview().offset(-10)
            m.left.right.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ vm: DividendsItemCellViewModel) {
        timeLabel.text = Date(timeIntervalSince1970: TimeInterval(vm.date)).format()
        vxLabel.text = "\(vm.vx) VX"
        btcItem.valueLabel.text = vm.btc
        ethItem.valueLabel.text = vm.eth
        usdtItem.valueLabel.text = vm.usdt
        totalLabel.text = vm.price
    }
}
