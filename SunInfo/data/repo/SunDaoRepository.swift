//
//  SunDaoRepository.swift
//  SunInfo
//
//  Created by onur on 29.07.2024.
//

import Foundation
import RxSwift
import Alamofire

class SunDaoRepository {
    var sunInfoRx = BehaviorSubject(value: SunResults())
    var clientInfoRx = BehaviorSubject(value: WorldTimeAPI())
    
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
}
