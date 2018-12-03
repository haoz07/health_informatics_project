//
//  TableCell.swift
//  artest
//
//  Created by Hao Zhang on 11/15/18.
//  Copyright © 2018 Hao Zhang. All rights reserved.
//

import Foundation
import UIKit

class TableCell: UITableViewCell {
    @IBOutlet weak var closeup: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
