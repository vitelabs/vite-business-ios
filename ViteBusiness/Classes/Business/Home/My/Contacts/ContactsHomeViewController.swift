//
//  ContactsHomeViewController.swift
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
import SnapKit
import DNSPageView

class ContactsHomeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    private var contentView: UIView?
    private var emptyView: UIView?

    fileprivate func setupView() {
        navigationTitleView = NavigationTitleView(title: R.string.localizable.contactsHomePageTitle())
        let item = UIBarButtonItem(image: R.image.icon_nav_add(), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            self?.navigationController?.pushViewController(ContactsEditViewController(contact: nil), animated: true)
        }.disposed(by: rx.disposeBag)
    }

    func bind() {
        AddressManageService.instance.contactsDriver.map({ $0.count > 0 }).drive(onNext: { [weak self] has in
            self?.showContentView(isShow: has)
            self?.showEmptyView(isShow: !has)
        }).disposed(by: rx.disposeBag)
    }

    func showContentView(isShow: Bool) {
        if isShow {
            if contentView == nil {
                let view = UIView()
                self.view.addSubview(view)
                view.snp.makeConstraints({ (m) in
                    m.top.equalTo(navigationTitleView!.snp.bottom)
                    m.left.right.bottom.equalToSuperview()
                })

                let pageStyle = DNSPageStyle()
                pageStyle.isShowBottomLine = true
                pageStyle.isTitleViewScrollEnabled = true
                pageStyle.titleViewBackgroundColor = .white
                pageStyle.titleSelectedColor = Colors.titleGray
                pageStyle.titleColor = Colors.titleGray_61
                pageStyle.titleFont = Fonts.Font13
                pageStyle.bottomLineColor = Colors.blueBg
                pageStyle.bottomLineHeight = 3

                let titles = [
                    R.string.localizable.contactsHomePageFilterAll(),
                    "VITE",
                    "ETH"
                ]

                let viewControllers = [
                    ContactsListViewController(viewModel:ContactsListViewModel(contactsDriver: AddressManageService.instance.contactsDriver)),
                    ContactsListViewController(viewModel:ContactsListViewModel(contactsDriver: AddressManageService.instance.contactsDriver(for: .vite))),
                    ContactsListViewController(viewModel:ContactsListViewModel(contactsDriver: AddressManageService.instance.contactsDriver(for: .eth)))
                ]

                let manager = DNSPageViewManager(style: pageStyle, titles: titles, childViewControllers: viewControllers)

                let shadowView = UIView().then {
                    $0.backgroundColor = UIColor.white
                    $0.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
                    $0.layer.shadowOpacity = 0.1
                    $0.layer.shadowOffset = CGSize(width: 0, height: 5)
                    $0.layer.shadowRadius = 20
                }

                view.addSubview(manager.contentView)
                view.addSubview(shadowView)
                shadowView.addSubview(manager.titleView)

                manager.titleView.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview().offset(9)
                    make.right.equalToSuperview().offset(-9)
                    make.bottom.equalToSuperview().offset(-6)
                    make.height.equalTo(35)
                }

                shadowView.snp.makeConstraints { (make) in
                    make.top.left.right.equalToSuperview()
                }

                manager.contentView.snp.makeConstraints { (make) in
                    make.top.equalTo(shadowView.snp.bottom)
                    make.left.right.equalToSuperview()
                    make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
                }

                contentView = view
            }
        }
        contentView?.isHidden = !isShow
    }

    func showEmptyView(isShow: Bool) {
        if isShow {
            if emptyView == nil {
                let view = UIView()
                view.backgroundColor = UIColor.white

                self.view.addSubview(view)
                view.snp.makeConstraints({ (m) in
                    m.edges.equalToSuperview()
                })

                let imageView = UIImageView(image: R.image.icon_contacts_empty())
                let label = UILabel().then {
                    $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                    $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
                    $0.text = R.string.localizable.contactsHomePageNoContactTip()
                }

                let button = UIButton(style: .blue, title: R.string.localizable.contactsHomePageAddButtonTitle())

                view.addSubview(imageView)
                view.addSubview(label)
                view.addSubview(button)

                imageView.snp.makeConstraints({ (m) in
                    m.centerX.equalToSuperview()
                    m.centerY.equalToSuperview().offset(-60)
                })

                label.snp.makeConstraints({ (m) in
                    m.top.equalTo(imageView.snp.bottom).offset(20)
                    m.centerX.equalTo(imageView)
                })

                button.snp.makeConstraints({ (m) in
                    m.left.equalToSuperview().offset(24)
                    m.right.equalToSuperview().offset(-24)
                    m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
                })

                button.rx.tap.bind { [weak self] in
                    self?.navigationController?.pushViewController(ContactsEditViewController(contact: nil), animated: true)

                    }.disposed(by: rx.disposeBag)
                emptyView = view
            }
        }
        emptyView?.isHidden = !isShow
    }
}
