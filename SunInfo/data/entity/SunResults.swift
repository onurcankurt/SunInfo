//
//  SunResults.swift
//  SunInfo
//
//  Created by onur on 28.07.2024.
//

import Foundation

class SunResults: Codable {
    var sunrise: String?
    var sunset: String?
    var solar_noon: String?
    var day_length: String?
    var civil_twilight_begin: String?
    var civil_twilight_end: String?
    var nautical_twilight_begin: String?
    var nautical_twilight_end: String?
    var astronomical_twilight_begin: String?
    var astronomical_twilight_end: String?
    
    init() {
    }

    init(sunrise: String, sunset: String, solar_noon: String, day_length: String, civil_twilight_begin: String, civil_twilight_end: String, nautical_twilight_begin: String, nautical_twilight_end: String, astronomical_twilight_begin: String, astronomical_twilight_end: String) {
        self.sunrise = sunrise
        self.sunset = sunset
        self.solar_noon = solar_noon
        self.day_length = day_length
        self.civil_twilight_begin = civil_twilight_begin
        self.civil_twilight_end = civil_twilight_end
        self.nautical_twilight_begin = nautical_twilight_begin
        self.nautical_twilight_end = nautical_twilight_end
        self.astronomical_twilight_begin = astronomical_twilight_begin
        self.astronomical_twilight_end = astronomical_twilight_end
    }
}
