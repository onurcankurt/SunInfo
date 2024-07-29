//
//  ViewController.swift
//  SunInfo
//
//  Created by onur on 28.07.2024.
//

import UIKit
import Alamofire
import CoreLocation

class HomePageVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var sunRiseLabel: UILabel!
    @IBOutlet weak var sunSetLabel: UILabel!
    @IBOutlet weak var solarNoonLabel: UILabel!
    @IBOutlet weak var dayLengthLabel: UILabel!
    
    var theDate: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    let dateFormatter = DateFormatter()
    var sunInfo: SunResults?
    var clientInfo: WorldTimeAPI?
    
    let locationManager = CLLocationManager()
    
    let viewModel = HomePageVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        theDate = dateFormatter.string(from: datePicker.date)
        print("viewdidload  \(theDate) ")
        
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
        
        print(clientInfo?.abbreviation)
        print(DateFormatter().timeZone.secondsFromGMT())
        
        sunRiseLabel.text = sunInfo?.sunrise
        sunSetLabel.text = sunInfo?.sunset
        solarNoonLabel.text = sunInfo?.solar_noon
        dayLengthLabel.text = sunInfo?.day_length
    }
    
    
    @IBAction func getInfoButton(_ sender: UIDatePicker) {
        let utc = clientInfo?.abbreviation
        theDate = dateFormatter.string(from: datePicker.date)
        print(theDate)
        print("Latitude: \(latitude), Longitude: \(longitude)")
        viewModel.getSunInfo(lat: latitude, lng: longitude, date: theDate)
//        if let s = sunInfo {
//            sunRiseLabel.text = s.sunrise
//            sunSetLabel.text = s.sunset
//            solarNoonLabel.text = s.solar_noon
//            dayLengthLabel.text = s.day_length
//        }
        
        if let s = sunInfo {
            sunRiseLabel.text = viewModel.adjustClockTime(userUTC: utc!, clock: s.sunrise!)
            sunSetLabel.text = viewModel.adjustClockTime(userUTC: utc!, clock: s.sunset!)
            solarNoonLabel.text = viewModel.adjustClockTime(userUTC: utc!, clock: s.solar_noon!)
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
}
