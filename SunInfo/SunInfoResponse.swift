//
//  SunInfoResponse.swift
//  SunInfo
//
//  Created by onur on 28.07.2024.
//

import Foundation

class SunInfoResponse: Codable {
    var results: SunResults
    var status: String
    var tzid: String
}
