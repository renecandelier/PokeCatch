//
//  PokemonsCollectionViewController.swift
//  Poke Map
//
//  Created by Rene Candelier on 7/17/16.
//  Copyright © 2016 Novus Mobile. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class PokemonsCollectionViewController: UICollectionViewController {

    //MARK: - Properties
    var pokemons = [String]()
    var pokemonSelectionViewController = ChoosePokemonViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadJSONFile()
    }
    
    //TODO: Save Array in a file
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

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.bounds.size.width/3, height: view.bounds.size.width/3)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! PokemonsCollectionViewCell
        let pokemonName = pokemons[indexPath.row]
        cell.pokemonNameLabel.text = pokemonName.capitalized
        cell.pokemonImageView.image = UIImage(named: pokemonName.lowercased())
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokeName = pokemons[indexPath.row]
        pokemonSelectionViewController.pokemonImageView.image = UIImage(named: pokeName.lowercased())
        pokemonSelectionViewController.pokemonNameLabel.text = pokeName
    }

}
