//
//  DistanceViewController.swift
//  Practical
//
//  Created by Anil on 14/11/19.
//  Copyright © 2019 Anil. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DistanceViewController: ViewController {
    
    var distanceFloat2: Float = 5.540
    var isSwitchOn: Bool = false
    
    @IBOutlet weak var lbltraveledDistance: UILabel!
    @IBOutlet var mySwitch: UISwitch?

    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var startDate: Date!
    var traveledDistance: Double = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(newLocationAdded(_:)), name: .newLocationSaved, object: nil)
        mySwitch?.addTarget(self, action: #selector(DistanceViewController.switchIsChanged(mySwitch:)), for: UIControl.Event.valueChanged)

        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.distanceFilter = 50
            mapview.showsUserLocation = true
            mapview.userTrackingMode = .follow
        }
       // Getgeocoder()
        checkLocationServices()

     

//        let coordinate₀ = CLLocation(latitude: 5.0, longitude: 5.0)
//        let coordinate₁ = CLLocation(latitude: 5.0, longitude: 3.0)
//        
//        let distanceInMeters = coordinate₀.distance(from: coordinate₁)

        // Do any additional setup after loading the view.
    }
    override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters,longitudinalMeters: regionInMeters)
        mapview.setRegion(region, animated: true)
        //CustaddAnnotationsOnMap(locationToPoint: location)
        addAnnotationsOnMap(locationToPoint: location)
        print(locations.last ?? "none")
        if startDate == nil {
            startDate = Date()
        } else {
            print("elapsedTime:", String(format: "%.0fs", Date().timeIntervalSince(startDate)))
        }
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            traveledDistance += lastLocation.distance(from: location)
          //  let meterDistance = location.distance(from: destination)
            distanceFloat2 = Float(traveledDistance / 1609.344)
            print("Traveled Distance:",  traveledDistance)
            print("Straight Distance:", startLocation.distance(from: locations.last!))
            lbltraveledDistance.text =  "Meters:" + "\(distanceFloat2)"
        }
        lastLocation = locations.last
        if isSwitchOn == true{
            guard let currentLocation = mapview.userLocation.location else {
                return
            }
            LocationsStorage.shared.saveCLLocationToDisk(currentLocation)
        }
        
    }
    
    @objc func newLocationAdded(_ notification: Notification) {
        guard (notification.userInfo?["location"] as? Location) != nil else {
            return
        }
        

//        let annotation = annotationForLocation(location)
//        mapView.addAnnotation(annotation)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//Mark: UIAction
//MARK

extension DistanceViewController{
    
    @objc func switchIsChanged(mySwitch: UISwitch) {
        if mySwitch.isOn {
            isSwitchOn = true
           // "UISwitch is ON"
        } else {
            isSwitchOn = false
            // "UISwitch is OFF"
        }
    }
}
