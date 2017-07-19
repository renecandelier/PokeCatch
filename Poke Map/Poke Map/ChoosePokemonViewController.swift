//
//  ChoosePokemonViewController.swift
//  Poke Map
//
//  Created by Rene Candelier on 7/19/16.
//  Copyright © 2016 Novus Mobile. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class ChoosePokemonViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: -Outlets
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var dateAndTimeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // MARK: -Properties
    var pokemonCollectionView: PokemonsCollectionViewController?
    var popDatePicker : PopDatePicker?
    var pin: CLLocationCoordinate2D?
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Load Date & Time with todays date
        let todaysDate = NSDate()
        dateFormatter.dateFormat = "EEEE, MMM d, H:mm a"
        let dateFormatted = dateFormatter.string(from: todaysDate as Date)
        dateAndTimeTextField.text = dateFormatted
        popDatePicker = PopDatePicker(forTextField: dateAndTimeTextField)
        dateAndTimeTextField.delegate = self
        descriptionTextField.delegate = self
        let textViewToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
            //CGRect(0, 0, self.view.frame.size.width, 50)
        textViewToolbar.tintColor = UIColor(red:0.10, green:0.74, blue:0.83, alpha:1.00)
        textViewToolbar.barStyle = .default
        textViewToolbar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(resign))]
        
        textViewToolbar.sizeToFit()
        descriptionTextField.inputAccessoryView = textViewToolbar

//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
//        tapRecognizer.numberOfTapsRequired = 1
//        view.addGestureRecognizer(tapRecognizer)
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
//        view.endEditing(true)
//        resign()
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == descriptionTextField {
            descriptionTextField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField === dateAndTimeTextField) {
            resign()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let initDate : NSDate? = formatter.date(from: dateAndTimeTextField.text!) as NSDate?
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : NSDate, forTextField : UITextField) -> () in
                let dateFormatted = self.dateFormatter.string(from: newDate as Date)
                forTextField.text = dateFormatted
            }
            popDatePicker!.pick(inViewController: self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        } else {
            return true
        }
    }
    
    func resign() {
        dateAndTimeTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
    }
    
    func createPokemonLocation(name: String) {
        if let newPin = pin {
            let geoPoint = PFGeoPoint(latitude: newPin.latitude, longitude: newPin.longitude)
            saveLocationToParse(geoPoint: geoPoint, name: name)
        } else {
            PFGeoPoint.geoPointForCurrentLocation(inBackground: { (geoPoint, error) in
                if error != nil {
                } else if let geoPoint = geoPoint {
                    self.saveLocationToParse(geoPoint: geoPoint, name: name)
                }
            })
        }
    }
    
    func saveLocationToParse(geoPoint: PFGeoPoint, name: String) {
        let pokemonLocation = PFObject(className: "PokeLocation")
        pokemonLocation["Name"] = name
        pokemonLocation["Location"] = geoPoint
        pokemonLocation["Like"] = "0"
        pokemonLocation["Dislike"] = "0"
        if (self.descriptionTextField.text?.characters.count)! > 0 {
            pokemonLocation["Description"] = self.descriptionTextField.text
        }
        pokemonLocation["DateAndTime"] = self.dateAndTimeTextField.text
        pokemonLocation.saveInBackground { (saved, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if saved {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let successAlert = SCLAlertView(appearance: appearance)
                successAlert.addButton("Great!") {
                    self.close()
                }
                successAlert.showSuccess("Success", subTitle: "Pokémon Location Saved")
            }
        }
    }
    
    @IBAction func saveLocation(sender: AnyObject) {
        resign()
        if dateAndTimeTextField.text?.characters.count == 0 {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let errorAlert = SCLAlertView(appearance: appearance)
            errorAlert.addButton("Got It") {
                self.dateAndTimeTextField.becomeFirstResponder()
            }
            errorAlert.showError("Missing Fields", subTitle: "Please Enter Date & Time")
        } else {
            createPokemonLocation(name: pokemonNameLabel.text!)
        }
    }
    
    @IBAction func closeView(sender: AnyObject) {
        close()
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedPokemonCollection" {
            let upcoming = segue.destination as! PokemonsCollectionViewController
            pokemonCollectionView = upcoming
            upcoming.pokemonSelectionViewController = self
        }
    }
    
}
