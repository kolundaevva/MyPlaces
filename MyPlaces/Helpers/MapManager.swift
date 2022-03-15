//
//  MapManager.swift
//  MyPlaces
//
//  Created by Владислав Колундаев on 15.03.2022.
//

import UIKit
import MapKit

class MapManager {
  let locationManager = CLLocationManager()
  
  private var directionsArray: [MKDirections] = []
  private var placeCoordinate: CLLocationCoordinate2D?
  
  func setupPlaceMark(place: Place, mapView: MKMapView) {
    guard let location = place.location else { return }
    
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(location) { (placemarks, error) in
      if let error = error {
        print("\(error)")
        return
      }
      guard let placemarks = placemarks else { return }
      
      let placemark = placemarks.first
      
      let annotation = MKPointAnnotation()
      
      annotation.title = place.name
      annotation.subtitle = place.type
      
      guard let placemarkLocation = placemark?.location else { return }
      annotation.coordinate = placemarkLocation.coordinate
      self.placeCoordinate = placemarkLocation.coordinate
      
      mapView.showAnnotations([annotation], animated: true)
      mapView.selectAnnotation(annotation, animated: true)
    }
  }
  
  func checkLocationServices(mapView: MKMapView, segueIdentifire: String, clouser: () -> ()) {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      checkLocationAuthorizathion(mapView: mapView, incomeSegueIdentifire: segueIdentifire)
      clouser()
    } else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.showAlert(
          title: "Your location is not Availeble",
          message: "To give permition Go to: Settings –> MyPlaces –> Location"
        )
      }
    }
  }
  
  func checkLocationAuthorizathion(mapView: MKMapView, incomeSegueIdentifire: String) {
    switch locationManager.authorizationStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
      break
    case .restricted:
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.showAlert(
          title: "Your location is not Availeble",
          message: "To give permition Go to: Settings –> MyPlaces –> Location"
        )
      }
      break
    case .denied:
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.showAlert(
          title: "Your location is not Availeble",
          message: "To give permition Go to: Settings –> MyPlaces –> Location"
        )
      }
      break
    case .authorizedAlways:
      break
    case .authorizedWhenInUse:
      mapView.showsUserLocation = true
      if incomeSegueIdentifire == "getAddress" { showUserLocation(mapView: mapView) }
      break
    case .authorized:
      break
    @unknown default:
      print("New case is avilable")
    }
  }
  
  func showUserLocation(mapView: MKMapView) {
    if let location = locationManager.location?.coordinate {
      let region = MKCoordinateRegion(center: location,
                                      latitudinalMeters: 5000,
                                      longitudinalMeters: 5000)
      mapView.setRegion(region, animated: true)
    }
  }
  
  func getDerections(for mapView: MKMapView, previosLocation: (CLLocation) -> ()) {
    guard let location = locationManager.location?.coordinate else {
      showAlert(title: "Error", message: "Current location is not found")
      return
    }
    
    locationManager.startUpdatingHeading()
    previosLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
    
    guard let request = createLocationRequest(from: location) else {
      showAlert(title: "Error", message: "Direction is not found")
      return
    }
    
    let direction = MKDirections(request: request)
    resetMapView(with: direction, mapView: mapView)
    
    direction.calculate { respons, error in
      if let error = error {
        print(error)
        return
      }
      
      guard let respons = respons else {
        self.showAlert(title: "Error", message: "Directions is not available")
        return
      }
      
      for route in respons.routes {
        mapView.addOverlay(route.polyline)
        mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
      }
    }
  }
  
  func createLocationRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
    guard let destinationCoordinate = placeCoordinate else { return nil }
    let startingLocation = MKPlacemark(coordinate: coordinate)
    let destination = MKPlacemark(coordinate: destinationCoordinate)
    
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: startingLocation)
    request.destination = MKMapItem(placemark: destination)
    request.requestsAlternateRoutes = true
    request.transportType = .automobile
    
    return request
  }
  
  func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, clouser: (_ currentLocation: CLLocation) -> ()) {
    guard let previosLocation = location else { return }
    let center = getCenterLocation(for: mapView)
    guard center.distance(from: previosLocation) > 50 else { return }
    
    clouser(center)
  }
  
  func resetMapView(with directions: MKDirections, mapView: MKMapView) {
    mapView.removeOverlays(mapView.overlays)
    directionsArray.append(directions)
    let _ = directionsArray.map({ $0.cancel() })
    directionsArray.removeAll()
  }
  
  func getCenterLocation(for mapView: MKMapView) -> CLLocation {
    let latitude = mapView.centerCoordinate.latitude
    let longtitude = mapView.centerCoordinate.longitude
    
    return CLLocation(latitude: latitude, longitude: longtitude)
  }
  
  private func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default)
    
    alert.addAction(okAction)
    
    let alertWindow = UIWindow(frame: UIScreen.main.bounds)
    alertWindow.rootViewController = UIViewController()
    alertWindow.windowLevel = UIWindow.Level.alert + 1
    alertWindow.makeKeyAndVisible()
    alertWindow.rootViewController?.present(alert, animated: true)
  }
}
