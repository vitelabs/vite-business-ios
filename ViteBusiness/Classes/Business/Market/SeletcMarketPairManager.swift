//
//  SeletcMarketPairManager.swift
//  Action
//
//  Created by haoshenyang on 2019/10/17.
//

import UIKit

open class SeletcMarketPairManager {

    public static let shared = SeletcMarketPairManager()

    var card: SeletcMarketPairCard!
    var carNav: UINavigationController!
    var searchVC: MarketSearchViewController!
    var background: UIView!

    public func showCard() {
        if card == nil {
            card = SeletcMarketPairCard()
        }
        if background == nil {
            background = UIView()
            background.backgroundColor = UIColor.init(netHex: 0x000000, alpha: 0.25)
        }
        if carNav == nil {
            carNav = UINavigationController.init(rootViewController: card)
        }

        UIApplication.shared.keyWindow?.addSubview(background)
       background.addSubview(carNav.view)
        background.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
       carNav.view.snp.makeConstraints { (m) in
           m.left.right.bottom.equalToSuperview()
           m.height.equalTo(600)
       }

        
    }

    @objc public  func closeCard() {
        self.hideCard()
    }

    @objc public  func hideCard() {
        self.card?.navigationController?.view.removeFromSuperview()
        self.background?.removeFromSuperview()
    }

    @objc public  func showSearch() {
        hideCard()
        if searchVC == nil {
            searchVC = MarketSearchViewController()
        }
        searchVC.originalData = Array(self.card.marketVM.sortedMarketDataBehaviorRelay.value.dropFirst())

        let returnButton = UIButton()
        returnButton.setBackgroundImage(R.image.icon_nav_back_black(), for: .normal)
        searchVC.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: returnButton)
        returnButton
            .rx.tap.bind {[unowned self] _ in
                self.searchVC.navigationController?.popViewController(animated: false)
                self.showCard()
        }

        self.searchVC.onSelectInfo = { [weak self] info in
            SeletcMarketPairManager.shared.searchVC?.navigationController?.popViewController(animated: false)
            SeletcMarketPairManager.shared.closeCard()
            self?.onSelectInfo?(info)
            self?.searchVC = nil
        }
        UIViewController.current?.navigationController?.pushViewController(searchVC, animated: true)
    }

    open var onSelectInfo: ((MarketInfo) -> ())?

}
