//
//  MapViewController.swift
//  LovePlaces
//
//  Created by Evgeniy Suprun on 29/07/2019.
//  Copyright © 2019 Evgeniy Suprun. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var place = Place()
    let anotationIdentifire = "anotationIdentifire"
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPlacemark()
    }
    
    @IBAction func closeMapButton() {
        dismiss(animated: true, completion: nil)
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

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {return nil}
        
        var anotationView = mapView.dequeueReusableAnnotationView(withIdentifier: anotationIdentifire) as? MKPinAnnotationView
        
        if anotationView == nil {
            anotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: anotationIdentifire)
            anotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            anotationView?.leftCalloutAccessoryView = imageView
        }
        return anotationView
    }
    
}
