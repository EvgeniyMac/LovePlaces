//
//  MapViewController.swift
//  LovePlaces
//
//  Created by Evgeniy Suprun on 29/07/2019.
//  Copyright © 2019 Evgeniy Suprun. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var place = Place()
    let anotationIdentifire = "anotationIdentifire"
    let locationManager = CLLocationManager()
    let locationDistans = 500.00
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPlacemark()
        checkLocationServices()
    }
    
    
    @IBAction func closeMapButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func centerViewInUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: locationDistans, longitudinalMeters: locationDistans)
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    private func setupPlacemark() {
        
        guard let location = place.location else {return}
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLoctionAutorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.checkLocationAlertController(
                    title: "Location Service Disable in your device",
                    message: "To enable services go to -> Privacy -> Location Service and turn On"
                )
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: Alert controller Location service not avalaible
    
    private func checkLocationAlertController(title: String, message: String) {
        
        let mapAC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)

        mapAC.addAction(okAction)
        present(mapAC, animated: true, completion: nil)
    }
    
    // MARK: Check location autorization by switch
    
    private func checkLoctionAutorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            self.checkLocationAlertController(
                title: "Location denied on this Application!",
                message: "To enable services go to -> Privacy -> Location service -> Your application -> Use when active Application"
            )
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.checkLocationAlertController(
                title: "Location restricted on this Application!",
                message: "To enable services go to -> Privacy -> Location service -> Your application -> Use when active Application"
            )
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available!")
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {return nil}
        
        var anotationView = mapView.dequeueReusableAnnotationView(withIdentifier: anotationIdentifire) as? MKPinAnnotationView
        
        if anotationView == nil {
            anotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: anotationIdentifire)
            anotationView?.canShowCallout = true
        }
        
        // Show place image with annotation
        
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            anotationView?.leftCalloutAccessoryView = imageView
        }
        return anotationView
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLoctionAutorization()
    }
}
