//
//  ETHTransactionDetailViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/27.
//

import Foundation

class ETHTransactionDetailViewController: BaseViewController {

    let transaction: ETHTransaction
    init(transaction: ETHTransaction) {
        self.transaction = transaction
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

    let headerImageView = UIImageView(image: R.image.icon_eth_detail_success())
    let etherscanButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.setTitle(R.string.localizable.ethTransactionDetailGoButtonTitle(), for: .normal)
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

        let statusLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59)
        }

        let timeLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
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

        statusLabel.text = R.string.localizable.ethTransactionDetailSuccess()
        timeLabel.text = transaction.timeStamp.format("yyyy.MM.dd HH:mm:ss")


        let toAddressView = AddressView(title: R.string.localizable.ethTransactionDetailToAddress(), address: transaction.toAddress, showLine: true)
        let fromAddressView = AddressView(title: R.string.localizable.ethTransactionDetailFromAddress(), address: transaction.fromAddress, showLine: false)

        let amountView = TitleValueView(title: R.string.localizable.ethTransactionDetailAmount(), value: transaction.amount.amountShortWithGroupSeparator(decimals: transaction.tokenInfo.decimals), unit: transaction.tokenInfo.symbol)
        let gasView = TitleValueView(title: R.string.localizable.ethTransactionDetailGas(), value: (transaction.gasUsed*transaction.gasPrice).amountFullWithGroupSeparator(decimals: TokenInfo.BuildIn.eth.value.decimals), unit: TokenInfo.BuildIn.eth.value.symbol)
        let hashView = HashView(title: R.string.localizable.ethTransactionDetailHash(), value: transaction.hash)
        let blockView = TitleValueView(title: R.string.localizable.ethTransactionDetailBlock(), value: transaction.blockNumber, unit: nil)

        scrollView.stackView.addArrangedSubview(toAddressView)
        scrollView.stackView.addArrangedSubview(fromAddressView)
        scrollView.stackView.addArrangedSubview(amountView)
        scrollView.stackView.addArrangedSubview(gasView)
        scrollView.stackView.addArrangedSubview(hashView)
        scrollView.stackView.addArrangedSubview(blockView)

        if transaction.tokenInfo.isEtherCoin && transaction.input.count > 2 {
            let noteView = NoteView(input: transaction.input)
            scrollView.stackView.addArrangedSubview(noteView)
        }
    }

    fileprivate func bind() {
        etherscanButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            var url = URL(string: "\(ViteConst.instance.eth.explorer)/tx/\(self.transaction.hash)")!
            let vc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)
    }

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

            titleLabel.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview().inset(10)
                m.left.equalToSuperview().offset(20)
            }

            if let unit = unit {
                unitLabel.text = unit
                addSubview(unitLabel)

                unitLabel.snp.makeConstraints { (m) in
                    m.centerY.equalToSuperview()
                    m.right.equalToSuperview().inset(20)
                }

                valueLabel.snp.makeConstraints { (m) in
                    m.centerY.equalToSuperview()
                    m.right.equalTo(unitLabel.snp.left).inset(-8)
                }
            } else {
                valueLabel.snp.makeConstraints { (m) in
                    m.centerY.equalToSuperview()
                    m.right.equalToSuperview().inset(20)
                }
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class HashView: UIView {

        private let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        }

        private let valueLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.textAlignment = .right
        }

        private let copyButton = UIButton().then {
            $0.setImage(R.image.icon_button_paste_light_gray(), for: .normal)
            $0.setImage(R.image.icon_button_paste_light_gray()?.highlighted, for: .highlighted)
        }

        init(title: String, value: String) {
            super.init(frame: .zero)

            titleLabel.text = title
            valueLabel.text = "\(value.prefix(8))...\(value.suffix(6))"

            addSubview(titleLabel)
            addSubview(valueLabel)
            addSubview(copyButton)

            titleLabel.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview().inset(10)
                m.left.equalToSuperview().offset(20)
            }

            valueLabel.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
            }

            let vLine = UIView().then {
                $0.backgroundColor = UIColor(netHex: 0xe5e5ea)
            }

            addSubview(vLine)
            vLine.snp.makeConstraints { (m) in
                m.width.equalTo(CGFloat.singleLineWidth)
                m.left.equalTo(valueLabel.snp.right).offset(20)
                m.right.equalToSuperview().offset(-50)
                m.top.equalToSuperview().offset(10)
                m.bottom.equalToSuperview().offset(-10)
            }

            copyButton.snp.makeConstraints { (m) in
                m.top.bottom.right.equalToSuperview()
                m.width.equalTo(60)
            }

            copyButton.rx.tap.bind {
                UIPasteboard.general.string = value
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

        init(input: String) {
            super.init(frame: .zero)

            titleLabel.text = R.string.localizable.ethTransactionDetailNote()
            let bytes = input.hex2Bytes
            if bytes.count > 0, let note = String(bytes: bytes, encoding: .utf8) {
                valueLabel.text = note
            } else {
                valueLabel.text = input
            }

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
