//
//  PlanCell.swift
//  hexefit
//
//  Created by Renata Rego on 27/07/2021.
//

import UIKit

class PlanCell: UITableViewCell {

    @IBOutlet weak var planName: UILabel!
    
    
    
    @IBOutlet weak var planDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
