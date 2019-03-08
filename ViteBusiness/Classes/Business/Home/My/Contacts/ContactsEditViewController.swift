//
//  ContactsEditViewController.swift
//  Vite
//
//  Created by Stone on 2018/9/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources
import ActionSheetPicker_3_0

class ContactsEditViewController: BaseViewController {

    let contact: Contact!
    let isEdit: Bool
    init(contact: Contact?) {
        self.contact = contact
        self.isEdit = contact != nil
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollableView.stackView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    let scrollableView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 0, right: 24)).then {
        $0.stackView.spacing = 0
    }

    let nameView = TitleTextFieldView(title: R.string.localizable.contactsEditPageNameTitle())
    let addressView = ContactAddressInputView()

    var type: BehaviorRelay<CoinType> = BehaviorRelay(value: CoinType.vite)

    fileprivate func setupView() {

        if isEdit {
            navigationTitleView = NavigationTitleView(title: R.string.localizable.contactsEditPageAddTitle())
        } else {
            navigationTitleView = NavigationTitleView(title: R.string.localizable.contactsEditPageAddTitle())
        }

        view.addSubview(scrollableView)
        scrollableView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom).offset(10)
            m.left.right.bottom.equalToSuperview()
        }

        scrollableView.stackView.addArrangedSubview(nameView)
        scrollableView.stackView.addPlaceholder(height: 20)
        scrollableView.stackView.addArrangedSubview(addressView)



    }

    func bind() {
        type.bind { [weak self] type in
            self?.addressView.typeButton.setTitle(type.name, for: .normal)
        }.disposed(by: rx.disposeBag)

        var index = 0
        for (i, type) in CoinType.allTypes.enumerated() where self.type.value == type {
            index = i
        }

        addressView.typeButton.rx.tap.bind {
            _ =  ActionSheetStringPicker.show(withTitle: R.string.localizable.selectWalletAccount(), rows: CoinType.allTypes.map({ $0.name }), initialSelection: index, doneBlock: {[weak self] _, index, _ in
                self?.type.accept(CoinType.allTypes[index])
            }, cancel: { _ in return }, origin: self.view)
        }.disposed(by: rx.disposeBag)
    }
}
