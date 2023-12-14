//
//  AboutUsViewController.swift
//  Vite
//
//  Created by Water on 2018/9/17.
//  Copyright © 2018年 vite labs. All rights reserved.
//
import UIKit
import ViteWallet
import Eureka
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import MessageUI
import Vite_HDWalletKit

class AboutUsViewController: FormViewController {
    var navigationBarStyle = NavigationBarStyle.default

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self._setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NavigationBarStyle.configStyle(navigationBarStyle, viewController: self)
    }

    lazy var logoImgView: UIImageView = {
        let logoImgView = UIImageView()
        logoImgView.backgroundColor = .clear
        logoImgView.image =  R.image.aboutus_logo()
        return logoImgView
    }()
}

extension AboutUsViewController {

    private func _setupView() {
        setupTableView()
    }

    func setupTableView() {
        self.tableView.backgroundColor = .white
        self.tableView.separatorStyle = .none

        LabelRow.defaultCellSetup = { cell, row in
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins.left = 24
            cell.layoutMargins.right = 24
            cell.selectionStyle = .none
        }

        ImageRow.defaultCellSetup = { cell, row in
            cell.selectionStyle = .none
            cell.textLabel?.font = Fonts.light16
            cell.textLabel?.textColor = Colors.cellTitleGray
        }

        let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 176))
        headerView.addSubview(logoImgView)
        logoImgView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView).offset(30)
            make.centerX.equalTo(headerView)
            make.width.equalTo(82)
            make.height.equalTo(116)
        }
        self.tableView.tableHeaderView = headerView
        self.tableView.alwaysBounceVertical = false
        let bottomView = AboutUsTableBottomView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 295) )
        self.tableView.tableFooterView = bottomView

        form +++
            Section {
                $0.header = HeaderFooterView<UIView>(.class)
                $0.header?.height = { 0.0 }
            }

            <<< LabelRow("aboutUsPageCellBlockHeight") {
                $0.cell.textLabel?.textColor = Colors.cellTitleGray
                $0.cell.textLabel?.font = Fonts.light16
                $0.title =  R.string.localizable.aboutUsPageCellBlockHeight()
                $0.value = R.string.localizable.aboutUsPageCellBlockHeightLoadingTip()
                $0.cell.height = { 60 }
                $0.cell.bottomSeparatorLine.isHidden = false
            }.onCellSelection({ _, _  in
                })

            <<< LabelRow("aboutUsPageCellVersion") {
                $0.cell.textLabel?.textColor = Colors.cellTitleGray
                $0.cell.textLabel?.font = Fonts.light16
                $0.title =  R.string.localizable.aboutUsPageCellVersion()
                var prefix = ""
                #if DEBUG
                prefix = prefix + "D"
                #endif
                #if TEST
                prefix = prefix + "T"
                #endif
                #if OFFICIAL
                prefix = prefix + "A"
                #endif

                $0.value = "\(Bundle.main.versionNumber) (\(prefix)\(Bundle.main.buildNumber))"
                $0.cell.height = { 60 }
                $0.cell.bottomSeparatorLine.isHidden = false
            }.onCellSelection({ _, _  in
                })

            <<< ImageRow("aboutUsPageCellContact") {
                $0.cell.titleLab.text =  R.string.localizable.aboutUsPageCellContact()
                $0.cell.rightImageView.image = R.image.icon_right_white()?.tintColor(Colors.titleGray).resizable
            }.onCellSelection({ [unowned self] _, _  in
                self.sendUsEmail()
                })

        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuideSnpTop)
            make.left.right.bottom.equalTo(self.view)
        }

        getSnapshotChainHeight()
        Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance).bind { [weak self] _ in self?.getSnapshotChainHeight() }.disposed(by: rx.disposeBag)
    }

    func getSnapshotChainHeight() {
        GetSnapshotChainHeightRequest().defaultProviderPromise
            .done { [weak self] (height) in
                guard let `self` = self else { return }
                guard let cell = self.form.rowBy(tag: "aboutUsPageCellBlockHeight") as? LabelRow else { return }
                cell.value = String(height)
                cell.updateCell()
        }
    }

    func sendUsEmail() {
        let composerController = MFMailComposeViewController()
        composerController.mailComposeDelegate = self
        composerController.setToRecipients([Constants.supportEmail])
        composerController.setSubject(R.string.localizable.aboutUsPageEmailTitle())
        composerController.setMessageBody(emailTemplate(), isHTML: false)

        if MFMailComposeViewController.canSendMail() {
            present(composerController, animated: true, completion: nil)
        } else {
            if #available(iOS 13.1, *) {
                Toast.show("can not send mail")
            }
        }
    }
    private func emailTemplate() -> String {

        return   R.string.localizable.aboutUsPageEmailContent(UIDevice.current.systemVersion, UIDevice.current.model, Bundle.main.fullVersion, Locale.preferredLanguages.first ?? "")
    }
}

extension AboutUsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
