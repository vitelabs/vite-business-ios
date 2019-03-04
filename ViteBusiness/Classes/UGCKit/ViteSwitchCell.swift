//
//  ViteSwitchCell.swift
//  ViteBusiness
//
//  Created by Water on 2019/3/4.
//

import Eureka
import SnapKit

open class ViteSwitchCell: Cell<Bool>, CellType {

    @IBOutlet public weak var switchControl: SwitchControl!

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let switchC = SwitchControl.createSwitchControl()
        switchControl = switchC
        accessoryView = switchControl
        editingAccessoryView = accessoryView
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        selectionStyle = .none
        switchControl.addTarget(self, action: #selector(ViteSwitchCell.valueChanged), for: .valueChanged)
    }

    deinit {
        switchControl?.removeTarget(self, action: nil, for: .allEvents)
    }

    open override func update() {
        super.update()
        switchControl.setOn(row.value ?? false, animated: false)
        switchControl.isEnabled = !row.isDisabled
    }

    @objc func valueChanged() {
        row.value = switchControl.isOn()
    }
}

// MARK: SwitchRow

open class _ViteSwitchRow: Row<ViteSwitchCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

/// Boolean row that has a UISwitch as accessoryType
public final class ViteSwitchRow: _ViteSwitchRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

