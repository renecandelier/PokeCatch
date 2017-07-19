//
//  PokemonTableViewController.swift
//  Poke Map
//
//  Created by Rene Candelier on 7/16/16.
//  Copyright © 2016 Novus Mobile. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class PokemonTableViewController: UITableViewController {
    
    var pokemons = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadJSONFile()
    }
    
    func loadJSONFile() {
        if let path = Bundle.main.path(forResource: "pokemon", ofType: "json") {
            if let jsonData = NSData(contentsOfFile:path) {
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData as Data, options: []) as! [[String : AnyObject]]
                    for result in json {
                        if let name = result["name"] as? String {
                            self.pokemons.append(name.capitalized)
                        }
                    }
                } catch {
                    
                }
            }
        }
    }
    
    //TODO: Save JSON in an array in file
    //TODO: load images
    //TODO: Add save Button
    //TODO: Add Description
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! PokemonTableViewCell
        let pokemonName = pokemons[indexPath.row]
        cell.pokemonNameLabel.text = pokemonName.capitalized
        cell.pokemonImageView.image = UIImage(named: pokemonName.lowercased())
        cell.pokemonNumberLabel.text = "#\(indexPath.row)"
        return cell
    }
    
    @IBAction func savePokemonLocation(sender: UIBarButtonItem) {
    }
    
    func createPokemonLocation(name: String) {
        
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if error != nil {
            } else if let geoPoint = geoPoint {
                let test = PFObject(className: "PokeLocation")
                test["Name"] = name
                test["Location"] = geoPoint
                test.saveInBackground(block: { (saved, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if saved {
                        
                        let successAlert = SCLAlertView()
                        successAlert.showSuccess("Success", subTitle: "Pokémon Saved")
                        
                        
                        //                        let alertViewResponder: SCLAlertViewResponder = SCLAlertView().showSuccess("Pokémon Saved", subTitle: "")
                        //                        alertViewResponder.setTitle("Pokémon Saved")
                    }
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.createPokemonLocation(name: pokemons[indexPath.row])

    }
    
}
