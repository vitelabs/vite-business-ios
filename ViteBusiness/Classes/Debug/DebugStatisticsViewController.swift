//
//  DebugStatisticsViewController.swift
//  Pods
//
//  Created by Stone on 2019/1/3.
//
#if DEBUG || TEST
import UIKit
import Eureka

class DebugStatisticsViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        form
            +++
            Section {
                $0.header = HeaderFooterView(title: "")
            }
            <<< LabelRow("testStatistics") {
                $0.title =  "Test Statistics"
                }.onCellSelection({ _, _  in
                    Statistics.log(eventId: Statistics.Page.Debug.test.rawValue)
                })
            <<< SwitchRow("showStatisticsToast") {
                $0.title = "Show Statistics Toast"
                $0.value = DebugService.instance.config.showStatisticsToast
                }.onChange { row in
                    guard let ret = row.value else { return }
                    DebugService.instance.config.showStatisticsToast = ret
            }
            <<< SwitchRow("reportEventInDebug") {
                $0.title = "Report Event In Debug"
                $0.value = DebugService.instance.config.reportEventInDebug
                }.onChange { row in
                    guard let ret = row.value else { return }
                    DebugService.instance.config.reportEventInDebug = ret
        }
    }
}
#endif
