//
//  RestaurantSearchViewController.swift
//  AllTrailsAtLunch
//
//  Created by Evelyn C Cordner on 6/2/20.
//  Copyright © 2020 EvelynCordner. All rights reserved.
//

import UIKit
import MapKit

fileprivate enum Views {
    case map
    case list
}

fileprivate let USER_DEFUALTS_FAVORITES_KEY = "RestaurantFavorites"

class RestaurantSearchViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toggleViewButton: UIButton!
    
    fileprivate var restaurants: [Restaurant] = []
    fileprivate var currentView = Views.map
    fileprivate var search = ""
    fileprivate var location: CLLocationCoordinate2D?
    fileprivate let locationManager = CLLocationManager()
    fileprivate var favorites:[String] = []
     
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @IBAction func switchView(sender: UIButton) {
        if currentView == Views.map {
            UIView.animate(withDuration:0.5, animations: {
                self.mapView.alpha = 0
                self.tableView.alpha = 1
            })
            self.toggleViewButton.setTitle("Map", for: UIControl.State.normal)
            self.toggleViewButton.setImage(#imageLiteral(resourceName: "Map Icon"), for: UIControl.State.normal)
            currentView = Views.list
        } else {
            UIView.animate(withDuration:0.5, animations: {
                self.mapView.alpha = 1
                self.tableView.alpha = 0
            })
            self.toggleViewButton.setTitle("List", for: UIControl.State.normal)
            self.toggleViewButton.setImage(#imageLiteral(resourceName: "List Icon"), for: UIControl.State.normal)
            currentView = Views.map
        }
    }
}

private extension RestaurantSearchViewController {
    
    func initialize() {
        // load favorites from NSUserDefaults
        favorites = UserDefaults.standard.stringArray(forKey: USER_DEFUALTS_FAVORITES_KEY) ?? [String]()
        
        // search text field
        searchTextField.delegate = self
        searchTextField.returnKeyType = UIReturnKeyType.search
        searchTextField.rightViewMode = UITextField.ViewMode.always
        searchTextField.rightView = UIImageView.init(image: #imageLiteral(resourceName: "Search Icon"))
        
        // toggle view button
        toggleViewButton.imageView?.contentMode = .scaleAspectFit
        
        // location & map view
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
                showLocationPermissionAlert()
            }
        }
        
        mapView.showsUserLocation = true;
    }
    
    func zoomToLocation(_ userLocation: CLLocationCoordinate2D) {
        location = userLocation
        mapView.setRegion(MKCoordinateRegion.init(center: userLocation, latitudinalMeters: 2000, longitudinalMeters: 8000), animated: true)
        searchForRestaurants()
    }
    
    func showLocationPermissionAlert() {
        let alert = UIAlertController(title: "AllTrails at lunch needs your location", message: "Please enable location permissions in the settings app of your phone to continue using this application.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    func searchForRestaurants() {
        guard let location = location else {return}
        fetchRestaurants(search:search, location:location) { [weak self] (results, error) in
            if let strongSelf = self {
                var restaurants:[Restaurant] = []
                if let newRestaurants = results {
                    restaurants = newRestaurants
                }
                strongSelf.restaurants = restaurants
            
                DispatchQueue.main.async {
                    // Refresh the Map View
                    strongSelf.mapView.removeAnnotations(strongSelf.mapView.annotations)
                    strongSelf.mapView.addAnnotations(restaurants)
                    
                    // Refresh the Table View
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }
}

extension RestaurantSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantTableViewCell
        let restaurant = restaurants[indexPath.row]
        
        cell.nameLabel.text = restaurant.name + " (\(restaurant.rating))"
        cell.ratingsView.rating = CGFloat(restaurant.rating)
        cell.ratingsLabel.text = "(\(restaurant.numberOfRatings))"
        cell.favorite = favorites.contains(restaurant.id)
        
        if let imgReference = restaurant.photos?[0].reference {
            cell.setImage(from: imgReference)
        }
        
        return cell
    }
}

extension RestaurantSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // add or remove the restaurant from the favorites list
        let restaurant = restaurants[indexPath.row]
        if favorites.contains(restaurant.id) {
            if let index = favorites.firstIndex(of: restaurant.id) {
                favorites.remove(at: index)
            }
        } else {
            favorites.append(restaurant.id)
        }
        
        // save to NSUserDefaults
        UserDefaults.standard.set(favorites, forKey: USER_DEFUALTS_FAVORITES_KEY)
        
        // update the cell
        let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
        cell.favorite = favorites.contains(restaurant.id)
    }
}

extension RestaurantSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.searchTextField {
            textField.resignFirstResponder()
            if let searchTerm = textField.text {
                search = searchTerm
                searchForRestaurants()
            }
            return false;
        }
        return true
    }
}

extension RestaurantSearchViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "AnnotationView"
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        var annotationView:MKAnnotationView?
        if let customAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView = customAnnotationView
            annotationView?.annotation = annotation
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView = av
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = #imageLiteral(resourceName: "Full Pin")
            
            // add ratings view to detail callout
            let ratingsView = RatingsView.init()
            ratingsView.rating = CGFloat((annotation as! Restaurant).rating)
            
            let widthConstraint = NSLayoutConstraint(item: ratingsView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
            let heightConstraint = NSLayoutConstraint(item: ratingsView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
            ratingsView.addConstraint(widthConstraint)
            ratingsView.addConstraint(heightConstraint)
            annotationView.detailCalloutAccessoryView = ratingsView
            
        }
        
        return annotationView
    }
}

extension RestaurantSearchViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            showLocationPermissionAlert()
        }
    }
    
    func  locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }
        if currentLocation.horizontalAccuracy < 500 && location == nil {
            zoomToLocation(currentLocation.coordinate)
            manager.stopUpdatingLocation()
        }
    }
}
