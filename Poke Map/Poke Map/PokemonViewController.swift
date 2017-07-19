//
//  PokemonViewController.swift
//  Poke Map
//
//  Created by Rene Candelier on 7/17/16.
//  Copyright © 2016 Novus Mobile. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class PokemonViewController: UIViewController {

    //MARK: -Properties
    
    var pokemon: PFObject!
    
    //MARK: -Outlets
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonName: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoView.layer.masksToBounds = false
        infoView.layer.shadowOffset = CGSize(width: -1, height: 2)
        infoView.layer.shadowRadius = 5
        infoView.layer.shadowOpacity = 0.5
        if let name =  pokemon["Name"] as? String {
            pokemonName.text = name.capitalized
            pokemonImageView.image = UIImage(named: name.lowercased())
        }
        if let description = pokemon["Description"] as? String {
            descriptionLabel.text = description.capitalized
        }
        if let dateFound = pokemon["DateAndTime"] as? String {
            dateAndTimeLabel.text = "Found " + dateFound
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d, H:mm a"
            dateAndTimeLabel.text = "Found " + dateFormatter.string(from: pokemon.createdAt!)
        }
        directionButton.layer.backgroundColor = UIColor(red: 0.13, green: 0.71, blue: 0.58, alpha: 1.0).cgColor
        directionButton.setTitleColor(UIColor.white, for: .normal)
        directionButton.layer.cornerRadius = 15
        styleButton(button: likeButton)
        styleButton(button: dislikeButton)
    }
    
    func styleButton(button: UIButton) {
        button.layer.backgroundColor = UIColor(red: 0.41, green: 0.86, blue: 0.87, alpha: 1.0).cgColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 15
    }
    
    @IBAction func closeView(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func increaseLike(sender: AnyObject) {
        likeButton.alpha = 0.5
        likeButton.isEnabled = false
        if let likes = pokemon ["Like"] as? String {
            let like = Int(likes)! + 1
            pokemon["Like"] = "\(like)"
            pokemon.saveEventually()
        }
        showSuccessAlert()
    }
    @IBAction func decreaseLike(sender: UIButton) {
        dislikeButton.alpha = 0.5
        dislikeButton.isEnabled = false
        if let dislikes = pokemon ["Dislike"] as? String {
            let dislike = Int(dislikes)!
            if  dislike > 0 {
                pokemon["Dislike"] = "\(dislike - 1)"
                pokemon.saveEventually()
            }
        }
        showSuccessAlert()
    }
    
    func showSuccessAlert() {
        let successAlert = SCLAlertView()
        successAlert.showSuccess("Thanks!", subTitle: "Feedback Sent")
    }
    
    @IBAction func getDirections(sender: AnyObject) {
        if let coordinate = pokemon["Location"] as? PFGeoPoint {
            let mapAlert = UIAlertController(title: "Open Maps?", message: nil, preferredStyle: .alert)
            mapAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            mapAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                let lat = coordinate.latitude
                let long = coordinate.longitude
                UIApplication.shared.openURL(NSURL(string: "http://maps.apple.com/?daddr=\(lat),\(long)")! as URL)
            }))
            self.present(mapAlert, animated: true, completion: nil)
        } else {
            
        }
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
