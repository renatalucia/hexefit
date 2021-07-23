//
//  HistoryCell.swift
//  hexefit
//
//  Created by Renata Rego on 19/07/2021.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var startTime: UILabel!
    
    @IBOutlet weak var activityIcon: UIImageView!
    
    @IBOutlet weak var workoutType: UILabel!
    
    @IBOutlet weak var duration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
