//
//  DataPicker.swift
//  iDoctors
//
//  Created by Valerio Ferrucci on 30/09/14.
//  Copyright (c) 2014 Tabasoft. All rights reserved.
//

import UIKit

public class PopDatePicker : NSObject, UIPopoverPresentationControllerDelegate, DataPickerViewControllerDelegate {
    
    public typealias PopDatePickerCallback = (_ newDate : NSDate, _ forTextField : UITextField)->()
    
    var datePickerVC : PopDateViewController
    var popover : UIPopoverPresentationController?
    var textField : UITextField!
    var dataChanged : PopDatePickerCallback?
    var presented = false
    var offset : CGFloat = 8.0
    
    public init(forTextField: UITextField) {
        
        datePickerVC = PopDateViewController()
        self.textField = forTextField
        super.init()
    }
    
    public func pick(inViewController : UIViewController, initDate : NSDate?, dataChanged : @escaping PopDatePickerCallback) {
        
        if presented {
            return  // we are busy
        }
        
        datePickerVC.delegate = self
        datePickerVC.modalPresentationStyle = UIModalPresentationStyle.popover
//        datePickerVC.preferredContentSize = CGSize(500,208)
        datePickerVC.currentDate = initDate
        
        popover = datePickerVC.popoverPresentationController
        if let _popover = popover {
            
            _popover.sourceView = textField
//            _popover.sourceRect = CGRect(self.offset,textField.bounds.size.height,0,0)
            _popover.delegate = self
            self.dataChanged = dataChanged
            inViewController.present(datePickerVC, animated: true, completion: nil)
            presented = true
        }
    }
    
    //Added UITraitCollection parameter to fix the full screen popover stretch in iPhone 6s and 6s plus - Pramod Joshi
    public func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController,
        traitCollection: UITraitCollection)
        -> UIModalPresentationStyle {
            return .none
    }
    
    func datePickerVCDismissed(date : NSDate?) {
        
        if let _dataChanged = dataChanged {
            
            if let _date = date {
            
                _dataChanged(_date, textField)
        
            }
        }
        presented = false
    }
}
