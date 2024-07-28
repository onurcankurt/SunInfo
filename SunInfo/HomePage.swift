//
//  ViewController.swift
//  SunInfo
//
//  Created by onur on 28.07.2024.
//

import UIKit
import Alamofire
import CoreLocation

class HomePage: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var sunRiseLabel: UILabel!
    @IBOutlet weak var sunSetLabel: UILabel!
    @IBOutlet weak var solarNoonLabel: UILabel!
    @IBOutlet weak var dayLengthLabel: UILabel!
    
    var theDate: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    let dateFormatter = DateFormatter()
    var sunInfo: SunResults?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        theDate = dateFormatter.string(from: datePicker.date)
        
        // Konum yöneticisini başlat
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Kullanıcıdan konum izni isteme
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    @IBAction func getInfoButton(_ sender: UIDatePicker) {
        theDate = dateFormatter.string(from: datePicker.date)
        print(theDate)
        print("Latitude: \(latitude), Longitude: \(longitude)")
        getSunInfo(lat: latitude, lng: longitude, date: theDate)
        if let s = sunInfo {
            sunRiseLabel.text = s.sunrise
            sunSetLabel.text = s.sunset
            solarNoonLabel.text = s.solar_noon
            dayLengthLabel.text = s.day_length
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            //print("Latitude: \(latitude), Longitude: \(longitude)")
            
            // Konum güncellemeyi durdur
            //locationManager.stopUpdatingLocation()
        }
    }
    
    func getSunInfo(lat: Double, lng: Double, date: String) {
        var url = "https://api.sunrise-sunset.org/json?lat=\(lat)&lng=\(lng)&date=\(date)"
        AF.request(url).response { response in
            if let data = response.data {
                do {
                    let resp = try JSONDecoder().decode(SunInfoResponse.self, from: data)
                    self.sunInfo = resp.results
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

