//
//  LogDetailsController.swift
//  artest
//
//  Created by Hao Zhang on 11/15/18.
//  Copyright © 2018 Hao Zhang. All rights reserved.
//

import Foundation
import UIKit

class LogDetailsController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var closeup: UIImageView!
    @IBOutlet weak var overview: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var desField: UITextView!
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var bleedingControl: UISegmentedControl!
    @IBOutlet weak var growingControl: UISegmentedControl!
    @IBOutlet weak var painfulControl: UISegmentedControl!
    
    var rashlog: RashLog?
    
    var bleeding: Bool!
    var painful: Bool!
    var growing: Bool!
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        picker.maximumDate = Date()
        return picker
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    lazy var toolbar: UIToolbar = {
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        //        toolbar.tintColor = .white
        toolbar.tintColor = UIColor(red: 250/255, green: 181/255, blue: 194/255, alpha: 1.0)
        
        let todayButton = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(todayPressed(_:)))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed(_:)))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/3, height: 40))
        
        label.text = "Select a date"
        
        label.textAlignment = .center
        
        label.font = .systemFont(ofSize: 17)
        
        let labelButton = UIBarButtonItem(customView: label)
        
        toolbar.setItems([todayButton, flexButton, labelButton, flexButton, doneButton], animated: true)
        
        return toolbar
    }()
    
    lazy var desToolbar: UIToolbar = {
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        //        toolbar.tintColor = .white
        toolbar.tintColor = UIColor(red: 250/255, green: 181/255, blue: 194/255, alpha: 1.0)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(desDonePressed(_:)))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([flexButton, flexButton, flexButton, flexButton, doneButton], animated: true)
        
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleeding = false
        painful = false
        growing = false
        
        if let data = rashlog {
            closeup.clipsToBounds = true
            closeup.image = UIImage(data: data.closeup)
            overview.clipsToBounds = true
            overview.image = UIImage(data: data.overview)
            sizeLabel.text = data.size
            desField.text = data.desField
            dateField.text = data.dateField
            bleeding = data.bleeding
            painful = data.painful
            growing = data.growing
        }
        
        if bleeding {
            bleedingControl.selectedSegmentIndex = 0
        }
        
        if painful {
            painfulControl.selectedSegmentIndex = 0
        }
        
        if growing {
            growingControl.selectedSegmentIndex = 0
        }
        
        dateField.inputView = datePicker
        desField.delegate = self
        desField.layer.cornerRadius = 8.0
        desField.layer.masksToBounds = true
        desField.layer.borderWidth = 0.5
        desField.layer.borderColor = UIColor.lightGray.cgColor
        dateField.inputAccessoryView = toolbar
        desField.inputAccessoryView = desToolbar
        
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        
        dateField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func todayPressed(_ sender: UIBarButtonItem) {
        
        dateField.text = dateFormatter.string(from: Date())
        
        dateField.resignFirstResponder()
    }
    
    @objc func donePressed(_ sender: UIBarButtonItem) {
        dateField.resignFirstResponder()
    }
    
    @objc func desDonePressed(_ sender: UIBarButtonItem) {
        desField.resignFirstResponder()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Include information such as rashes in other locations, new medications, recent travel, and additional symptoms (fever, pain etc.). Providing more information will better help your provider make a diagnosis. "
            textView.textColor = UIColor.lightGray
        }
    }
}
