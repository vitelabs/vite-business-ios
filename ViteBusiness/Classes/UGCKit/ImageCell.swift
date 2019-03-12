//
//  ImageCell.swift
//  Vite
//
//  Created by Water on 2018/9/12.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import Eureka
import SnapKit

public class ImageCell: Cell<Bool>, CellType {

    public lazy var titleLab: UILabel = {
        let titleLab = UILabel()
        titleLab.translatesAutoresizingMaskIntoConstraints = false
        titleLab.textAlignment = .left
        titleLab.textColor = Colors.cellTitleGray
        titleLab.font = Fonts.light16
        return titleLab
    }()

    public lazy var rightLab: UILabel = {
        let titleLab = UILabel()
        titleLab.translatesAutoresizingMaskIntoConstraints = false
        titleLab.textAlignment = .right
        titleLab.textColor = UIColor(netHex: 0x8E8E93)
        titleLab.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLab.text = ""
        return titleLab
    }()

    public lazy var rightImageView: UIImageView = {
        let rightImageView = UIImageView()
        rightImageView.backgroundColor = .clear
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.contentMode = .scaleAspectFit
        return rightImageView
    }()

    public override func setup() {
        super.setup()
        contentView.addSubview(titleLab)
        contentView.addSubview(rightLab)
        contentView.addSubview(rightImageView)

        self.titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(24)
            make.centerY.equalTo(contentView)
        }

        self.rightLab.snp.makeConstraints({ (make) in
            make.right.equalTo(contentView).offset(-40)
            make.centerY.equalTo(contentView)
        })

        self.rightImageView.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-20)
            make.centerY.equalTo(contentView)
        }
        self.height = { 60 }

        self.bottomSeparatorLine.isHidden = false
    }

    public override func update() {
        super.update()
    }

}

public final class ImageRow: Row<ImageCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ImageCell>()
    }

    public override func customDidSelect() {
        guard !isDisabled else {
            super.customDidSelect()
            return
        }
        deselect()
    }
}
