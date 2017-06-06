//
//  DriverTableViewCell.swift
//  UberClone
//
//  Created by Marcelo Mogrovejo on 6/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import Parse

class DriverTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var riderNameLabel: UILabel!
    @IBOutlet weak var riderDistantceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Public methods
    
    func configureCell(uberRequest: Request) {
        riderNameLabel.text = uberRequest.username
        riderDistantceLabel.text = String(format: "%.2f", uberRequest.distance) + "km away"
    }

}
