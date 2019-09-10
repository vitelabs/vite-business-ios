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
import ViteWallet
import web3swift

class ContactsEditViewController: BaseViewController {

    let contact: Contact?
    var type: BehaviorRelay<CoinType>

    init(contact: Contact) {
        self.contact = contact
        self.type = BehaviorRelay(value: contact.type)
        super.init(nibName: nil, bundle: nil)
    }

    init(type: CoinType?) {
        self.contact = nil
        self.type = BehaviorRelay(value: type ?? CoinType.vite)
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(view)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    let scrollableView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 0, right: 24))

    let nameView = TitleTextFieldView(title: R.string.localizable.contactsEditPageNameTitle())
    let addressView = ContactAddressInputView()
    let saveButton = UIButton(style: .blue, title: R.string.localizable.contactsEditPageSaveButtonTitle())

    fileprivate func setupView() {

        if let contact = contact  {
            navigationTitleView = NavigationTitleView(title: R.string.localizable.contactsEditPageAddTitle())
            nameView.textField.text = contact.name
            addressView.textView.text = contact.address
        } else {
            navigationTitleView = NavigationTitleView(title: R.string.localizable.contactsEditPageAddTitle())
        }

        view.addSubview(scrollableView)
        view.addSubview(saveButton)
        scrollableView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom).offset(10)
            m.left.right.bottom.equalToSuperview()
        }

        scrollableView.stackView.addArrangedSubview(nameView)
        scrollableView.stackView.addPlaceholder(height: 20)
        scrollableView.stackView.addArrangedSubview(addressView)


        saveButton.snp.makeConstraints({ (m) in
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        })

        if let _ = contact {
            showDeleteButton()
        }
    }

    func bind() {
        type.bind { [weak self] type in
            self?.addressView.typeButton.setTitle(type.name, for: .normal)
        }.disposed(by: rx.disposeBag)

        addressView.typeButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            var index = 0
            for (i, type) in CoinType.allTypes.enumerated() where self.type.value == type {
                index = i
            }
            _ =  ActionSheetStringPicker.show(withTitle: R.string.localizable.contactsEditPageTypeSelectTitle(), rows: CoinType.allTypes.map({ $0.name }), initialSelection: index, doneBlock: {[weak self] _, index, _ in
                self?.type.accept(CoinType.allTypes[index])
            }, cancel: { _ in return }, origin: self.view)
        }.disposed(by: rx.disposeBag)

        Driver.combineLatest(
            nameView.textField.rx.text.asDriver(),
            addressView.textView.rx.text.asDriver())
            .map { !(($0 ?? "").isEmpty || ($1 ?? "").isEmpty) }
        .drive(saveButton.rx.isEnabled)

        saveButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            switch self.type.value {
            case .vite:
                guard self.addressView.textView.text.isViteAddress else {
                    Toast.show(R.string.localizable.sendPageToastAddressError())
                    return
                }
            case .eth:
                guard let address = EthereumAddress(self.addressView.textView.text), address.isValid else {
                    Toast.show(R.string.localizable.sendPageToastAddressError())
                    return
                }
            case .grin:
                break
            default:
                fatalError()
            }

            Statistics.log(eventId: Statistics.Page.MyHome.contactAddSaveClicked.rawValue)
            if let contact = self.contact {
                let c = Contact(id: contact.id, type: self.type.value, name: self.nameView.textField.text!, address: self.addressView.textView.text)
                AddressManageService.instance.updateContact(c)
                Toast.show(R.string.localizable.contactsEditPageEditSuccessTip())
                self.navigationController?.popViewController(animated: true)
            } else {
                AddressManageService.instance.addContact(type: self.type.value, name: self.nameView.textField.text!, address: self.addressView.textView.text)
                Toast.show(R.string.localizable.contactsEditPageSaveSuccessTip())
                self.navigationController?.popViewController(animated: true)
            }
        }.disposed(by: rx.disposeBag)

        addressView.scanButton.rx.tap.bind { [weak self] in
            let scanViewController = ScanViewController()
            _ = scanViewController.rx.result.bind {[weak self, scanViewController] result in
                guard let `self` = self else { return }
                if case .success(let uri) = ViteURI.parser(string: result) {
                    self.addressView.textView.text = uri.address
                    scanViewController.navigationController?.popViewController(animated: true)
                } else if case .success(let uri) = ETHURI.parser(string: result) {
                    self.addressView.textView.text = uri.address
                    scanViewController.navigationController?.popViewController(animated: true)
                } else {
                    scanViewController.showAlertMessage(result)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(scanViewController, animated: true)
        }.disposed(by: rx.disposeBag)
    }

    func showDeleteButton() {
        let view = UIView()
        let deleteButton = UIButton().then {
            $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.setTitle(R.string.localizable.contactsEditPageDeleteButtonTitle(), for: .normal)
        }
        let separatorLine = UIView()

        view.addSubview(deleteButton)
        view.addSubview(separatorLine)

        deleteButton.snp.makeConstraints { (m) in
            m.top.bottom.left.equalTo(view)
            m.height.equalTo(50)
        }

        separatorLine.backgroundColor = Colors.lineGray
        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.right.equalTo(view)
            m.bottom.equalTo(view)
        }

        scrollableView.stackView.addArrangedSubview(view)

        deleteButton.rx.tap.bind { [weak self] in
            Alert.show(title: R.string.localizable.contactsEditPageDeleteAlertTitle(), message: nil, actions: [
                (.cancel, nil),
                (.default(title: R.string.localizable.confirm()), { [weak self] alert in
                    guard let id = self?.contact?.id else { return }
                    AddressManageService.instance.removeContact(forId: id)
                    self?.navigationController?.popViewController(animated: true)
                }),
                ])
        }.disposed(by: rx.disposeBag)
    }
}
