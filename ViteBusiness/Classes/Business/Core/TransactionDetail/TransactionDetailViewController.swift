//
//  TransactionDetailViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/27.
//

import Foundation

class TransactionDetailViewController: BaseViewController {

    let holder: TransactionDetailHolder
    var vm: TransactionDetailHolder.ViewModel? = nil
    init(holder: TransactionDetailHolder) {
        self.holder = holder
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    let headerImageView = UIImageView()

    let statusLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
    }

    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
    }

    let etherscanButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)).then {
        $0.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    fileprivate func setupView() {
        navigationTitleView = NavigationTitleView(title: R.string.localizable.ethTransactionDetailPageTitle())

        let shadowView = UIView().then {
            $0.backgroundColor = nil
            $0.layer.shadowColor = UIColor(netHex: 0x000000, alpha: 0.1).cgColor
            $0.layer.shadowOpacity = 1
            $0.layer.shadowOffset = CGSize(width: 0, height: 0)
            $0.layer.shadowRadius = 5
        }

        let whiteView = UIView().then {
            $0.backgroundColor = UIColor.white
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 2
        }

        view.addSubview(shadowView)
        shadowView.addSubview(whiteView)
        view.addSubview(scrollView)
        view.addSubview(headerImageView)
        view.addSubview(etherscanButton)

        shadowView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom).offset(40)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalTo(self.view.safeAreaLayoutGuideSnpBottom).offset(-59)
        }

        whiteView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(shadowView).offset(98)
            m.left.right.bottom.equalTo(shadowView)
        }

        headerImageView.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.centerY.equalTo(shadowView.snp.top)
        }

        etherscanButton.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(shadowView.snp.bottom).offset(17)
        }

        view.addSubview(statusLabel)
        view.addSubview(timeLabel)

        statusLabel.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(headerImageView.snp.bottom).offset(10)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(statusLabel.snp.bottom).offset(10)
        }
    }

    fileprivate func bind() {

        holder.bind { [weak self] (state) in
            guard let `self` = self else { return }
            switch state {
            case .loading:
                self.dataStatus = .loading
            case .success(let vm):
                self.vm = vm
                self.dataStatus = .normal

                self.headerImageView.image = vm.headerImage
                self.statusLabel.text = vm.stateString
                self.timeLabel.text = vm.timeString
                self.etherscanButton.setTitle(vm.link.text, for: .normal)

                self.scrollView.stackView.arrangedSubviews.forEach {
                    self.scrollView.stackView.removeArrangedSubview($0)
                }

                vm.items.forEach { (item) in
                    let view: UIView
                    switch item {
                    case let .address(title, text, hasSeparator):
                        view = AddressView(title: title, address: text, showLine: hasSeparator)
                    case let .ammount(title, text, symbol):
                        view = TitleValueView(title: title, value: text, unit: symbol)
                    case let .copyable(title, text, rawText):
                        view = CopyableView(title: title, value: text, rawText: rawText)
                    case let .height(title, text):
                        view = TitleValueView(title: title, value: text, unit: nil)
                    case let .note(title, text):
                        view = NoteView(title: title, text: text)
                    }
                    self.scrollView.stackView.addArrangedSubview(view)
                }

            case .failed(let error, let block):
                self.dataStatus = .networkError(error, block)
            }
        }

        etherscanButton.rx.tap.bind { [weak self] in
            guard let url = self?.vm?.link.url else { return }
            let vc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)
    }
}
extension TransactionDetailViewController: ViewControllerDataStatusable {
    func networkErrorView(error: Error, retry: @escaping () -> Void) -> UIView {
        return UIView.defaultNetworkErrorView(error: error, retry: retry)
    }
}
extension TransactionDetailViewController {

    class AddressView: UIView {

        private let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        }

        private let addressLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.numberOfLines = 2
        }

        private let copyButton = UIButton().then {
            $0.setImage(R.image.icon_button_paste_light_gray(), for: .normal)
            $0.setImage(R.image.icon_button_paste_light_gray()?.highlighted, for: .highlighted)
        }

        init(title: String, address: String, showLine: Bool) {
            super.init(frame: .zero)

            backgroundColor = UIColor(netHex: 0xF1F8FF)

            addSubview(titleLabel)
            addSubview(addressLabel)
            addSubview(copyButton)

            titleLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(10)
                m.left.equalToSuperview().offset(20)
            }

            addressLabel.snp.makeConstraints { (m) in
                m.top.equalTo(titleLabel.snp.bottom).offset(4)
                m.left.equalToSuperview().offset(20)
                m.bottom.equalToSuperview().offset(-10)
            }

            let vLine = UIView().then {
                $0.backgroundColor = UIColor(netHex: 0xe5e5ea)
            }

            addSubview(vLine)
            vLine.snp.makeConstraints { (m) in
                m.width.equalTo(CGFloat.singleLineWidth)
                m.left.equalTo(addressLabel.snp.right).offset(10)
                m.right.equalToSuperview().offset(-50)
                m.top.equalToSuperview().offset(10)
                m.bottom.equalToSuperview().offset(-10)
            }

            copyButton.snp.makeConstraints { (m) in
                m.top.bottom.right.equalToSuperview()
                m.width.equalTo(60)
            }

            let hLine = UIImageView(image: R.image.dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

            addSubview(hLine)
            hLine.snp.makeConstraints { (m) in
                m.bottom.equalToSuperview()
                m.left.right.equalToSuperview().inset(20)
            }

            titleLabel.text = title
            addressLabel.text = address
            hLine.isHidden = !showLine

            copyButton.rx.tap.bind {
                UIPasteboard.general.string = address
                Toast.show(R.string.localizable.walletHomeToastCopyAddress(), duration: 1.0)
            }.disposed(by: rx.disposeBag)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class TitleValueView: UIView {

        private let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        }

        private let valueLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.textAlignment = .right
        }

        private let unitLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        }

        init(title: String, value: String, unit: String?) {
            super.init(frame: .zero)

            titleLabel.text = title
            valueLabel.text = value

            addSubview(titleLabel)
            addSubview(valueLabel)

            titleLabel.setContentHuggingPriority(.required, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            titleLabel.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview().inset(10)
                m.left.equalToSuperview().offset(20)
            }

            if let unit = unit {
                unitLabel.text = unit
                addSubview(unitLabel)

                unitLabel.setContentHuggingPriority(.required, for: .horizontal)
                unitLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
                unitLabel.snp.makeConstraints { (m) in
                    m.centerY.equalToSuperview()
                    m.right.equalToSuperview().inset(20)
                }

                valueLabel.snp.makeConstraints { (m) in
                    m.centerY.equalToSuperview()
                    m.left.equalTo(titleLabel.snp.right).offset(8)
                    m.right.equalTo(unitLabel.snp.left).offset(-8)
                }
            } else {
                valueLabel.snp.makeConstraints { (m) in
                    m.centerY.equalToSuperview()
                    m.left.equalTo(titleLabel.snp.right).offset(8)
                    m.right.equalToSuperview().inset(20)
                }
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class CopyableView: UIView {

        private let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        }

        private let valueLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.textAlignment = .right
            $0.lineBreakMode = .byTruncatingMiddle
        }

        private let copyButton = UIButton().then {
            $0.setImage(R.image.icon_button_paste_light_gray(), for: .normal)
            $0.setImage(R.image.icon_button_paste_light_gray()?.highlighted, for: .highlighted)
        }

        init(title: String, value: String, rawText: String) {
            super.init(frame: .zero)

            titleLabel.text = title
            valueLabel.text = value

            addSubview(titleLabel)
            addSubview(valueLabel)
            addSubview(copyButton)

            titleLabel.setContentHuggingPriority(.required, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            titleLabel.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview().inset(10)
                m.left.equalToSuperview().offset(20)
            }

            valueLabel.snp.makeConstraints { (m) in
                m.left.equalTo(titleLabel.snp.right).offset(8)
                m.centerY.equalToSuperview()
            }

            let vLine = UIView().then {
                $0.backgroundColor = UIColor(netHex: 0xe5e5ea)
            }

            addSubview(vLine)
            vLine.snp.makeConstraints { (m) in
                m.width.equalTo(CGFloat.singleLineWidth)
                m.left.equalTo(valueLabel.snp.right).offset(10)
                m.right.equalToSuperview().offset(-50)
                m.top.equalToSuperview().offset(10)
                m.bottom.equalToSuperview().offset(-10)
            }

            copyButton.snp.makeConstraints { (m) in
                m.top.bottom.right.equalToSuperview()
                m.width.equalTo(60)
            }

            copyButton.rx.tap.bind {
                UIPasteboard.general.string = rawText
                Toast.show(R.string.localizable.walletHomeToastCopyAddress(), duration: 1.0)
            }.disposed(by: rx.disposeBag)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class NoteView: UIView {

        private let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        }

        private let valueLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.numberOfLines = 0
        }

        init(title: String, text: String) {
            super.init(frame: .zero)

            titleLabel.text = title
            valueLabel.text = text

            addSubview(titleLabel)
            addSubview(valueLabel)

            titleLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().inset(10)
                m.left.equalToSuperview().offset(20)
            }

            valueLabel.snp.makeConstraints { (m) in
                m.top.equalTo(titleLabel.snp.bottom).offset(10)
                m.left.right.equalToSuperview().inset(20)
                m.bottom.equalToSuperview().inset(10)
            }

        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    
}
