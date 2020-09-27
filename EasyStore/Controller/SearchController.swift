//
//  SearchController.swift
//  EasyStore
//
//  Created by Oscar Garcia Vazquez on 9/26/20.
//  Copyright © 2020 Oscar Garcia Vazquez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SearchController : UIViewController {
    
    // MARK: - Properites
    let mapView = MKMapView()
    let manager = CLLocationManager()
    let newPin = MKPointAnnotation()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Helpers
    func configureUI() {
        getLocations()
        configureDelegates()
        configureMap()
        getUserCoordinates()
    }
    
    func configureMap() {
        let mapFrame = CGRect(x: 0,
                              y: 0,
                              width: view.frame.width,
                              height: view.frame.height)
        
        mapView.frame = mapFrame
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        view.addSubview(mapView)
    }
    
    func configureDelegates() {
        mapView.delegate = self
        manager.delegate = self
    }
    
    func getUserCoordinates() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
            
            print("DEBUG - Checking Update - determineLocation")
        }
    }
    
    func getDestinationCoordinates(address:String) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) {
            (placemarks, error) in
            
            let placemark = placemarks?.first
            let coordinates = placemark?.location?.coordinate
            
            let lat = String(describing: coordinates!.latitude)
            let lon = String(describing: coordinates!.longitude)
           
            print("Lat: \(lat), Lon: \(lon)")
        }
    }
 
    func getLocations() {
        SpaceServices.shared.getSpaces(token: (currentUser.user?.token!)!, lat: "\(manager.location?.coordinate.latitude ?? 0.0)", long: "\(manager.location?.coordinate.longitude ?? 0.0)") { (locationArray) in
            var locations = [MKPointAnnotation]()
            
            for loc in locationArray.locations {
                print("DEBUG: \(loc.address)")
                
                let coordiantes : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: loc.latitude,
                                                                                  longitude: loc.longitude)
                let dropPin = MKPointAnnotation()
                
                dropPin.coordinate = coordiantes
                dropPin.title = "Spaces Left \(loc.maxRenters - loc.currentRenters)"
                
                locations.append(dropPin)
            }
            self.mapView.showAnnotations(locations, animated: true)
        }
    }
    
    func presentRequestScreen(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard viewController is RequestSpaceController else { return true }
        let storyboard = UIStoryboard(name: "RequestSpaceController", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "RequestSpaceController") as! RequestSpaceController
        popupViewController.modalPresentationStyle = .fullScreen
        tabBarController.present(popupViewController, animated: true, completion: nil)
        return false
    }
}

// MARK: - Extensions
extension SearchController : MKMapViewDelegate {
    
}

extension SearchController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Error \(error)")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("DEBUG: \(String(describing: view.annotation?.title ?? "No title"))")
        
        let controller = RequestSpaceController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
