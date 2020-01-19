//
//  BaseScrollableViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/4.
//

import UIKit

class BaseScrollableViewController: BaseViewController {


    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)) {
        self.insets = insets
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var scrollView = ScrollableView(insets: self.insets).then {
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    override var navigationTitleView: UIView? {
        didSet { layoutTableView() }
    }

    override var customHeaderView: UIView? {
        didSet { layoutTableView() }
    }

    private func layoutTableView() {
        if let customHeaderView = customHeaderView {
            scrollView.snp.remakeConstraints { (m) in
                m.top.equalTo(customHeaderView.snp.bottom)
                m.left.right.bottom.equalTo(view)
            }
        } else if let navigationTitleView = navigationTitleView {
            scrollView.snp.remakeConstraints { (m) in
                m.top.equalTo(navigationTitleView.snp.bottom)
                m.left.right.bottom.equalTo(view)
            }
        } else {
            scrollView.snp.remakeConstraints { (m) in
                m.edges.equalTo(view)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        layoutTableView()
    }
}
