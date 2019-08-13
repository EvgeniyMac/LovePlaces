////
////  MapManager.swift
////  LovePlaces
////
////  Created by Evgeniy Suprun on 8/5/19.
////  Copyright © 2019 Evgeniy Suprun. All rights reserved.
////
//
//import UIKit
//import MapKit
//
//
//class MapManager {
//    
//    let locationManager = CLLocationManager()
//   private var placeCoordinate: CLLocationCoordinate2D?
//   private let locationDistans = 250.00
//   private var directionsArray: [MKDirections] = []
//    
//
//    private func setupPlacemark(place: Place, mapView: MKMapView) {
//        
//        guard let location = place.location else {return}
//        
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(location) { (placemarks, error) in
//            if let error = error {
//                print(error)
//                return
//            }
//            
//            guard let placemarks = placemarks else {return}
//            
//            let placemark = placemarks.first
//            
//            let annotation = MKPointAnnotation()
//            annotation.title = place.name
//            annotation.subtitle = place.type
//            
//            guard let placemarkLocation = placemark?.location else {return}
//            
//            annotation.coordinate = placemarkLocation.coordinate
//            self.placeCoordinate = placemarkLocation.coordinate
//            
//            mapView.showAnnotations([annotation], animated: true)
//            mapView.selectAnnotation(annotation, animated: true)
//        }
//    }
//    
//    private func checkLocationServices(mapView: MKMapView, sequeIdentifire: String, closure: ()->()) {
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            checkLoctionAutorization(mapView: mapView, sequeIndetifire: sequeIdentifire)
//            closure()
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.checkLocationAlertController(
//                    title: "Location Service Disable in your device",
//                    message: "To enable services go to -> Privacy -> Location Service and turn On"
//                )
//            }
//        }
//    }
//    
//    //MARK: Focus map on user current place
//    
//    private func centerUserLocation(mapView: MKMapView) {
//        if let location = locationManager.location?.coordinate {
//            let region = MKCoordinateRegion(center: location, latitudinalMeters: locationDistans, longitudinalMeters: locationDistans)
//            mapView.setRegion(region, animated: true)
//        }
//    }
//    
//    // MARK: Get direction for check location User to Place
//    
//    func getDirection(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
//        
//        guard let location = locationManager.location?.coordinate else {
//            checkLocationAlertController(title: "Error", message: "Current location is not found")
//            return
//        }
//        
//        locationManager.startUpdatingLocation()
//        previusLocation = (CLLocation(latitude: location.latitude, longitude: location.longitude))
//        
//        guard let request = createDirectionRequest(coordinate: location) else {
//            checkLocationAlertController(title: "Error", message: "Destination is not found")
//            return
//        }
//        
//        let direction = MKDirections(request: request)
//        resetMapDirections(new: direction, mapView: mapView)
//        direction.calculate { (responce, error) in
//            if let error = error {
//                print(error)
//                return
//            }
//            
//            guard let responce = responce else {
//                self.checkLocationAlertController(title: "Error", message: "Direction is not available")
//                return
//            }
//            
//            for route in responce.routes {
//                
//                mapView.addOverlay(route.polyline)
//                
//                var regionRect = route.polyline.boundingMapRect
//                
//                let wPadding = regionRect.size.width * 0.5
//                let hPadding = regionRect.size.height * 0.5
//                regionRect.size.width += wPadding
//                regionRect.size.height += hPadding
//                regionRect.origin.x -= wPadding / 2
//                regionRect.origin.y -= hPadding / 2
//                
//                mapView.setVisibleMapRect(regionRect, animated: true)
//                distanceStack.isHidden = false
//                
//                if route.expectedTravelTime < 60 {
//                    let timeInterval = String(format: "%.0f", route.expectedTravelTime)
//                    self.timeLabel.text = "\(timeInterval)сек"
//                } else if route.expectedTravelTime > 3600{
//                    let timeInterval = String(format: "%.1f", route.expectedTravelTime / 3600)
//                    self.timeLabel.text = "\(timeInterval)ч"
//                } else {
//                    let timeInterval = String(format: "%.0f", route.expectedTravelTime / 60)
//                    self.timeLabel.text = "\(timeInterval)мин"
//                }
//                
//                if route.distance < 1000 {
//                    let distance = String(format: "%.0f", route.distance)
//                    self.distanceLabel.text = "\(distance)м"
//                } else {
//                    let distance = String(format: "%.1f", route.distance / 1000)
//                    self.distanceLabel.text = "\(distance)км"
//                }
//                
//            }
//        }
//    }
//    
//    // MARK: Request setup for route calculation
//    
//    private func createDirectionRequest(coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
//        
//        guard let destinationCoordinate = placeCoordinate else { return nil }
//        
//        let startingLocation = MKPlacemark(coordinate: coordinate)
//        let destination = MKPlacemark(coordinate: destinationCoordinate)
//        
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: startingLocation)
//        request.destination = MKMapItem(placemark: destination)
//        request.transportType = .automobile
//        request.requestsAlternateRoutes = true
//        
//        return request
//    }
//    
//    //MARK: Start tracking user location
//    
//    private func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
//        
//        guard let previusLocation = location else { return }
//        let center = getCenterLocation(mapView: mapView)
//        guard center.distance(from: location) > 50 else { return }
//        
//        closure(center)
//    }
//    
//    //MARK: Resetting all previously built routes before building new ones
//    
//    func resetMapDirections(new directions: MKDirections, mapView: MKMapView) {
//        mapView.removeOverlays(mapView.overlays)
//        directionsArray.append(directions)
//        let _ = directionsArray.map {$0.cancel()}
//        directionsArray.removeAll()
//    }
//    
//    
//    
//    // MARK: Check location autorization by switch
//    
//    func checkLoctionAutorization(mapView: MKMapView, sequeIndetifire: String) {
//        switch CLLocationManager.authorizationStatus() {
//        case .authorizedWhenInUse:
//            mapView.showsUserLocation = true
//            break
//        case .denied:
//            self.checkLocationAlertController(
//                title: "Location denied on this Application!",
//                message: "To enable services go to -> Privacy -> Location service -> Your application -> Use when active Application"
//            )
//            break
//        case .notDetermined:
//            locationManager.requestWhenInUseAuthorization()
//        case .restricted:
//            self.checkLocationAlertController(
//                title: "Location restricted on this Application!",
//                message: "To enable services go to -> Privacy -> Location service -> Your application -> Use when active Application"
//            )
//            break
//        case .authorizedAlways:
//            break
//        @unknown default:
//            print("New case is available!")
//        }
//    }
//
//    // MARK: Alert controller Location service not avalaible
//    
//    private func checkLocationAlertController(title: String, message: String) {
//        
//        let mapAC = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default)
//        
//        mapAC.addAction(okAction)
//        
//        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
//        alertWindow.rootViewController = UIViewController()
//        alertWindow.windowLevel = UIWindow.Level.alert + 1
//        alertWindow.makeKeyAndVisible()
//        alertWindow.rootViewController?.present(mapAC, animated: true, completion: nil)
//        
//    }
//}
