//
//  HomeViewController.swift
//  hexefit
//
//  Created by Renata Rego on 07/08/2021.
//

import UIKit
import Charts

class HomeViewController: UIViewController {
    

    @IBOutlet weak var pieChart: PieChartView!
    
    var chartPalette = ["#EF476F","#06D6A0", "#FFD166", "#118AB2"]
    
    let zones = ["Traditional Stength Training", "Mixed Cardio", "Streching", "Yoga", "Running"]
    let timeinzones = [100, 100, 80, 76, 60]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeChart(dataPoints: zones, values: timeinzones.map{ Double($0) })
        // Do any additional setup after loading the view.
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
          let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
          dataEntries.append(dataEntry)
        }
        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        // 4. Assign it to the chart’s data
        pieChart.data = pieChartData
        
    }
    
    private func updateChartPallete(){
        for i in 0..<chartPalette.count-1{
            chartPalette[i] = chartPalette[i+1]
        }
        chartPalette[chartPalette.count-1] = chartPalette[0]
    }
    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        
        for i in 0..<numbersOfColor {
            let colorIdx = i % chartPalette.count
            colors.append(UIColor(hex: chartPalette[colorIdx]) ?? UIColor.green)
            if i == chartPalette.count - 1{
                updateChartPallete()
            }
        }
      return colors
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b: CGFloat
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            if hexColor.count == 6{
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000FF) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }

        return nil
    }
}
