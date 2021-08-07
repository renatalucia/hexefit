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
    
    
    let zones = ["Warm up", "Fat Burn", "Cardio", "Peak"]
    let timeinzones = [100, 100, 80, 76]
    
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
    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        print(numbersOfColor)

//        var  colors: [UIColor] = []
//        for _ in 0..<numbersOfColor {
//        let red = Double(arc4random_uniform(256))
//        let green = Double(arc4random_uniform(256))
//        let blue = Double(arc4random_uniform(256))
//        let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
//        colors.append(color)
//      }
        let colors: [UIColor] = [
                    UIColor(red: 239/255, green: 71/255, blue: 111/255, alpha: 1),
                    UIColor(red: 255/255, green: 209/255, blue: 102/255, alpha: 1),
            UIColor(red: 6/255, green: 214/255, blue: 160/255, alpha: 1),
                    UIColor(red: 17/255, green: 138/255, blue: 178/255, alpha: 1)]
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
