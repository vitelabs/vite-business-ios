//
//  CandlestickChartView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit
import LightweightCharts
import Charts


class CandlestickChartView: UIView {

    let chartView = CombinedChartView().then {
        $0.chartDescription?.enabled = false
        $0.maxVisibleCount = 60
        $0.pinchZoomEnabled = false
        $0.drawGridBackgroundEnabled = true
        $0.backgroundColor = .clear
        $0.gridBackgroundColor = .clear

        $0.xAxis.labelPosition = .bottom
        $0.xAxis.drawGridLinesEnabled = false
        $0.xAxis.labelFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.xAxis.labelTextColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)

        $0.rightAxis.labelCount = 4
        $0.rightAxis.drawGridLinesEnabled = false
        $0.rightAxis.drawAxisLineEnabled = false
        $0.rightAxis.labelPosition = .outsideChart
        $0.rightAxis.labelFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.rightAxis.labelTextColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)

        $0.scaleYEnabled = false
        $0.leftAxis.enabled = false
        $0.legend.enabled = false
    }



    override init(frame: CGRect) {
        super.init(frame: frame)

        chartView.delegate = self

//        self.chartView.zoomToCenter(scaleX: 4, scaleY: 1)

        addSubview(chartView)

        chartView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
            m.height.equalTo(400)
        }

        // 待测试的属性
//        chartView.autoScaleMinMaxEnabled = true


        let chartData = CombinedChartData()
        chartData.candleData = generateCandleData(count: 500, range: 100)
        chartData.lineData = generateLineData(count: 500, range: 100)
        chartData.barData = generateBarData(count: 500, range: 100)
        chartView.data = chartData

    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func generateLineData(count: Int, range: UInt32) -> LineChartData {
        let colors = ChartColorTemplates.vordiplom()[0...2]

        let block: (Int) -> ChartDataEntry = { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(range) + 3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        let dataSets = (0..<3).map { i -> LineChartDataSet in
            let yVals = (0..<count).map(block)
            let set = LineChartDataSet(entries: yVals, label: "DataSet \(i)")
            set.lineWidth = 2.5
            set.circleRadius = 4
            set.circleHoleRadius = 2
            let color = colors[i % colors.count]
            set.setColor(color)
            set.setCircleColor(color)

            return set
        }

        dataSets[0].lineDashLengths = [5, 5]
        dataSets[0].colors = ChartColorTemplates.vordiplom()
        dataSets[0].circleColors = ChartColorTemplates.vordiplom()

        let data = LineChartData(dataSets: dataSets)
        data.setValueFont(.systemFont(ofSize: 7, weight: .light))

        return data
    }

    func generateCandleData(count: Int, range: UInt32) -> CandleChartData {
        let yVals1 = (0..<count).map { (i) -> CandleChartDataEntry in
            let mult: UInt32 = range + 1
            let val = Double(arc4random_uniform(40) + mult)
            let high = Double(arc4random_uniform(9) + 8)
            let low = Double(arc4random_uniform(9) + 8)
            let open = Double(arc4random_uniform(6) + 1)
            let close = Double(arc4random_uniform(6) + 1)
            let even = i % 2 == 0

            return CandleChartDataEntry(x: Double(i), shadowH: val + high, shadowL: val - low, open: even ? val + open : val - open, close: even ? val - close : val + close, icon: nil)
        }

        let set1 = CandleChartDataSet(entries: yVals1, label: "Data Set")
        set1.axisDependency = .left
        set1.setColor(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = false
        set1.shadowColor = .darkGray
        set1.shadowWidth = 0.7
        set1.decreasingColor = .red
        set1.decreasingFilled = true
        set1.increasingColor = UIColor(red: 122/255, green: 242/255, blue: 84/255, alpha: 1)
        set1.increasingFilled = false
        set1.neutralColor = .blue

        return CandleChartData(dataSet: set1)
    }

    func generateBarData(count: Int, range: UInt32) -> BarChartData {

        var dataEntries = [BarChartDataEntry]()
        for i in 0..<count {
            let y = arc4random()%range
            let entry = BarChartDataEntry(x: Double(i), y: Double(y))
            dataEntries.append(entry)
        }
        //这10条数据作为柱状图的所有数据
        let chartDataSet = BarChartDataSet(entries: dataEntries)
        chartDataSet.colors = [.orange] //全部使用橙色
        //目前柱状图只包括1组立柱
        let chartData = BarChartData(dataSets: [chartDataSet])
        return chartData
    }
}

extension CandlestickChartView: ChartViewDelegate {


}
