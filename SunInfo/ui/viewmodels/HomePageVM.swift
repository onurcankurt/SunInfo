//
//  HomePageVM.swift
//  SunInfo
//
//  Created by onur on 29.07.2024.
//

import Foundation
import RxSwift

class HomePageVM {
    var srepo = SunDaoRepository()
    var sunInfoRx = BehaviorSubject(value: SunResults())
    var clientInfoRx = BehaviorSubject(value: WorldTimeAPI())
    
    init() {
        sunInfoRx = srepo.sunInfoRx
        clientInfoRx = srepo.clientInfoRx
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
}
