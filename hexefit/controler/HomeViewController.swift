//
//  HomeViewController.swift
//  hexefit
//
//  Created by Renata Rego on 07/08/2021.
//

import UIKit
import Charts
import HealthKit




class HomeViewController: UIViewController {
    

    @IBOutlet weak var pieChart: PieChartView!
    
    var hkAssistant = HealthKitAssistant()
    
    var weekWorkouts: [String: Int] = [:]
    
//    var chartPalette = ["#EF476F","#06D6A0", "#FFD166", "#118AB2"]
    var chartPalette = ["#F94144", "#577590", "#F9C74F", "#F3722C", "#43AA8B", "#F8961E", "#90BE6D"]
    
    let zones = ["Traditional Stength Training", "Mixed Cardio", "Streching", "Yoga", "Running"]
    
    let timeinzones = [100, 100, 80, 76, 60]
    
    // MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "HexFit"
        self.navigationController?.title = "HexFit"
        authorizeHealthKit()
        customizeChart(dataPoints: Array(weekWorkouts.keys), values: Array(weekWorkouts.values).map{ Double($0)})
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Chart Methods
    
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
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.horizontalAlignment = .center
        // 4. Assign it to the chart’s data
        pieChart.data = pieChartData
        
    }
    
    func updateChartPallete(){
        for i in 0..<chartPalette.count-1{
            chartPalette[i] = chartPalette[i+1]
        }
        chartPalette[chartPalette.count-1] = chartPalette[0]
    }
    
    func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        var alpha = 1.0
        for i in 0..<numbersOfColor {
            let colorIdx = i % chartPalette.count
            print(alpha)
            colors.append(UIColor(hex: chartPalette[colorIdx], alpha: alpha) ?? UIColor.green)
            if i == chartPalette.count - 1{
                updateChartPallete()
                if alpha > 0.5{
                    alpha -= 0.5
                }
            }
        }
      return colors
    }
}


// MARK: - UIColor Extension to create object from hex code
extension UIColor {
    public convenience init?(hex: String, alpha: Double) {
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

                    self.init(red: r, green: g, blue: b, alpha: CGFloat(alpha))
                    return
                }
            }
        }

        return nil
    }
}


// MARK: - HealthKit Methods
extension HomeViewController{
    func authorizeHealthKit(){
        HealthKitAssistant.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                return
            }
            print("HealthKit Successfully Authorized.")
            self.loadHKData() { workouts, error  in
                print("Number of workouts:")
                print(workouts!.count)
            }

        }
    }
    
    func loadHKData(completion:
                        @escaping ([HKWorkout]?, Error?) -> Void) {

        let calendar = NSCalendar.current
        let endDate = Date()
         
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            fatalError("*** Unable to create the start date ***")
        }

        // Create the predicate for the query
        let workoutsWithinRange = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                ascending: true)
        

        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: workoutsWithinRange,
            limit: 0,
            sortDescriptors: [sortDescriptor]) {
            
            query, results, error in
            
            guard let samples = results as? [HKWorkout] else {
                completion(nil, error)
                return
            }
            
            for sample in samples{
                if self.weekWorkouts[sample.workoutActivityType.name] != nil{
                    self.weekWorkouts[sample.workoutActivityType.name]! += Int(round(Double(sample.duration)/60.0))
                }
                else{
                    self.weekWorkouts[sample.workoutActivityType.name] = Int(round(Double(sample.duration)/60.0))
                }
            }
            
            DispatchQueue.main.async {
                self.customizeChart(dataPoints: Array(self.weekWorkouts.keys), values: Array(self.weekWorkouts.values).map{ Double($0)})
            }
            completion(samples, nil)
            
            
        }
        HKHealthStore().execute(query)

    }

}
