//
//  ViewController.swift
//  SunInfo
//
//  Created by onur on 28.07.2024.
//

import UIKit
import Alamofire
import CoreLocation
import MapKit

class HomePageVC: UIViewController{
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var sunRiseLabel: UILabel!
    @IBOutlet weak var sunSetLabel: UILabel!
    @IBOutlet weak var solarNoonLabel: UILabel!
    @IBOutlet weak var dayLengthLabel: UILabel!
    @IBOutlet weak var utcLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var theDate: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    let dateFormatter = DateFormatter()
    var utc = 0
    var sunInfo: SunResults?
    var clientInfo: WorldTimeAPI?
    
    var cityData = [String]()
    
    let locationManager = CLLocationManager()
    
    let viewModel = HomePageVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        theDate = dateFormatter.string(from: datePicker.date)
        
        mapView.delegate = self
        
        //Starting location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Authorization for location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        latitude = (locationManager.location?.coordinate.latitude)!
        longitude = (locationManager.location?.coordinate.longitude)!
        
        _ = viewModel.sunInfoRx.subscribe(onNext: { sunResult in
            self.sunInfo = sunResult
        })
        
        
        _ = viewModel.clientInfoRx.subscribe(onNext: { clientInfoRx in
            self.clientInfo = clientInfoRx
        })
        
        _ = viewModel.cityDataRx.subscribe(onNext: { cityDataRx in
            self.cityData = cityDataRx
            self.viewModel.addPin(latitude: self.latitude, longitude: self.longitude, province: self.cityData.first ?? "" , district: self.cityData.last ?? "", map: self.mapView)
            self.viewModel.getTimeZone(for: CLLocation(latitude: self.latitude, longitude: self.longitude)) { offset in
                self.utc = offset
            }
        })
        
        viewModel.getClientInfo()
        viewModel.getSunInfo(lat: latitude, lng: longitude, date: theDate)
        viewModel.reverseGeocode(location: CLLocation(latitude: latitude, longitude: longitude))
        
        
        self.theDate = self.dateFormatter.string(from: self.datePicker.date)
        
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        //Add gesture recognizer to mapview
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        self.viewModel.dateChanged(sender, latitude: latitude, longitude: longitude)
    }
    
    
    @IBAction func getInfoButton(_ sender: UIDatePicker) {
        viewModel.getTimeZone(for: CLLocation(latitude: self.latitude, longitude: self.longitude)) { offset in
            self.utc = offset
        }
        self.theDate = self.dateFormatter.string(from: self.datePicker.date)
        if let s = self.sunInfo {
            self.sunRiseLabel.text = self.viewModel.adjustClockTime(userUTC: self.utc, clock: s.sunrise!)
            self.sunSetLabel.text = self.viewModel.adjustClockTime(userUTC: self.utc, clock: s.sunset!)
            self.solarNoonLabel.text = self.viewModel.adjustClockTime(userUTC: self.utc, clock: s.solar_noon!)
            self.dayLengthLabel.text = s.day_length
            let sign = (self.utc >= 0 ? "+" : "")
            self.utcLabel.text = "UTC \(sign)\(self.utc)"
        }
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let coords = viewModel.handleTap(gestureRecognizer: gestureRecognizer, mapView: mapView, latitude: latitude, longitude: longitude, theDate: theDate)
        latitude = coords.first ?? 0
        longitude = coords.last ?? 0
    }
    
    func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.bottom.cgColor, UIColor.top.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        
        // Add the gradient layer to the view's layer at index 0
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
            gradientLayer.colors = [UIColor.bottom.cgColor, UIColor.top.cgColor]
        })
    }
}

extension HomePageVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            
            // Stop update location
            //locationManager.stopUpdatingLocation()
        }
    }
}

extension HomePageVC: MKMapViewDelegate {
    
}
