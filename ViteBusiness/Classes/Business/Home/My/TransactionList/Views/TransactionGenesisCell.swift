//
//  TransactionGenesisCell.swift
//  Vite
//
//  Created by Stone on 2018/9/11.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TransactionGenesisCell: BaseTableViewCell {

    static var cellHeight: CGFloat {
        return 72
    }

    fileprivate let button = UIButton().then {
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        $0.setImage(R.image.icon_genesis_button(), for: .normal)
        $0.setImage(R.image.icon_genesis_button()?.highlighted, for: .highlighted)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        selectionStyle = .none

        contentView.addSubview(button)
        button.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(viewModel: TransactionViewModelType, index: Int) {
        button.setTitle(viewModel.typeName, for: .normal)

        button.rx.tap.bind {
            WebHandler.openTranscationGenesisPage(address: HDWalletManager.instance.account?.address ?? "")
            }.disposed(by: disposeBag)
    }

}
