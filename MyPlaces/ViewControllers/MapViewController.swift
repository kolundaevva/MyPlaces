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
  
  let mapManager = MapManager()
  var place = Place()
  var mapViewControllerDelegate: MapViewControllerDelegate?
  
  let annotationIdentifire = "annotationIdentifire"
  var incomeSegueIdentifire = ""
  
  var previosLocation: CLLocation? {
    didSet {
      mapManager.startTrackingUserLocation(
        for: mapView,
        and: previosLocation) { currentLocation in
             
             self.previosLocation = currentLocation
             
             DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
               self.mapManager.showUserLocation(mapView: self.mapView)
             }
           }
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
  }
  
  @IBAction func centerViewInUserLocation() {
    self.mapManager.showUserLocation(mapView: mapView)
  }
  
  @IBAction func cancelAction() {
    dismiss(animated: true)
  }
  
  @IBAction func doneButtonPressed() {
    mapViewControllerDelegate?.getAddress(addressLabel.text)
    dismiss(animated: true)
  }
  
  @IBAction func goButtonPressed() {
    self.mapManager.getDerections(for: mapView) { location in
      self.previosLocation = location
    }
  }
  
  private func setupMapView() {
    goButton.isHidden = true
    
    mapManager.checkLocationServices(mapView: mapView, segueIdentifire: incomeSegueIdentifire) {
      mapManager.locationManager.delegate = self
    }
    
    if incomeSegueIdentifire == "showMap" {
      mapManager.setupPlaceMark(place: place, mapView: mapView)
      goButton.isHidden = false
      addressLabel.isHidden = true
      pinImage.isHidden = true
      doneButton.isHidden = true
    }
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
    let center = mapManager.getCenterLocation(for: mapView)
    
    if incomeSegueIdentifire == "showMap" && previosLocation != nil {
      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        self.mapManager.showUserLocation(mapView: self.mapView)
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
    mapManager.checkLocationAuthorizathion(mapView: mapView,
                                           incomeSegueIdentifire: incomeSegueIdentifire)
  }
}
