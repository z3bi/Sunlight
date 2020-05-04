//
//  Coordinates.swift
//  Sunlight
//
//  Created by Ameir Al-Zoubi on 4/29/20.
//  Copyright © 2020 Ameir Al-Zoubi. All rights reserved.
//

import Foundation

public struct Coordinates: Codable, Equatable {
    let latitude: Double
    let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    var latitudeAngle: Angle {
        return Angle(latitude)
    }

    var longitudeAngle: Angle {
        return Angle(longitude)
    }
}
