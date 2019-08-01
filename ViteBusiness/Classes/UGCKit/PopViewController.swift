//
//  PopViewController.swift
//  Vite
//
//  Created by Water on 2018/10/29.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import WebKit

class PopViewController: BaseViewController {
    let htmlString: String
    weak var delegate: QuotaSubmitPopViewControllerDelegate?

    init(htmlString: String) {
        self.htmlString = htmlString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        initBinds()
        label.attributedText = htmlString.htmlToAttributedString
    }

    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
    }

    lazy var bgView = UIView().then {
        $0.backgroundColor = .white
        $0.setupShadow(CGSize(width: 0, height: 5))
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 18, left: 24, bottom: 0, right: 24)).then {
        $0.stackView.spacing = 10
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        $0.stackView.addArrangedSubview(self.label)
    }

    lazy var label = UILabel().then {
        $0.numberOfLines = 0
    }

    lazy var cancelBtn = UIButton(style: .whiteWithShadow, title: R.string.localizable.close())

    func setupView() {
        self.navigationController?.view.backgroundColor = .clear
        self.view.backgroundColor = .clear

        view.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.left.equalTo(view).offset(52)
            make.right.equalTo(view).offset(-52)
            make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuideSnpTop).offset(80)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuideSnpBottom).offset(-80)
        }

        bgView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (m) in
            m.left.right.equalTo(bgView)
            m.top.equalTo(bgView)
        }

        bgView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (m) in
            m.left.right.equalTo(bgView)
            m.top.equalTo(scrollView.snp.bottom)
            m.bottom.equalTo(bgView)
            m.height.equalTo(50)
        }

        let lineView = LineView.init(direction: .horizontal)
        cancelBtn.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(cancelBtn)
            make.height.equalTo(1)
        }
    }

    func initBinds() {
        self.cancelBtn.rx.tap
            .bind { [weak self] in
                self?.dismiss()
            }.disposed(by: rx.disposeBag)
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString.string ?? ""
    }
}
