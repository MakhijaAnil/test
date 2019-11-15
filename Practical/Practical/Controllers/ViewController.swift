//
//  ViewController.swift
//  Practical
//
//  Created by Anil on 14/11/19.
//  Copyright © 2019 Anil. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapview: MKMapView!
    let LocationManager = CLLocationManager()
    
    var pointAnnotation:CustomPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    let regionInMeters:Double = 10000
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        checkLocationServices()
       // BackgroundLocationManager.instance.start()

        
    }
    
    //function to add annotation to map view
    func addAnnotationsOnMap(locationToPoint : CLLocation){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        let geoCoder = CLGeocoder ()
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                let addressDictionary =  "\(placemark.subThoroughfare ?? ""), \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.subLocality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
                print("\(addressDictionary)")//placemark.addressDictionary;
                annotation.title = addressDictionary//addressDictionary["Name"] as? String
                self.mapview.addAnnotation(annotation)
            }
        })
    }
    
    func setupLocationManager() {
        LocationManager.delegate = self
        LocationManager.desiredAccuracy = kCLLocationAccuracyBest

    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // Setup our location manager
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            // Show alert lattring the user know  they have to turn this on
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = LocationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapview.setRegion(region, animated: true)
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            //Do Map Stuff
            mapview.showsUserLocation = true
            mapview.mapType = MKMapType.standard
            centerViewOnUserLocation()
            LocationManager.startUpdatingLocation()
            break
        case .denied:
            //Show alert instructing  them how to turn on permission
            break
        case .notDetermined:
            LocationManager.requestWhenInUseAuthorization()
        case .restricted:
            //Show an alert lettring them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default: break
            //
        }
    }


}

//MARK:- MapKit Delegate Function
//MARK

extension ViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters,longitudinalMeters: regionInMeters)
            mapview.setRegion(region, animated: true)
        addAnnotationsOnMap(locationToPoint: location)
        
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    //MARK: - Custom Annotation
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPointAnnotation
        annotationView?.image = UIImage(named: customPointAnnotation.pinCustomImageName)
        
        return annotationView
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

