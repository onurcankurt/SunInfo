//
//  HomePageVM.swift
//  SunInfo
//
//  Created by onur on 29.07.2024.
//

import Foundation
import RxSwift
import CoreLocation
import MapKit

class HomePageVM {
    var srepo = SunDaoRepository()
    var sunInfoRx = BehaviorSubject(value: SunResults())
    var clientInfoRx = BehaviorSubject(value: WorldTimeAPI())
    
    var cityDataRx = BehaviorSubject(value: [String]())
    
    init() {
        sunInfoRx = srepo.sunInfoRx
        clientInfoRx = srepo.clientInfoRx
        cityDataRx = srepo.cityDataRx
        getClientInfo()
    }
    
    func getSunInfo(lat: Double, lng: Double, date: String) {
        srepo.getSunInfo(lat: lat, lng: lng, date: date)
    }
    
    func getClientInfo(){
        srepo.getClientInfo()
    }
    
    func adjustClockTime(userUTC: Int, clock: String) -> String{
        srepo.adjustClockTime(userUTC: userUTC, clock: clock)
    }
    
    func reverseGeocode(location: CLLocation) {
        srepo.reverseGeocode(location: location)
    }
    
    func addPin(latitude: Double, longitude: Double, province: String, district: String, map: MKMapView) {
        srepo.addPin(latitude: latitude, longitude: longitude, province: province, district: district, map: map)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker, latitude: Double, longitude: Double) {
        srepo.dateChanged(sender, latitude: latitude, longitude: longitude)
    }
    
    func getTimeZone(for location: CLLocation, completion: @escaping (Int) -> Void) {
        srepo.getTimeZone(for: location) { timezone in
            completion(timezone)
        }
    }
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer, mapView: MKMapView, latitude: Double, longitude: Double, theDate: String) -> [Double] {
        srepo.handleTap(gestureRecognizer: gestureRecognizer, mapView: mapView, latitude: latitude, longitude: longitude, theDate: theDate)
    }
}
