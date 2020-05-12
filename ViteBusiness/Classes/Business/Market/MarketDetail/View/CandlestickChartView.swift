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

    static let height: CGFloat = 440

    var kineTypeBehaviorRelay: BehaviorRelay<MarketKlineType>

    let headerView = HeaderView()
    let selectorView = SelectorView()

    let valueView = ValueView()

    let ma7Lable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        $0.textColor = UIColor(netHex: 0xFFA300)
    }

    let ma30Lable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        $0.textColor = UIColor(netHex: 0x007AFF)
    }

    let ma90Lable = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        $0.textColor = UIColor(netHex: 0xA864FF)
    }

    let logoImageView = UIImageView(image: R.image.icon_market_logo())

    let combinedChartView = CombinedChartView().then {

        $0.chartDescription?.enabled = false
        $0.pinchZoomEnabled = true
        $0.drawGridBackgroundEnabled = true
        $0.doubleTapToZoomEnabled = false
        $0.scaleXEnabled = true
        $0.scaleYEnabled = false
        $0.leftAxis.enabled = false
        $0.legend.enabled = false
        $0.autoScaleMinMaxEnabled = true
        $0.maxVisibleCount = 0
        $0.backgroundColor = .clear
        $0.gridBackgroundColor = .clear
        $0.noDataText = ""

        $0.xAxis.enabled = true
        $0.xAxis.drawAxisLineEnabled = false
        $0.xAxis.labelPosition = .top
        $0.xAxis.labelTextColor = .clear
        $0.xAxis.drawGridLinesEnabled = true
        $0.xAxis.gridLineWidth = 1
        $0.xAxis.gridColor = UIColor(netHex: 0xD3DFEF, alpha: 0.4)
        $0.xAxis.axisMinLabels = 1
        $0.xAxis.axisMaxLabels = 4
        $0.xAxis.labelCount = 4

        $0.rightAxis.labelCount = 4
        $0.rightAxis.drawAxisLineEnabled = false
        $0.rightAxis.labelPosition = .insideChart
        $0.rightAxis.labelFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.rightAxis.labelTextColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.rightAxis.drawGridLinesEnabled = true
        $0.rightAxis.gridLineWidth = 1
        $0.rightAxis.gridColor = UIColor(netHex: 0xD3DFEF, alpha: 0.4)

    }

    let barChartView = BarChartView().then {
        $0.chartDescription?.enabled = false
        $0.pinchZoomEnabled = true
        $0.drawGridBackgroundEnabled = true
        $0.doubleTapToZoomEnabled = false
        $0.scaleXEnabled = true
        $0.scaleYEnabled = false
        
        $0.legend.enabled = false
        $0.autoScaleMinMaxEnabled = true
        $0.maxVisibleCount = 0
        $0.backgroundColor = .clear
        $0.gridBackgroundColor = .clear
        $0.noDataText = ""


        $0.xAxis.labelPosition = .bottom
        $0.xAxis.labelFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.xAxis.labelTextColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.xAxis.drawGridLinesEnabled = true
        $0.xAxis.gridLineWidth = 1
        $0.xAxis.gridColor = UIColor(netHex: 0xD3DFEF, alpha: 0.4)
        $0.xAxis.axisMinLabels = 1
        $0.xAxis.axisMaxLabels = 4
        $0.xAxis.labelCount = 4

        $0.rightAxis.enabled = false
        $0.leftAxis.drawAxisLineEnabled = false;
        $0.leftAxis.labelPosition = .insideChart
        $0.leftAxis.labelTextColor = .clear;
        $0.leftAxis.labelCount = 1;
        $0.leftAxis.drawGridLinesEnabled = false;
    }

    init(klineType: MarketKlineType) {
        self.kineTypeBehaviorRelay = BehaviorRelay(value: klineType)
        super.init(frame: .zero)

        combinedChartView.delegate = self
        barChartView.delegate = self

        addSubview(headerView)
        addSubview(logoImageView)
        addSubview(combinedChartView)
        addSubview(barChartView)
        addSubview(ma7Lable)
        addSubview(ma30Lable)
        addSubview(ma90Lable)
        addSubview(valueView)
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

        logoImageView.snp.makeConstraints { (m) in
            m.left.equalTo(combinedChartView).offset(9)
            m.bottom.equalTo(combinedChartView).offset(-8)
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

        ma7Lable.snp.makeConstraints { (m) in
            m.top.equalTo(combinedChartView).offset(10)
            m.left.equalTo(combinedChartView).offset(8)
        }

        ma30Lable.snp.makeConstraints { (m) in
            m.top.equalTo(combinedChartView).offset(10)
            m.left.equalTo(ma7Lable.snp.right).offset(20)
        }

        ma90Lable.snp.makeConstraints { (m) in
            m.top.equalTo(combinedChartView).offset(10)
            m.left.equalTo(ma30Lable.snp.right).offset(20)
        }

        selectorView.snp.makeConstraints { (m) in
            m.top.left.right.equalTo(combinedChartView)
        }

        valueView.snp.makeConstraints { (m) in
            m.top.equalTo(combinedChartView).offset(36)
            m.width.equalTo(135)
            m.right.equalTo(combinedChartView).offset(-5)
        }

        selectedIndex.bind { [weak self] in
            guard let `self` = self else { return }
            if let index = $0, index < self.klineItems.count {
                let pricePrecision = self.marketInfo?.statistic.pricePrecision ?? 4
                let ma7Value = self.ma7?[index].map { String(format: "%.\(pricePrecision)f", $0) } ?? ""
                let ma30Value = self.ma30?[index].map { String(format: "%.\(pricePrecision)f", $0) } ?? ""
                let ma90Value = self.ma90?[index].map { String(format: "%.\(pricePrecision)f", $0) } ?? ""
                self.ma7Lable.text = "MA7: \(ma7Value)"
                self.ma30Lable.text = "MA30: \(ma30Value)"
                self.ma90Lable.text = "MA90: \(ma90Value)"

                self.valueView.bind(klineItem: self.klineItems[index], info: self.marketInfo)
                self.valueView.isHidden = false
            } else {
                self.ma7Lable.text = "MA7: "
                self.ma30Lable.text = "MA30: "
                self.ma90Lable.text = "MA90: "

                self.valueView.isHidden = true
            }
        }.disposed(by: rx.disposeBag)
    }

    let selectedIndex: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    var klineItems: [KlineItem] = []
    var marketInfo: MarketInfo? = nil
    var ma7: [Double?]? = nil
    var ma30: [Double?]? = nil
    var ma90: [Double?]? = nil

    var lastKlineTopic: String = ""

    func bind(klineItems: [KlineItem], info: MarketInfo) {

        let neededMove = lastKlineTopic != self.kineTypeBehaviorRelay.value.topic(symbol: info.statistic.symbol)

        self.klineItems = klineItems
        self.marketInfo = info

        if klineItems.count > 0 {
            self.lastKlineTopic = self.kineTypeBehaviorRelay.value.topic(symbol: info.statistic.symbol)
        }

        ma7 = nil
        ma30 = nil
        ma90 = nil

        bindCombinedChartView(klineItems: klineItems)
        bindBarChartView(klineItems: klineItems)



        if neededMove {
            self.combinedChartView.setVisibleXRange(minXRange: 50, maxXRange: 50)
            self.barChartView.setVisibleXRange(minXRange: 50, maxXRange: 50)
            let x: Double = klineItems.count < 50 ? 0 : Double(klineItems.count - 1)
            self.combinedChartView.moveViewToX(x)
            self.barChartView.moveViewToX(x)
            self.combinedChartView.setVisibleXRange(minXRange: 25, maxXRange: 50)
            self.barChartView.setVisibleXRange(minXRange: 25, maxXRange: 50)
            selectedIndex.accept(nil)
        }

        let dataPoints = klineItems.map { Date(timeIntervalSince1970: TimeInterval($0.t)).format(kineTypeBehaviorRelay.value.timeFormat) }
        combinedChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        combinedChartView.rightAxis.valueFormatter = DefaultAxisValueFormatter(block: { (value, _) -> String in
            String(format: "%.\(info.statistic.pricePrecision)f", value)
        })
    }

    func bindCombinedChartView(klineItems: [KlineItem]) {

        guard klineItems.count > 0 else {
            combinedChartView.data = nil
            return
        }

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
                           BarChartDataEntry(x: max(Double(klineItems.count), 50) - 0.5, y: 0)]
            let set = BarChartDataSet(entries: entries)
            set.colors = [.clear]
            set.highlightEnabled = false
            return BarChartData(dataSet: set)
        }()

        // ma
        let ma7 = calcMA(klineItems: klineItems, days: 7)
        let ma30 = calcMA(klineItems: klineItems, days: 30)
        let ma90 = calcMA(klineItems: klineItems, days: 90)
        self.ma7 = ma7
        self.ma30 = ma30
        self.ma90 = ma90
        let ma7DataSet = maDataSet(ma: ma7).then { $0.colors = [UIColor(netHex: 0xFFA300)] }
        let ma30DataSet = maDataSet(ma: ma30).then { $0.colors = [UIColor(netHex: 0x007AFF)] }
        let ma90DataSet = maDataSet(ma: ma90).then { $0.colors = [UIColor(netHex: 0xA864FF)] }
        combinedChartData.lineData = LineChartData(dataSets: [ma7DataSet, ma30DataSet, ma90DataSet])

        combinedChartView.data = combinedChartData
    }

    func maDataSet(ma: [Double?]) -> LineChartDataSet {
        var maEntries: [ChartDataEntry] = []
        for (index, closePrice) in ma.enumerated() {
            if let closePrice = closePrice {
                maEntries.append(ChartDataEntry(x: Double(index), y: closePrice))
            }
        }

        return LineChartDataSet(entries: maEntries).then {
            $0.mode = .cubicBezier
            $0.drawCirclesEnabled = false
            $0.lineWidth = 1
            $0.circleRadius = 4
            $0.axisDependency = .right
        }
    }

    func bindBarChartView(klineItems: [KlineItem]) {

        guard klineItems.count > 0 else {
            barChartView.data = nil
            return
        }

        var barDataEntries = (0..<klineItems.count).map { index -> BarChartDataEntry in
            BarChartDataEntry(x: Double(index), y: klineItems[index].v)
        }

        if klineItems.count < 50 {
            barDataEntries.append(BarChartDataEntry(x: 49, y: 0))
        }

        let barSet = BarChartDataSet(entries: barDataEntries)
        barSet.colors = klineItems.map { UIColor(netHex: $0.c - $0.o >= 0 ? 0x01D764: 0xE5494D) }
        barSet.highlightEnabled = false
        barChartView.data = BarChartData(dataSet: barSet)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    func calcMA(klineItems: [KlineItem], days: Int) -> [Double?] {
        var sum: Double = 0
        var ma: [Double?] = []
        let closePriceArray = klineItems.map { $0.c }
        for (index, closePrice) in closePriceArray.enumerated() {
            if index >= days - 1 {
                sum += closePrice
                if index - days >= 0 {
                    sum -= closePriceArray[index - days]
                }
                ma.append(sum / Double(days))
            } else {
                sum += closePrice
                ma.append(nil)
            }
        }
        return ma
    }
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

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let index = Int(exactly: entry.x) {
            selectedIndex.accept(index)

            if highlight.xPx > self.bounds.width / 2 {
                valueView.snp.remakeConstraints { (m) in
                    m.top.equalTo(combinedChartView).offset(36)
                    m.width.equalTo(135)
                    m.left.equalTo(combinedChartView).offset(5)
                }
            } else {
                valueView.snp.remakeConstraints { (m) in
                    m.top.equalTo(combinedChartView).offset(36)
                    m.width.equalTo(135)
                    m.right.equalTo(combinedChartView).offset(-5)
                }
            }

        } else {
            selectedIndex.accept(nil)
        }
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        selectedIndex.accept(nil)
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

            backgroundColor = UIColor(netHex: 0x3E4A59, alpha: 0.02)
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

    class ValueView: UIView {
        let timeTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.text = R.string.localizable.marketDetailPageValueTimeTitle()
        }
        let openTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.text = R.string.localizable.marketDetailPageValueOpenTitle()
        }
        let highTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.text = R.string.localizable.marketDetailPageValueHighTitle()
        }
        let lowTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.text = R.string.localizable.marketDetailPageValueLowTitle()
        }
        let closeTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.text = R.string.localizable.marketDetailPageValueCloseTitle()
        }
        let diffTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.text = R.string.localizable.marketDetailPageValueDiffTitle()
        }
        let extentTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.text = R.string.localizable.marketDetailPageValueExtentTitle()
        }
        let volTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
            $0.text = R.string.localizable.marketDetailPageValueVolTitle()
        }


        let timeLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
        }

        let openLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
        }

        let highLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
        }

        let lowLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
        }

        let closeLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
        }

        let diffLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
        }

        let extentLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
        }

        let volLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            let stackView = UIStackView().then {
                $0.axis = .vertical
                $0.alignment = .fill
                $0.distribution = .fill
                $0.spacing = 4
            }

            func addTo(left: UIView, right: UIView) -> UIView {
                let view = UIView()
                view.addSubview(left)
                view.addSubview(right)
                left.snp.makeConstraints { (m) in
                    m.top.bottom.left.equalToSuperview()
                }

                right.snp.makeConstraints { (m) in
                    m.top.bottom.right.equalToSuperview()
                }
                return view
            }

            backgroundColor = UIColor(netHex: 0xFBFBFC)
            layer.borderColor = UIColor(netHex: 0xD3DFEF).cgColor
            layer.borderWidth = 1
            layer.cornerRadius = 2

            addSubview(stackView)
            stackView.snp.makeConstraints { (m) in
                m.edges.equalToSuperview().inset(8)
            }

            stackView.addArrangedSubview(addTo(left: timeTitleLabel, right: timeLabel))
            stackView.addArrangedSubview(addTo(left: openTitleLabel, right: openLabel))
            stackView.addArrangedSubview(addTo(left: highTitleLabel, right: highLabel))
            stackView.addArrangedSubview(addTo(left: lowTitleLabel, right: lowLabel))
            stackView.addArrangedSubview(addTo(left: closeTitleLabel, right: closeLabel))
            stackView.addArrangedSubview(addTo(left: diffTitleLabel, right: diffLabel))
            stackView.addArrangedSubview(addTo(left: extentTitleLabel, right: extentLabel))
            stackView.addArrangedSubview(addTo(left: volTitleLabel, right: volLabel))
        }

        func bind(klineItem: KlineItem, info: MarketInfo?) {

            let pricePrecision = info?.statistic.pricePrecision ?? 4
            let quantityPrecision = info?.statistic.quantityPrecision ?? 4


            timeLabel.text = Date(timeIntervalSince1970: TimeInterval(klineItem.t)).format("yy-MM-dd HH:mm:ss")
            openLabel.text = String(format: "%.\(pricePrecision)f", klineItem.o)
            highLabel.text = String(format: "%.\(pricePrecision)f", klineItem.h)
            lowLabel.text = String(format: "%.\(pricePrecision)f", klineItem.l)
            closeLabel.text = String(format: "%.\(pricePrecision)f", klineItem.c)
            diffLabel.text = String(format: "%.\(pricePrecision)f", klineItem.c - klineItem.o)
            extentLabel.text = String(format: "%.2f%%", (klineItem.c - klineItem.o) * 100 / klineItem.o)
            volLabel.text = String(format: "%.\(quantityPrecision)f", klineItem.v)
        }

        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
