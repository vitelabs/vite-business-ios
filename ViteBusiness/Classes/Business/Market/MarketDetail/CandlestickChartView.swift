//
//  CandlestickChartView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit
import LightweightCharts
import Charts
import RxSwift
import RxCocoa


class CandlestickChartView: UIView {

    var kineTypeBehaviorRelay: BehaviorRelay<MarketKlineType>

    let headerView = HeaderView()
    let selectorView = SelectorView()

    let combinedChartView = CombinedChartView().then {

        $0.chartDescription?.enabled = false
        $0.pinchZoomEnabled = false
        $0.drawGridBackgroundEnabled = true
        $0.doubleTapToZoomEnabled = false
        $0.scaleXEnabled = false
        $0.scaleYEnabled = false
        $0.leftAxis.enabled = false
        $0.legend.enabled = false
        $0.autoScaleMinMaxEnabled = true
        $0.maxVisibleCount = 0
        $0.backgroundColor = .clear
        $0.gridBackgroundColor = .clear
        $0.noDataText = ""


        $0.xAxis.enabled = false
        $0.xAxis.labelPosition = .bottom
        $0.xAxis.drawGridLinesEnabled = false
        $0.xAxis.labelFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.xAxis.labelTextColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)

        $0.rightAxis.labelCount = 4
        $0.rightAxis.drawGridLinesEnabled = false
        $0.rightAxis.drawAxisLineEnabled = false
        $0.rightAxis.labelPosition = .insideChart
        $0.rightAxis.labelFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.rightAxis.labelTextColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)

    }

    let barChartView = BarChartView().then {
        $0.chartDescription?.enabled = false
        $0.pinchZoomEnabled = false
        $0.drawGridBackgroundEnabled = true
        $0.doubleTapToZoomEnabled = false
        $0.scaleXEnabled = false
        $0.scaleYEnabled = false
        $0.leftAxis.enabled = false
        $0.legend.enabled = false
        $0.autoScaleMinMaxEnabled = true
        $0.maxVisibleCount = 0
        $0.backgroundColor = .clear
        $0.gridBackgroundColor = .clear
        $0.noDataText = ""


        $0.xAxis.labelPosition = .bottom
        $0.xAxis.drawGridLinesEnabled = false
        $0.xAxis.labelFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.xAxis.labelTextColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)


        $0.leftAxis.enabled = false
        $0.rightAxis.enabled = false
    }

    init(klineType: MarketKlineType) {
        self.kineTypeBehaviorRelay = BehaviorRelay(value: klineType)
        super.init(frame: .zero)

        combinedChartView.delegate = self
        barChartView.delegate = self

        addSubview(headerView)
        addSubview(combinedChartView)
        addSubview(barChartView)
        addSubview(selectorView)

        selectorView.isHidden = true

        headerView.selectorButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.selectorView.isHidden.toggle()
        }.disposed(by: rx.disposeBag)

        kineTypeBehaviorRelay.bind { [weak self] in
            guard let `self` = self else { return }
            self.headerView.selectorButton.setTitle($0.text, for: .normal)
        }.disposed(by: rx.disposeBag)

        selectorView.tap = { [weak self] index in
            guard let `self` = self else { return }
            self.selectorView.isHidden = true
            self.kineTypeBehaviorRelay.accept(MarketKlineType.allCases[index])
        }

        headerView.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
        }

        combinedChartView.snp.makeConstraints { (m) in
            m.top.equalTo(headerView.snp.bottom)
            m.left.right.equalToSuperview()
            m.height.equalTo(340)
        }

        barChartView.snp.makeConstraints { (m) in
            m.top.equalTo(combinedChartView.snp.bottom)
            m.bottom.left.right.equalToSuperview()
            m.height.equalTo(60)
        }

        selectorView.snp.makeConstraints { (m) in
            m.top.left.right.equalTo(combinedChartView)
        }
    }

    func bind(klineItems: [KlineItem]) {

        guard klineItems.count > 0 else { return }


        let combinedChartData = CombinedChartData()
        // kline
        let klineEntries = (0..<klineItems.count).map { index -> CandleChartDataEntry in
            let item = klineItems[index]
            return CandleChartDataEntry(x: Double(index), shadowH: item.h, shadowL: item.l, open: item.o, close: item.c)
        }

        let klineSet = CandleChartDataSet(entries: klineEntries, label: "Data Set").then {
            $0.axisDependency = .right
            $0.shadowColorSameAsCandle = true
            $0.shadowWidth = 3
            $0.decreasingColor = UIColor(netHex: 0xE5494D)
            $0.decreasingFilled = true
            $0.increasingColor = UIColor(netHex: 0x01D764)
            $0.increasingFilled = true
            $0.neutralColor = UIColor(netHex: 0x01D764)
        }

        combinedChartData.candleData = CandleChartData(dataSet: klineSet)

        // use bar fix offset
        combinedChartData.barData = {
            let entries = [BarChartDataEntry(x: -0.5, y: 0),
                           BarChartDataEntry(x: Double(klineItems.count) - 0.5, y: 0)]
            let set = BarChartDataSet(entries: entries)
            set.colors = [.clear]
            set.highlightEnabled = false
            return BarChartData(dataSet: set)
        }()

        combinedChartView.data = combinedChartData


        // Bar
        let barDataEntries = (0..<klineItems.count).map { index -> BarChartDataEntry in
            BarChartDataEntry(x: Double(index), y: klineItems[index].v)
        }

        let barSet = BarChartDataSet(entries: barDataEntries)
        barSet.colors = klineItems.map { UIColor(netHex: $0.c - $0.o >= 0 ? 0x01D764: 0xE5494D) }
        barSet.highlightEnabled = false
        barChartView.data = BarChartData(dataSet: barSet)

        self.combinedChartView.setVisibleXRangeMaximum(50.0)
        self.barChartView.setVisibleXRangeMaximum(50.0)
        self.combinedChartView.moveViewToX(Double(klineItems.count - 1))
        self.barChartView.moveViewToX(Double(klineItems.count - 1))

        let dataPoints = klineItems.map { Date(timeIntervalSince1970: TimeInterval($0.t)).format("HH:mm") }
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        barChartView.xAxis.setLabelCount(3, force: false)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


}

extension CandlestickChartView: ChartViewDelegate {

    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        let srcMatrix = chartView.viewPortHandler.touchMatrix
        self.combinedChartView.viewPortHandler.refresh(newMatrix: srcMatrix, chart: self.combinedChartView, invalidate: true)
        self.barChartView.viewPortHandler.refresh(newMatrix: srcMatrix, chart: self.barChartView, invalidate: true)
    }

    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        let srcMatrix = chartView.viewPortHandler.touchMatrix
        self.combinedChartView.viewPortHandler.refresh(newMatrix: srcMatrix, chart: self.combinedChartView, invalidate: true)
        self.barChartView.viewPortHandler.refresh(newMatrix: srcMatrix, chart: self.barChartView, invalidate: true)
    }

}

extension CandlestickChartView {
    class HeaderView: UIView {

        let selectorButton = UIButton().then {
            $0.setTitleColor(UIColor(netHex: 0x3E4A59), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x3E4A59).highlighted, for: .highlighted)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.setImage(R.image.icon_market_kline_type(), for: .normal)
            $0.setImage(R.image.icon_market_kline_type()?.highlighted, for: .highlighted)
            $0.transform = CGAffineTransform(scaleX: -1, y: 1)
            $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
            $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(selectorButton)

            selectorButton.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.equalToSuperview().offset(24)
                m.height.equalTo(9+14+9)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class SelectorView: UIView {

        var tap: ((Int) -> Void)? = nil

        override init(frame: CGRect) {
            super.init(frame: frame)

            backgroundColor = UIColor(netHex: 0xF3F3F3)

            var buttons: [UIButton] = []
            for (index, type) in MarketKlineType.allCases.enumerated() {
                let button = UIButton().then {
                    $0.setTitleColor(UIColor(netHex: 0x3E4A59), for: .normal)
                    $0.setTitleColor(UIColor(netHex: 0x3E4A59).highlighted, for: .highlighted)
                    $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                    $0.setTitle(type.text, for: .normal)
                    $0.tag = index
                    $0.addTarget(self, action: #selector(onTap(sender:)), for: .touchUpInside)
                }
                addSubview(button)
                buttons.append(button)
            }

            let lineCount = 5
            for i in 0..<buttons.count {
                let button = buttons[i]
                button.snp.makeConstraints { (m) in
                    m.height.equalTo(36)
                    m.width.equalToSuperview().multipliedBy(1.0/CGFloat(lineCount))

                    if i < lineCount {
                        m.top.equalToSuperview()
                    } else {
                        let up = buttons[i - lineCount]
                        m.top.equalTo(up.snp.bottom)
                    }

                    if i%lineCount == 0 {
                        m.left.equalToSuperview()
                    } else {
                        let left = buttons[i-1]
                        m.left.equalTo(left.snp.right)
                    }

                    if i == buttons.count - 1 {
                        m.bottom.equalToSuperview()
                    }
                }
            }
        }

        @objc func onTap(sender: UIButton) {
            if let tap = tap {
                tap(sender.tag)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
