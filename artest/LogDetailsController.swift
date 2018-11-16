//
//  LogDetailsController.swift
//  artest
//
//  Created by Hao Zhang on 11/15/18.
//  Copyright © 2018 Hao Zhang. All rights reserved.
//

import Foundation
import UIKit

class LogDetailsController: UIViewController {
    @IBOutlet weak var closeup: UIImageView!
    @IBOutlet weak var overview: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var desField: UITextView!
    @IBOutlet weak var dateField: UITextField!
    
    var rashlog: RashLog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = rashlog {
            closeup.clipsToBounds = true
            closeup.image = UIImage(data: data.closeup)
            overview.clipsToBounds = true
            overview.image = UIImage(data: data.overview)
            sizeLabel.text = data.size
            desField.text = data.desField
            dateField.text = data.dateField
        }
        
        
    }
}
