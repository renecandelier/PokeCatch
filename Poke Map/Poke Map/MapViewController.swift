//
//  MapViewController.swift
//  Poke Map
//
//  Created by Rene Candelier on 7/16/16.
//  Copyright © 2016 Novus Mobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Properties
    
    let locationManager = CLLocationManager()
    var userLocation = PFGeoPoint()
    var pokemonLocations = [PFObject]()
    var pokeName = ""
    var annotationTag = 0
    var pokemonSelected = 0
    var updateMap = true
    var droppedPin: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(dropPin))
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .follow
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func dropPin(gestureRecognizer: UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        droppedPin = annotation.coordinate
        addNewPokemon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserLocation()
    }
    
    func getUserLocation() {
        
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if error != nil {
            } else if let geoPoint = geoPoint {
                self.userLocation = geoPoint
                self.downloadPokemons()
            }
        }
    }
    
    func downloadPokemons() {
        let pokemonLocationQuery = PFQuery(className: "PokeLocation")
        pokemonLocationQuery.whereKey("Location", nearGeoPoint: userLocation)
        pokemonLocationQuery.findObjectsInBackground { (pokemons, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let pokemons = pokemons, pokemons.count > 0 {
                self.pokemonLocations = pokemons
                self.loadPins(locations: pokemons)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? LocationAnnotationView {
            pokemonSelected = annotation.pokemonTag
            showPinDetails()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        let reuseId = "pokemon"
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        } else {
            anView!.annotation = annotation
        }
        if let cpa = annotation as? LocationAnnotationView {
            anView!.image = UIImage(named: cpa.name)
        }
        return anView
    }
    
    @IBAction func showPokemons(sender: AnyObject) {
        addNewPokemon()
    }
    
    @IBAction func refreshMap(sender: AnyObject) {
        downloadPokemons()
    }
    
    @IBAction func showUserLocation(sender: AnyObject) {
        recenterCurrentLocation()
    }
    
    func recenterCurrentLocation() {
        let center = self.mapView.userLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
    }
    
    func addNewPokemon() {
        performSegue(withIdentifier: "AddPokemon", sender: self)
    }
    
    func showPinDetails() {
        performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    
    func loadPins(locations: [PFObject]) {
        var annotations = [LocationAnnotationView]()
        var pokeId = 0
        for location in locations {
            if let coordinate = location["Location"] as? PFGeoPoint, let pokeName = location["Name"] as? String {
                let pokemonLocation = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
                self.pokeName = pokeName
                let pokeAnnotation = LocationAnnotationView()
                pokeAnnotation.name = pokeName.lowercased()
                pokeAnnotation.pokemonTag = pokeId
                pokeId = pokeId + 1
                pokeAnnotation.coordinate = pokemonLocation
                annotations.append(pokeAnnotation)
            }
        }
        mapView.addAnnotations(annotations)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddPokemon" {
            let upcomingNav = segue.destination as! UINavigationController
            let upcomingView = upcomingNav.viewControllers[0] as! ChoosePokemonViewController
            if let coordinate = droppedPin {
                upcomingView.pin = coordinate
            }
        } else if segue.identifier == "ShowDetail" {
            let upcoming = segue.destination as! PokemonViewController
            upcoming.pokemon = pokemonLocations[pokemonSelected]
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
        if pokemonLocations.count == 0 {
            downloadPokemons()
        }
    }
}
