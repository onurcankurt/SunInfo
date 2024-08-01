//
//  HomePageVM.swift
//  SunInfo
//
//  Created by onur on 29.07.2024.
//

import Foundation
import RxSwift
import CoreLocation

class HomePageVM {
    var srepo = SunDaoRepository()
    var sunInfoRx = BehaviorSubject(value: SunResults())
    var clientInfoRx = BehaviorSubject(value: WorldTimeAPI())
    
    var theDate: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    let dateFormatter = DateFormatter()
    var utc = 0
    
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
}
