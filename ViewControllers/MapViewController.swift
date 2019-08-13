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
    let locationDistans = 250.00
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var previusLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var showWayOutlet: UIButton!
    
    @IBOutlet weak var distanceStack: UIStackView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceStack.isHidden = true
        mapView.delegate = self
        setupPlacemark()
        checkLocationServices()
    }
    
    
    @IBAction func closeMapButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func centerUserButton() {
        centerUserLocation()
    }
    
    // MARK: - Center place location
    
    @IBAction func showPlaceInMap(_ sender: Any) {
       setupPlacemark()
       checkLocationServices()
    }
    
    @IBAction func showWayButton(_ sender: UIButton) {
        getDirection()
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
            self.placeCoordinate = placemarkLocation.coordinate
            
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
    
    private func centerUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: locationDistans, longitudinalMeters: locationDistans)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getCenterLocation(mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let logtitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: logtitude)
    }
    
    //MARK: Start tracking user location
    
    private func startTrackingUserLocation() {
        
        guard let previusLocation = previusLocation else { return }
        let center = getCenterLocation(mapView: mapView)
        guard center.distance(from: previusLocation) > 50 else { return }
        self.previusLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.centerUserLocation()
        }
    }
    
    
    // MARK: Get direction for check location User to Place
    
    func getDirection() {
        
        guard let location = locationManager.location?.coordinate else {
            checkLocationAlertController(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previusLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionRequest(coordinate: location) else {
            checkLocationAlertController(title: "Error", message: "Destination is not found")
            return
        }
        
        let direction = MKDirections(request: request)
        resetMapDirections(directions: direction)
        
        direction.calculate { (responce, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let responce = responce else {
                self.checkLocationAlertController(title: "Error", message: "Direction is not available")
                return
            }
            
            for route in responce.routes {
                
                self.mapView.addOverlay(route.polyline)
                
                var regionRect = route.polyline.boundingMapRect
        
                //
                let wPadding = regionRect.size.width * 0.5
                let hPadding = regionRect.size.height * 0.5
                regionRect.size.width += wPadding
                regionRect.size.height += hPadding
                regionRect.origin.x -= wPadding / 2
                regionRect.origin.y -= hPadding / 2
                
                self.mapView.setVisibleMapRect(regionRect, animated: true)
                self.distanceStack.isHidden = false
                
                if route.expectedTravelTime < 60 {
                    let timeInterval = String(format: "%.0f", route.expectedTravelTime)
                    self.timeLabel.text = "\(timeInterval)сек"
                } else if route.expectedTravelTime > 3600{
                    let timeInterval = String(format: "%.1f", route.expectedTravelTime / 3600)
                    self.timeLabel.text = "\(timeInterval)ч"
                } else {
                    let timeInterval = String(format: "%.0f", route.expectedTravelTime / 60)
                    self.timeLabel.text = "\(timeInterval)мин"
                }
                
                if route.distance < 1000 {
                    let distance = String(format: "%.0f", route.distance)
                    self.distanceLabel.text = "\(distance)м"
                } else {
                    let distance = String(format: "%.1f", route.distance / 1000)
                    self.distanceLabel.text = "\(distance)км"
                }
                
            }
        }
    }
    
    private func createDirectionRequest(coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func resetMapDirections(directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel()}
        directionsArray.removeAll()
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
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.7764705882, alpha: 1)
        
        return renderer
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLoctionAutorization()
    }
}
