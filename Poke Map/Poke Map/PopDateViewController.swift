//
//  DatePickerActionSheet.swift
//  iDoctors
//
//  Created by Valerio Ferrucci on 30/09/14.
//  Copyright (c) 2014 Tabasoft. All rights reserved.
//

import UIKit

protocol DataPickerViewControllerDelegate : class {
    
    func datePickerVCDismissed(date : NSDate?)
}

class PopDateViewController : UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate : DataPickerViewControllerDelegate?

    var currentDate : NSDate? {
        didSet {
            updatePickerCurrentDate()
        }
    }

    convenience init() {

        self.init(nibName: "PopDateViewController", bundle: nil)
    }

    private func updatePickerCurrentDate() {
        
        if let _currentDate = self.currentDate {
            if let _datePicker = self.datePicker {
                _datePicker.date = _currentDate as Date
            }
        }
    }

    @IBAction func okAction(sender: AnyObject) {
        
        self.dismiss(animated: true) {
            
            let nsdate = self.datePicker.date
            self.delegate?.datePickerVCDismissed(date: nsdate as NSDate)
            
        }
    }
    
    override func viewDidLoad() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateFormatted = dateFormatter.date(from: "07/08/2016")
        datePicker.minimumDate = dateFormatted
        datePicker.maximumDate = NSDate() as Date
        updatePickerCurrentDate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.delegate?.datePickerVCDismissed(date: nil)
    }
}
