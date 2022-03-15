//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Владислав Колундаев on 07.03.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
  func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
  
  var place = Place()
  var mapViewControllerDelegate: MapViewControllerDelegate?
  
  let annotationIdentifire = "annotationIdentifire"
  let locationManager = CLLocationManager()
  var incomeSegueIdentifire = ""
  var directionsArray: [MKDirections] = []
  var placeCoordinate: CLLocationCoordinate2D?
  var previosLocation: CLLocation? {
    didSet {
      startTrackingUserLocation()
    }
  }
  
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet var pinImage: UIImageView!
  @IBOutlet var doneButton: UIButton!
  @IBOutlet var goButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addressLabel.text = ""
    mapView.delegate = self
    setupMapView()
    checkLocationServices()
  }
  
  @IBAction func centerViewInUserLocation() {
    showUserLocation()
  }
  
  @IBAction func cancelAction() {
    dismiss(animated: true)
  }
  
  @IBAction func doneButtonPressed() {
    mapViewControllerDelegate?.getAddress(addressLabel.text)
    dismiss(animated: true)
  }
  
  @IBAction func goButtonPressed() {
    getDerections()
  }
  
  private func setupMapView() {
    goButton.isHidden = true
    
    if incomeSegueIdentifire == "showMap" {
      goButton.isHidden = false
      setupPlaceMark()
      addressLabel.isHidden = true
      pinImage.isHidden = true
      doneButton.isHidden = true
    }
  }
  
  private func resetMapView(with directions: MKDirections) {
    mapView.removeOverlays(mapView.overlays)
    directionsArray.append(directions)
    let _ = directionsArray.map({ $0.cancel() })
    directionsArray.removeAll()
  }
  
  private func setupPlaceMark() {
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
      
      annotation.title = self.place.name
      annotation.subtitle = self.place.type
      
      guard let placemarkLocation = placemark?.location else { return }
      annotation.coordinate = placemarkLocation.coordinate
      self.placeCoordinate = placemarkLocation.coordinate
      
      self.mapView.showAnnotations([annotation], animated: true)
      self.mapView.selectAnnotation(annotation, animated: true)
    }
  }
  
  private func checkLocationServices() {
    if CLLocationManager.locationServicesEnabled() {
      setupLocationManager()
      checkLocationAuthorizathion()
    } else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.showAlert(
          title: "Your location is not Availeble",
          message: "To give permition Go to: Settings –> MyPlaces –> Location"
        )
      }
    }
  }
  
  private func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
  
  private func checkLocationAuthorizathion() {
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
      if incomeSegueIdentifire == "getAddress" { showUserLocation() }
      break
    case .authorized:
      break
    @unknown default:
      print("New case is avilable")
    }
  }
  
  private func showUserLocation() {
    if let location = locationManager.location?.coordinate {
      let region = MKCoordinateRegion(center: location,
                                      latitudinalMeters: 5000,
                                      longitudinalMeters: 5000)
      mapView.setRegion(region, animated: true)
    }
  }
  private func startTrackingUserLocation() {
    guard let previosLocation = previosLocation else { return }
    let center = getCenterLocation(for: mapView)
    guard center.distance(from: previosLocation) > 50 else { return }
    self.previosLocation = center
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      self.showUserLocation()
    }
  }
  private func getDerections() {
    guard let location = locationManager.location?.coordinate else {
      showAlert(title: "Error", message: "Current location is not found")
      return
    }
    
    locationManager.startUpdatingHeading()
    previosLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
    
    guard let request = createLocationRequest(from: location) else {
      showAlert(title: "Error", message: "Direction is not found")
      return
    }
    
    let derection = MKDirections(request: request)
    resetMapView(with: derection)
    
    derectionc.calculate { respons, error in
      if let error = error {
        print(error)
        return
      }
      
      guard let respons = respons else {
        self.showAlert(title: "Error", message: "Directions is not available")
        return
      }
      
      for route in respons.routes {
        self.mapView.addOverlay(route.polyline)
        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
      }
    }
  }
  
  private func createLocationRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
  
  private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
    let latitude = mapView.centerCoordinate.latitude
    let longtitude = mapView.centerCoordinate.longitude
    
    return CLLocation(latitude: latitude, longitude: longtitude)
  }
  
  private func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default)
    
    alert.addAction(okAction)
    present(alert, animated: true)
  }
}

extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    guard !(annotation is MKUserLocation) else { return nil }
    
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifire) as? MKMarkerAnnotationView
    
    if annotationView == nil {
      annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifire)
      annotationView?.canShowCallout = true
    }
    
    if let imageData = place.imageData {
      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
      imageView.layer.cornerRadius = 10
      imageView.clipsToBounds = true
      imageView.image = UIImage(data: imageData)
      annotationView?.rightCalloutAccessoryView = imageView
    }
    
    return annotationView
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    let geocoder = CLGeocoder()
    let center = getCenterLocation(for: mapView)
    
    if incomeSegueIdentifire == "showMap" && previosLocation != nil {
      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        self.showUserLocation()
      }
    }
    
    geocoder.cancelGeocode()
    
    geocoder.reverseGeocodeLocation(center) { placemarks, error in
      if let error = error {
        print(error)
        return
      }
      
      guard let placemarks = placemarks else { return }
      
      let placemark = placemarks.first
      let streetName = placemark?.thoroughfare
      let houseNumber = placemark?.subThoroughfare
      
      DispatchQueue.main.async {
        
        if streetName != nil, houseNumber != nil {
          self.addressLabel.text = "\(streetName!), \(houseNumber!)"
        } else if streetName != nil {
          self.addressLabel.text = "\(streetName!)"
        } else {
          self.addressLabel.text = ""
        }
      }
    }
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
    render.strokeColor = .blue
    
    return render
  }
}

extension MapViewController: CLLocationManagerDelegate {
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    checkLocationAuthorizathion()
  }
}
