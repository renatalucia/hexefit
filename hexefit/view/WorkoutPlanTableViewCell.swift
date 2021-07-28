//
//  WorkoutPlanTableViewCell.swift
//  hexefit
//
//  Created by Renata Rego on 28/07/2021.
//

import UIKit

class WorkoutPlanTableViewCell: UITableViewCell {

    @IBOutlet weak var exerciseData: UILabel!
    
    @IBOutlet weak var exerciseName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
