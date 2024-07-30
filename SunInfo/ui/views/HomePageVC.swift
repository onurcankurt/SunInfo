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
    
    let locationManager = CLLocationManager()
    
    let viewModel = HomePageVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        theDate = dateFormatter.string(from: datePicker.date)
        //print("viewdidload  \(theDate) ")
        
        mapView.delegate = self
        
        // Konum yöneticisini başlat
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Kullanıcıdan konum izni isteme
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        _ = viewModel.sunInfoRx.subscribe(onNext: { sunResult in
            self.sunInfo = sunResult
        })
        
        _ = viewModel.clientInfoRx.subscribe(onNext: { clientInfoRx in
            self.clientInfo = clientInfoRx
        })
        
        viewModel.getSunInfo(lat: latitude, lng: longitude, date: theDate)
        viewModel.getClientInfo()
        
        //print(clientInfo?.abbreviation)
        //print(DateFormatter().timeZone.secondsFromGMT())
        
        sunRiseLabel.text = sunInfo?.sunrise
        sunSetLabel.text = sunInfo?.sunset
        solarNoonLabel.text = sunInfo?.solar_noon
        dayLengthLabel.text = sunInfo?.day_length
        
        // Haritaya dokunma işlemi ekle
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @IBAction func getInfoButton(_ sender: UIDatePicker) {
        getTimeZone(for: CLLocation(latitude: latitude, longitude: longitude)) { offset in
            self.utc = offset
        }
        theDate = dateFormatter.string(from: datePicker.date)
        //print(theDate)
        //print("Latitude: \(latitude), Longitude: \(longitude)")
        viewModel.getSunInfo(lat: latitude, lng: longitude, date: theDate)
        //        if let s = sunInfo {
        //            sunRiseLabel.text = s.sunrise
        //            sunSetLabel.text = s.sunset
        //            solarNoonLabel.text = s.solar_noon
        //            dayLengthLabel.text = s.day_length
        //        }
        //print(utc)
        if let s = sunInfo {
            sunRiseLabel.text = viewModel.adjustClockTime(userUTC: utc, clock: s.sunrise!)
            sunSetLabel.text = viewModel.adjustClockTime(userUTC: utc, clock: s.sunset!)
            solarNoonLabel.text = viewModel.adjustClockTime(userUTC: utc, clock: s.solar_noon!)
            dayLengthLabel.text = s.day_length
            let sign = (self.utc >= 0 ? "+" : "")
            utcLabel.text = "\(sign)\(self.utc)"
        }
        
        //getTimeZone(for: CLLocation(latitude: latitude, longitude: longitude))
    }
    
    func getTimeZone(for location: CLLocation, completion: @escaping (Int) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Failed to reverse geocode location: \(error.localizedDescription)")
                completion(0)
            }
            
            if let placemark = placemarks?.first, let timeZone = placemark.timeZone {
                let offset = timeZone.secondsFromGMT() / 3600
                self.utc = offset
                //print("Time Zone from Location: \(timeZone.identifier)")
                completion(offset) // Başarı durumunda offset döndür
            } else {
                print("Failed to get time zone from placemark.")
                completion(0) // Başarısız durumda 0 döndür
            }
        }
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Dokunulan koordinatları ekrana yazdır
        //print("Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
        
        // Saat dilimini belirleme
        let locationForTimezone = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        latitude = locationForTimezone.coordinate.latitude
        longitude = locationForTimezone.coordinate.longitude
        getTimeZone(for: locationForTimezone) { utc in
        }
    }
}

extension HomePageVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            //print("Latitude: \(latitude), Longitude: \(longitude)")
            
            // Konum güncellemeyi durdur
            //locationManager.stopUpdatingLocation()
        }
    }
}

extension HomePageVC: MKMapViewDelegate {
    
}
