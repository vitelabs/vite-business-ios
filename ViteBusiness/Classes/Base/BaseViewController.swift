//
//  BaseViewController.swift
//  Vite
//
//  Created by Stone on 2018/8/27.
//  Copyright © 2018年 Vite. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

open class BaseViewController: UIViewController {

    var statisticsPageName: String?
    open var automaticallyShowDismissButton: Bool = true
    var navigationBarStyle = NavigationBarStyle.default
    open var navigationTitleView: UIView? {
        didSet {
            if let old = oldValue {
                old.removeFromSuperview()
            }

            if let new = navigationTitleView {
                view.addSubview(new)
            }

            layoutNavigationTitleViewAndCustomHeaderView()
        }
    }

    var customHeaderView: UIView? {
        didSet {
            if let old = oldValue {
                old.removeFromSuperview()
            }

            if let new = customHeaderView {
                view.addSubview(new)
            }

            layoutNavigationTitleViewAndCustomHeaderView()
        }
    }

    private func layoutNavigationTitleViewAndCustomHeaderView() {

        if let navigationTitleView = navigationTitleView {
            navigationTitleView.snp.remakeConstraints { (m) in
                m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
                m.left.equalTo(view)
                m.right.equalTo(view)
            }

            if let customHeaderView = customHeaderView {
                customHeaderView.snp.remakeConstraints { (m) in
                    m.top.equalTo(navigationTitleView.snp.bottom)
                    m.left.equalTo(view)
                    m.right.equalTo(view)
                }
            }
        } else {
            if let customHeaderView = customHeaderView {
                customHeaderView.snp.remakeConstraints { (m) in
                    m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
                    m.left.equalTo(view)
                    m.right.equalTo(view)
                }
            }
        }
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        if navigationController?.viewControllers.first === self && automaticallyShowDismissButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.icon_nav_back_black(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(_onCancel))
        }
    }

    @objc fileprivate func _onCancel() {
        dismiss(animated: true, completion: nil)
    }

    func dismiss() {
        if navigationController == nil || navigationController?.viewControllers.first === self {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationTitleView = navigationTitleView {
            view.bringSubviewToFront(navigationTitleView)
        }
        NavigationBarStyle.configStyle(navigationBarStyle, viewController: self)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let name = statisticsPageName {
            Statistics.pageviewStart(with: name)
        }
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let name = statisticsPageName {
            Statistics.pageviewEnd(with: name)
        }
    }
}
