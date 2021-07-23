//
//  ActivityCell.swift
//  hexefit
//
//  Created by Renata Rego on 18/07/2021.
//

import UIKit

class ActivityCell: UITableViewCell {

    @IBOutlet weak var activityBubble: UIView!
    
    @IBOutlet weak var ActivityIcon: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        activityBubble.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
}
