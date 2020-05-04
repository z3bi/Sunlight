//
//  SolarPosition.swift
//  Sunlight
//
//  Created by Ameir Al-Zoubi on 4/29/20.
//  Copyright © 2020 Ameir Al-Zoubi. All rights reserved.
//

import Foundation

struct SolarPosition {

    /* The declination of the sun, the angle between
     the rays of the Sun and the plane of the Earth's equator. */
    let declination: Angle

    /* Right ascension of the Sun, the angular distance on the
     celestial equator from the vernal equinox to the hour circle. */
    let rightAscension: Angle

    /* Apparent sidereal time, the hour angle of the vernal equinox. */
    let apparentSiderealTime: Angle

    init(julianDay: Double) {
        let T = Astronomical.julianCentury(julianDay: julianDay)
        let L0 = Astronomical.meanSolarLongitude(julianCentury: T)
        let Lp = Astronomical.meanLunarLongitude(julianCentury: T)
        let Ω = Astronomical.ascendingLunarNodeLongitude(julianCentury: T)
        let λ = Astronomical.apparentSolarLongitude(julianCentury: T, meanLongitude: L0).radians

        let θ0 = Astronomical.meanSiderealTime(julianCentury: T)
        let ΔΨ = Astronomical.nutationInLongitude(solarLongitude: L0, lunarLongitude: Lp, ascendingNode: Ω)
        let Δε = Astronomical.nutationInObliquity(solarLongitude: L0, lunarLongitude: Lp, ascendingNode: Ω)

        let ε0 = Astronomical.meanObliquityOfTheEcliptic(julianCentury: T)
        let εapp = Astronomical.apparentObliquityOfTheEcliptic(julianCentury: T, meanObliquityOfTheEcliptic: ε0).radians

        /* Equation from Astronomical Algorithms page 165 */
        self.declination = Angle(radians: asin(sin(εapp) * sin(λ)))

        /* Equation from Astronomical Algorithms page 165 */
        self.rightAscension = Angle(radians: atan2(cos(εapp) * sin(λ), cos(λ))).unwound()

        /* Equation from Astronomical Algorithms page 88 */
        self.apparentSiderealTime = Angle(θ0.degrees + (((ΔΨ * 3600) * cos(Angle(ε0.degrees + Δε).radians)) / 3600))
    }
}
