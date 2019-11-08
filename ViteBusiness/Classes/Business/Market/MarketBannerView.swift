//
//  MarketBannerView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/8.
//

import FSPagerView

class MarketBannerCell: FSPagerViewCell {

    let bannerView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bannerView)
        bannerView.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class MarketBannerView: UIView {
    let pagerView = FSPagerView()
    var items = [MarketBannerItem]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(pagerView)
        pagerView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.bottom.equalToSuperview()
            m.height.equalTo((kScreenW-48)*282/981)
        }

        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.automaticSlidingInterval = 3.0
        pagerView.register(MarketBannerCell.self, forCellWithReuseIdentifier: "MarketBannerCell")

        AppContentService.instance.storageDriver.map { $0.marketBannerItems }.drive(onNext: { [weak self] (items) in
            guard let `self` = self else { return }
            self.items = items
            self.pagerView.isInfinite = items.count > 1
            self.pagerView.reloadData()
        }).disposed(by: rx.disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MarketBannerView: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return items.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "MarketBannerCell", at: index) as! MarketBannerCell
        cell.bannerView.kf.cancelDownloadTask()
        cell.bannerView.kf.setImage(with: URL(string: items[index].imageUrl), placeholder: UIImage.color(UIColor(netHex: 0xF8F8F8)))
        return cell
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let item = items[index]

        guard item.linkUrl != "", let url = URL(string: item.linkUrl) else {
            return
        }
        let vc = WKWebViewController("", url: url)
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
    }
}
