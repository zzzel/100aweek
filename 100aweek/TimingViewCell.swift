//
//  TimingViewCell.swift
//  100aweek
//
//  Created by Zel Marko on 19/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class TimingViewCell: UITableViewCell {

    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var pausedLabel: UILabel!
    @IBOutlet weak var pausesLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
      
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
