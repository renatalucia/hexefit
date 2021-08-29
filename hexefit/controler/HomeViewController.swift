//
//  HomeViewController.swift
//  hexefit
//
//  Created by Renata Rego on 07/08/2021.
//

import UIKit
import Charts
import HealthKit




class HomeViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var pieChart: PieChartView!
    

    @IBOutlet weak var workoutsLabel: UILabel!
    @IBOutlet weak var trainingTimeLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var stairsLabel: UILabel!
    @IBOutlet weak var sleepLabel: UILabel!
    @IBOutlet weak var restCaloriesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var duesPaidLabel: UILabel!
    @IBOutlet weak var activeTimeLabel: UILabel!
    
    var hkAssistant = HealthKitAssistant()
    var weekWorkouts: [String: Int] = [:]
    var workoutsCount = 0
    var workoutsToday = 0
    var activeTimeToday:Int = 0
    
    var stepsCount:Double = 0
    
    var chartPalette = ["#EF476F","#06D6A0", "#FFD166", "#118AB2"]
//    var chartPalette = ["#F94144", "#577590", "#F9C74F", "#F3722C", "#43AA8B", "#F8961E", "#90BE6D"]
    
    let zones = ["Traditional Stength Training", "Mixed Cardio", "Streching", "Yoga", "Running"]
    
    let timeinzones = [100, 100, 80, 76, 60]
    
    // MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "HexFit"
        self.navigationController?.title = "HexFit"
        self.duesPaidLabel.clipsToBounds = true
        duesPaidLabel.lineBreakMode = .byWordWrapping
        duesPaidLabel.numberOfLines = 0;
        authorizeHealthKit()
        self.pieChart.delegate = self

//        customizeChart(dataPoints: Array(weekWorkouts.keys), values: Array(weekWorkouts.values).map{ Double($0)})
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
        let formatter = ChartValueFormatter(numberFormatter: format)
        pieChartData.setValueFormatter(formatter)
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.horizontalAlignment = .center
        pieChartData.highlightEnabled = false
        
        // 4. Assign it to the chart’s data
        pieChart.data = pieChartData
        
        let chartAttribute = [ NSAttributedString.Key.font: UIFont(name: "ArialHebrew", size: 20)! ]
        let chartAttrString = NSAttributedString(
            string: "\(String(workoutsCount))", attributes: chartAttribute)
        pieChart.centerAttributedText = chartAttrString
        
        
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight){
        print("Triangle")
        performSegue(withIdentifier: "toRecent", sender: self)
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
    
    // MARK: - UI Methods
    func updateUIWeekData() {
        self.customizeChart(dataPoints: Array(self.weekWorkouts.keys), values: Array(self.weekWorkouts.values).map{ Double($0)})
        self.workoutsLabel.text = String(workoutsCount)
        self.activeTimeLabel.text = String("\(self.activeTimeToday)min")
        self.trainingTimeLabel.text = String("\(Array(self.weekWorkouts.values).reduce(0, +))min")
        if workoutsToday > 0{
            self.duesPaidLabel.text = "Dues Paid! \n Congrats! You did \(workoutsToday) workouts today."
            self.duesPaidLabel.backgroundColor = UIColor(hex: "#06d6a0", alpha: 1.0)
        } else {
            self.duesPaidLabel.text = "Let's move! \n The only bad workout is the one that \n didn't happen."
            self.duesPaidLabel.backgroundColor = UIColor(hex: "#ef476f", alpha: 1.0)
        }
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

// MARK: - Formatter for PieChart
class ChartValueFormatter: NSObject, IValueFormatter {
    fileprivate var numberFormatter: NumberFormatter?

    convenience init(numberFormatter: NumberFormatter) {
        self.init()
        self.numberFormatter = numberFormatter
    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let numberFormatter = numberFormatter
            else {
                return ""
        }
        return "\(numberFormatter.string(for: value)!) \n min"
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
            self.getTodaysData()

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
                self.workoutsCount += 1
                
                if Calendar.current.isDate(sample.endDate, inSameDayAs: Date()){
                    self.workoutsToday += 1
                    self.activeTimeToday += Int(round(Double(sample.duration)/60.0))
                }

            }
            
            DispatchQueue.main.async {
                self.updateUIWeekData()
            }
            completion(samples, nil)
            
            
        }
        HKHealthStore().execute(query)

    }
    
    func getTodaysData() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let activeEnergyQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let basalEnergyQuantityType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
        let flightsClimbedQuantityType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        let distanceType =  HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                fatalError("Error loading todays steps")
            }
            self.stepsCount = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                self.stepsLabel.text = String(self.stepsCount)
            }
        }
        
        HKHealthStore().execute(query)
        
        let queryFC = HKStatisticsQuery(
            quantityType: flightsClimbedQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                fatalError("Error loading stairs climbed")
            }
            DispatchQueue.main.async {
                self.stairsLabel.text = String(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        HKHealthStore().execute(queryFC)
        
        let queryAE = HKStatisticsQuery(
            quantityType: activeEnergyQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                fatalError("Error loading active calories")
            }
            DispatchQueue.main.async {
                self.caloriesLabel.text = String(sum.doubleValue(for: HKUnit.kilocalorie()))
            }
        }
        
        HKHealthStore().execute(queryAE)
        
        let queryBE = HKStatisticsQuery(
            quantityType: basalEnergyQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                fatalError("Error loading basal calories")
            }
            DispatchQueue.main.async {
                self.restCaloriesLabel.text = String(sum.doubleValue(for: HKUnit.kilocalorie()))
            }
        }
        
        HKHealthStore().execute(queryBE)
        
        let queryD = HKStatisticsQuery(
            quantityType: distanceType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                fatalError("Error loading basal calories")
            }
            print("distance:")
            let distance = sum.doubleValue(for: HKUnit.meter())/1000.0
            let distanceString = String(format: "%.1f", distance)
            DispatchQueue.main.async {
                self.distanceLabel.text = "\(distanceString)km"
            }
        }
        
        HKHealthStore().execute(queryD)
        
        // Get all samples from the last 24 hours
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-1.0 * 60.0 * 60.0 * 24.0)
        let predicateSleepQuery = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                ascending: true)
        let querySL = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicateSleepQuery,
            limit: 0,
            sortDescriptors: [sortDescriptor]) { (query, result, error) in
                guard let result = result else {
                    fatalError("Error loading sleep data")
                }
                var minutesSleepAggr = 0.0
                for item in result {
                    if let sample = item as? HKCategorySample {
                        if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue && sample.startDate >= startDate {
                                let sleepTime = sample.endDate.timeIntervalSince(sample.startDate)
                                let minutesInAnHour = 60.0
                                let minutesBetweenDates = sleepTime / minutesInAnHour
                                minutesSleepAggr += minutesBetweenDates
                        }
                    }
                }
            
                print(minutesSleepAggr)
                DispatchQueue.main.async {
                    self.sleepLabel.text = "\(String(Int(minutesSleepAggr/60)))h\(String( Int(round(minutesSleepAggr.truncatingRemainder(dividingBy: 60.0)))))m"
                }
            }
        
        HKHealthStore().execute(querySL)
        

    }
    

    
    func loadDayHKData(){
        //   Define the Step Quantity Type
//        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
//        let activeKcal = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
//        let restKcal = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)
//        let stairs = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)

        //   Get the start of the day
    }


}
