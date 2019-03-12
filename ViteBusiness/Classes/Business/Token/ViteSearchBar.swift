//
//  ViteSearchBar.swift
//  ViteBusiness
//
//  Created by Water on 2019/3/12.
//

class ViteSearchBar: UISearchBar {

    var isActive: Bool = false

    var alwaysHiddenCancelButton: Bool = true
    override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) {
        if !alwaysHiddenCancelButton {
            super.setShowsCancelButton(showsCancelButton, animated: animated)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isActive {
            self.frame.origin.x = 15
            self.frame.size.width = self.frame.size.width-30
        }

        //设置textfield
        if let textField: UITextField = value(forKey: "_searchField") as? UITextField {
            var frame = textField.frame
            frame.size.height = 30
            frame.size.width = frame.size.width - 40
            frame.origin.y = (self.bounds.size.height - frame.size.height) / 2.0
            frame.origin.x = frame.origin.x + 5
            textField.frame = frame
//            textField.layer.cornerRadius = 15
//            textField.layer.masksToBounds = true
        }
    }
}
