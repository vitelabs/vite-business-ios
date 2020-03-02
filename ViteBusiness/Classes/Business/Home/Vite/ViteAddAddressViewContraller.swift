//
//  ViteAddAddressViewContraller.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/2.
//

import Foundation

class ViteAddAddressViewContraller: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    // View
    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)).then {
        $0.layer.masksToBounds = false
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    let singleTextField = UnderlineTextFieldView().then {
        $0.textField.placeholder = R.string.localizable.viteAddAddressSinglePlaceholder()
        $0.textField.keyboardType = .numberPad
    }

    let fromTextField = UnderlineTextFieldView().then {
        $0.textField.textAlignment = .center
        $0.textField.keyboardType = .numberPad
    }
    let toTextField = UnderlineTextFieldView().then {
        $0.textField.textAlignment = .center
        $0.textField.keyboardType = .numberPad
    }

    let addButton = UIButton(style: .blue, title: R.string.localizable.viteAddAddressAddButtonTitile())

    fileprivate func setupView() {
        navigationTitleView = NavigationTitleView(title: R.string.localizable.viteAddAddressPageTitle())

        let singleTitleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.text = R.string.localizable.viteAddAddressSingleTitle()
        }

        let batchTitleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.text = R.string.localizable.viteAddAddressBatchTitle()
        }

        let batchPlaceholderTitleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.text = R.string.localizable.viteAddAddressBatchPlaceholder()
        }

        let toLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.text = R.string.localizable.viteAddAddressBatchTo()
        }

        let batchView = UIView().then {
            $0.addSubview(fromTextField)
            $0.addSubview(toLabel)
            $0.addSubview(toTextField)

            fromTextField.snp.makeConstraints { (m) in
                m.top.left.bottom.equalToSuperview()
                m.width.equalTo(70)
            }

            toLabel.snp.makeConstraints { (m) in
                m.left.equalTo(fromTextField.snp.right)
                m.bottom.equalToSuperview()
            }

            toTextField.snp.makeConstraints { (m) in
                m.left.equalTo(toLabel.snp.right)
                m.bottom.equalToSuperview()
                m.width.equalTo(70)
            }
        }

        view.addSubview(scrollView)
        view.addSubview(addButton)

        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom).offset(10)
            m.left.right.equalToSuperview()
        }

        addButton.snp.makeConstraints { (m) in
            m.top.equalTo(scrollView.snp.bottom)
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalTo(self.view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }

        scrollView.stackView.addArrangedSubview(singleTitleLabel)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(singleTextField)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(batchTitleLabel)
        scrollView.stackView.addPlaceholder(height: 8)
        scrollView.stackView.addArrangedSubview(batchPlaceholderTitleLabel)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(batchView)

        singleTextField.textField.kas_setReturnAction(.resignFirstResponder)
        fromTextField.textField.kas_setReturnAction(.next(responder: toTextField.textField))
        toTextField.textField.kas_setReturnAction(.resignFirstResponder)
    }

    fileprivate func bind() {
        addButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            if self.singleTextField.textField.text?.isEmpty ?? true {
                guard let from = self.fromTextField.textField.text,
                    let to = self.toTextField.textField.text,
                    let fromIndex = Int(from), let toIndex = Int(to),
                    fromIndex >= 0, fromIndex <= 100, toIndex >= 0, toIndex <= 100 else {
                            Toast.show(R.string.localizable.viteAddAddressErrorToast())
                            return
                }
                _ = HDWalletManager.instance.generateAccounts(from: fromIndex, to: toIndex)
                self.navigationController?.popViewController(animated: true)
            } else {
                guard let from = self.singleTextField.textField.text,
                    let fromIndex = Int(from), fromIndex >= 0, fromIndex <= 100 else {
                        Toast.show(R.string.localizable.viteAddAddressErrorToast())
                        return
                }
                let toIndex = fromIndex
                _ = HDWalletManager.instance.generateAccounts(from: fromIndex, to: toIndex)
                self.navigationController?.popViewController(animated: true)
            }
        }.disposed(by: rx.disposeBag)
    }

}
