//
//  SunDaoRepository.swift
//  SunInfo
//
//  Created by onur on 29.07.2024.
//

import Foundation
import RxSwift
import Alamofire
import CoreLocation
import MapKit

class SunDaoRepository {
    var sunInfoRx = BehaviorSubject(value: SunResults())
    var clientInfoRx = BehaviorSubject(value: WorldTimeAPI())
    
    var cityDataRx = BehaviorSubject(value: [String]())
    
    func getSunInfo(lat: Double, lng: Double, date: String) {
        let url = "https://api.sunrise-sunset.org/json?lat=\(lat)&lng=\(lng)&date=\(date)"
        AF.request(url).response { response in
            if let data = response.data {
                do {
                    let resp = try JSONDecoder().decode(SunInfoResponse.self, from: data)
                    self.sunInfoRx.onNext(resp.results)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getClientInfo(){
        let url = "https://worldtimeapi.org/api/ip/178.233.66.232"
        AF.request(url).response { reponse in
            if let data = reponse.data {
                do {
                    let resp = try JSONDecoder().decode(WorldTimeAPI.self, from: data)
                    self.clientInfoRx.onNext(resp)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func adjustClockTime(userUTC: Int, clock: String) -> String{
        // Saati UTC 0 formatında parse etmek için bir DateFormatter
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm:ss a"
        
        if let date = timeFormatter.date(from: clock) {
            // Kullanıcının UTC offset'ini DateComponents'a dönüştürme
            var offsetComponents = DateComponents()
            //let sign = userUTC.first!
            //let hoursOffset = Int(userUTC.dropFirst())!
            offsetComponents.hour = userUTC
            
            // Calendar kullanarak tarihi güncelleme
            if let adjustedDate = Calendar.current.date(byAdding: offsetComponents, to: date) {
                // Yeni tarihi istenen formatta döndürme
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "h:mm:ss a"
                //outputFormatter.timeZone = TimeZone.current
                let localTimeString = outputFormatter.string(from: adjustedDate)
                //print("Adjusted Time: \(localTimeString)")
                return localTimeString
            }
        }
        return ""
    }
    
    func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            var addressComponents: [String] = []
            
            if let error = error {
                print("Failed to reverse geocode location: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                if let administrativeArea = placemark.administrativeArea {
                    addressComponents.append(administrativeArea)
                }
                
                if let subAdministrativeArea = placemark.subAdministrativeArea {
                    addressComponents.append(subAdministrativeArea)
                }
                self.cityDataRx.onNext(addressComponents)
            }
        }
    }
    
    @objc func dateChanged(_ sender: UIDatePicker, latitude: Double, longitude: Double) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Tarih formatını belirle
        let selectedDate = dateFormatter.string(from: sender.date)
        print("Selected Date: \(selectedDate)")
        
        // Seçilen tarih ile yapılacak diğer işlemler
        // örneğin, bir değişkeni güncelleme veya başka bir fonksiyon çağırma
        getSunInfo(lat: latitude, lng: longitude, date: selectedDate)
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
                completion(offset) // Return offset
            } else {
                print("Failed to get time zone from placemark.")
                completion(0) // return 0
            }
        }
    }
    

    func addPin(latitude: Double, longitude: Double, province: String, district: String, map: MKMapView) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = province
        pin.subtitle = district
        
        map.addAnnotation(pin)
    }
    
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer, mapView: MKMapView, latitude: Double, longitude: Double,  theDate: String) -> [Double] {
        mapView.removeAnnotations(mapView.annotations)
        
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        //Set the time zone
        let locationForTimezone = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let lat = locationForTimezone.coordinate.latitude
        let lng = locationForTimezone.coordinate.longitude
        getTimeZone(for: locationForTimezone) { utc in}
        
        reverseGeocode(location: locationForTimezone)
        print("\(lat) \(lng)")
        getSunInfo(lat: lat, lng: lng, date: theDate)
        return [lat, lng]
    }
}
