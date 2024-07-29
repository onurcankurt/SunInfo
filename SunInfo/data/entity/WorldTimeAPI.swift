//
//  WorldTimeAPI.swift
//  SunInfo
//
//  Created by onur on 29.07.2024.
//

import Foundation
import Alamofire

class WorldTimeAPI: Codable {
    
    var abbreviation: String?
    var client_ip: String?
    var datetime: String?
    var day_of_week: Int?
    var day_of_year: Int?
    var timezone: String?
    var unixtime: Int?
    var utc_offset: String?
    var week_number: Int?
    
    init() {
    }
    
    init(abbreviation: String, client_ip: String, datetime: String, day_of_week: Int, day_of_year: Int, timezone: String, unixtime: Int, utc_offset: String, week_number: Int) {
        self.abbreviation = abbreviation
        self.client_ip = client_ip
        self.datetime = datetime
        self.day_of_week = day_of_week
        self.day_of_year = day_of_year
        self.timezone = timezone
        self.unixtime = unixtime
        self.utc_offset = utc_offset
        self.week_number = week_number
    }
}
