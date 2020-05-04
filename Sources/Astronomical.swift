//
//  Astronomical.swift
//  Sunlight
//
//  Created by Ameir Al-Zoubi on 4/29/20.
//  Copyright © 2020 Ameir Al-Zoubi. All rights reserved.
//

import Foundation

enum Astronomical {

    /* The geometric mean longitude of the sun. */
    static func meanSolarLongitude(julianCentury T: Double) -> Angle {
        /* Equation from Astronomical Algorithms page 163 */
        let term1 = 280.4664567
        let term2 = 36000.76983 * T
        let term3 = 0.0003032 * pow(T, 2)
        let L0 = term1 + term2 + term3
        return Angle(L0).unwound()
    }

    /* The geometric mean longitude of the moon. */
    static func meanLunarLongitude(julianCentury T: Double) -> Angle {
        /* Equation from Astronomical Algorithms page 144 */
        let term1 = 218.3165
        let term2 = 481267.8813 * T
        let Lp = term1 + term2
        return Angle(Lp).unwound()
    }

    static func ascendingLunarNodeLongitude(julianCentury T: Double) -> Angle {
        /* Equation from Astronomical Algorithms page 144 */
        let term1 = 125.04452
        let term2 = 1934.136261 * T
        let term3 = 0.0020708 * pow(T, 2)
        let term4 = pow(T, 3) / 450000
        let Ω = term1 - term2 + term3 + term4
        return Angle(Ω).unwound()
    }

    /* The mean anomaly of the sun. */
    static func meanSolarAnomaly(julianCentury T: Double) -> Angle {
        /* Equation from Astronomical Algorithms page 163 */
        let term1 = 357.52911
        let term2 = 35999.05029 * T
        let term3 = 0.0001537 * pow(T, 2)
        let M = term1 + term2 - term3
        return Angle(M).unwound()
    }

    /* The Sun's equation of the center. */
    static func solarEquationOfTheCenter(julianCentury T: Double, meanAnomaly M: Angle) -> Angle {
        /* Equation from Astronomical Algorithms page 164 */
        let Mrad = M.radians
        let term1 = (1.914602 - (0.004817 * T) - (0.000014 * pow(T, 2))) * sin(Mrad)
        let term2 = (0.019993 - (0.000101 * T)) * sin(2 * Mrad)
        let term3 = 0.000289 * sin(3 * Mrad)
        return Angle(term1 + term2 + term3)
    }

    /* The apparent longitude of the Sun, referred to the
     true equinox of the date. */
    static func apparentSolarLongitude(julianCentury T: Double, meanLongitude L0: Angle) -> Angle {
        /* Equation from Astronomical Algorithms page 164 */
        let longitude = L0 + Astronomical.solarEquationOfTheCenter(julianCentury: T, meanAnomaly: Astronomical.meanSolarAnomaly(julianCentury: T))
        let Ω = Angle(125.04 - (1934.136 * T))
        let λ = Angle(longitude.degrees - 0.00569 - (0.00478 * sin(Ω.radians)))
        return λ.unwound()
    }

    /* The mean obliquity of the ecliptic, formula
     adopted by the International Astronomical Union. */
    static func meanObliquityOfTheEcliptic(julianCentury T: Double) -> Angle {
        /* Equation from Astronomical Algorithms page 147 */
        let term1 = 23.439291
        let term2 = 0.013004167 * T
        let term3 = 0.0000001639 * pow(T, 2)
        let term4 = 0.0000005036 * pow(T, 3)
        return Angle(term1 - term2 - term3 + term4)
    }

    /* The mean obliquity of the ecliptic, corrected for
     calculating the apparent position of the sun. */
    static func apparentObliquityOfTheEcliptic(julianCentury T: Double, meanObliquityOfTheEcliptic ε0: Angle) -> Angle {
        /* Equation from Astronomical Algorithms page 165 */
        let O: Double = 125.04 - (1934.136 * T)
        return Angle(ε0.degrees + (0.00256 * cos(Angle(O).radians)))
    }

    /* Mean sidereal time, the hour angle of the vernal equinox. */
    static func meanSiderealTime(julianCentury T: Double) -> Angle {
        /* Equation from Astronomical Algorithms page 165 */
        let JD = (T * 36525) + 2451545.0
        let term1 = 280.46061837
        let term2 = 360.98564736629 * (JD - 2451545)
        let term3 = 0.000387933 * pow(T, 2)
        let term4 = pow(T, 3) / 38710000
        let θ = term1 + term2 + term3 - term4
        return Angle(θ).unwound()
    }

    static func nutationInLongitude(solarLongitude L0: Angle, lunarLongitude Lp: Angle, ascendingNode Ω: Angle) -> Double {
        /* Equation from Astronomical Algorithms page 144 */
        let term1 = (-17.2/3600) * sin(Ω.radians)
        let term2 =  (1.32/3600) * sin(2 * L0.radians)
        let term3 =  (0.23/3600) * sin(2 * Lp.radians)
        let term4 =  (0.21/3600) * sin(2 * Ω.radians)
        return term1 - term2 - term3 + term4
    }

    static func nutationInObliquity(solarLongitude L0: Angle, lunarLongitude Lp: Angle, ascendingNode Ω: Angle) -> Double {
        /* Equation from Astronomical Algorithms page 144 */
        let term1 =  (9.2/3600) * cos(Ω.radians)
        let term2 = (0.57/3600) * cos(2 * L0.radians)
        let term3 = (0.10/3600) * cos(2 * Lp.radians)
        let term4 = (0.09/3600) * cos(2 * Ω.radians)
        return term1 + term2 + term3 - term4
    }

    static func altitudeOfCelestialBody(observerLatitude φ: Angle, declination δ: Angle, localHourAngle H: Angle) -> Angle {
        /* Equation from Astronomical Algorithms page 93 */
        let term1 = sin(φ.radians) * sin(δ.radians)
        let term2 = cos(φ.radians) * cos(δ.radians) * cos(H.radians)
        return Angle(radians: asin(term1 + term2))
    }

    static func approximateTransit(longitude L: Angle, siderealTime Θ0: Angle, rightAscension α2: Angle) -> Double {
        /* Equation from page Astronomical Algorithms 102 */
        let Lw = L * -1
        return ((α2 + Lw - Θ0) / 360).degrees.normalizedToScale(1)
    }

    /* The time at which the sun is at its highest point in the sky (in universal time) */
    static func correctedTransit(approximateTransit m0: Double, longitude L: Angle, siderealTime Θ0: Angle,
                                 rightAscension α2: Angle, previousRightAscension α1: Angle, nextRightAscension α3: Angle) -> Double {
        /* Equation from page Astronomical Algorithms 102 */
        let Lw = L * -1
        let θ = Angle(Θ0.degrees + (360.985647 * m0)).unwound()
        let α = Astronomical.interpolateAngles(value: α2, previousValue: α1, nextValue: α3, factor: m0).unwound()
        let H = (θ - Lw - α).quadrantShifted()
        let Δm = H / Angle(-360)
        return (m0 + Δm.degrees) * 24
    }

    static func correctedHourAngle(approximateTransit m0: Double, angle h0: Angle, coordinates: Coordinates, afterTransit: Bool, siderealTime Θ0: Angle,
                                   rightAscension α2: Angle, previousRightAscension α1: Angle, nextRightAscension α3: Angle,
                                   declination δ2: Angle, previousDeclination δ1: Angle, nextDeclination δ3: Angle) -> Double {
        /* Equation from page Astronomical Algorithms 102 */
        let Lw = coordinates.longitudeAngle * Angle(-1)
        let term1 = sin(h0.radians) - (sin(coordinates.latitudeAngle.radians) * sin(δ2.radians))
        let term2 = cos(coordinates.latitudeAngle.radians) * cos(δ2.radians)
        let H0 = Angle(radians: acos(term1 / term2))
        let m = afterTransit ? m0 + (H0.degrees / 360) : m0 - (H0.degrees / 360)
        let θ = Angle(Θ0.degrees + (360.985647 * m)).unwound()
        let α = Astronomical.interpolateAngles(value: α2, previousValue: α1, nextValue: α3, factor: m).unwound()
        let δ = Angle(Astronomical.interpolate(value: δ2.degrees, previousValue: δ1.degrees, nextValue: δ3.degrees, factor: m))
        let H = (θ - Lw - α)
        let h = Astronomical.altitudeOfCelestialBody(observerLatitude: coordinates.latitudeAngle, declination: δ, localHourAngle: H)
        let term3 = (h - h0).degrees
        let term4 = 360 * cos(δ.radians) * cos(coordinates.latitudeAngle.radians) * sin(H.radians)
        let Δm = term3 / term4
        return (m + Δm) * 24
    }

    /* Interpolation of a value given equidistant
     previous and next values and a factor
     equal to the fraction of the interpolated
     point's time over the time between values. */
    static func interpolate(value y2: Double, previousValue y1: Double, nextValue y3: Double, factor n: Double) -> Double {
        /* Equation from Astronomical Algorithms page 24 */
        let a = y2 - y1
        let b = y3 - y2
        let c = b - a
        return y2 + ((n/2) * (a + b + (n * c)))
    }

    /* Interpolation of three angles, accounting for
     angle unwinding. */
    static func interpolateAngles(value y2: Angle, previousValue y1: Angle, nextValue y3: Angle, factor n: Double) -> Angle {
        /* Equation from Astronomical Algorithms page 24 */
        let a = (y2 - y1).unwound()
        let b = (y3 - y2).unwound()
        let c = b - a
        return Angle(y2.degrees + ((n/2) * (a.degrees + b.degrees + (n * c.degrees))))
    }

    /* The Julian Day for the given Gregorian date. */
    static func julianDay(year: Int, month: Int, day: Int, hours: Double = 0) -> Double {

        /* Equation from Astronomical Algorithms page 60 */

        // NOTE: Casting to Int is done intentionally for the purpose of decimal truncation

        let Y: Int = month > 2 ? year : year - 1
        let M: Int = month > 2 ? month : month + 12
        let D: Double = Double(day) + (hours / 24)

        let A: Int = Y/100
        let B: Int = 2 - A + (A/4)

        let i0: Int = Int(365.25 * (Double(Y) + 4716))
        let i1: Int = Int(30.6001 * (Double(M) + 1))
        return Double(i0) + Double(i1) + D + Double(B) - 1524.5
    }

    /* The Julian Day for the given Gregorian date components. */
    static func julianDay(dateComponents: DateComponents) -> Double {
        let year = dateComponents.year ?? 1
        let month = dateComponents.month ?? 1
        let day = dateComponents.day ?? 1
        let hour: Double = Double(dateComponents.hour ?? 0)
        let minute: Double = Double(dateComponents.minute ?? 0)

        return Astronomical.julianDay(year: year, month: month, day: day, hours: hour + (minute / 60))
    }

    /* Julian century from the epoch. */
    static func julianCentury(julianDay JD: Double) -> Double {
        /* Equation from Astronomical Algorithms page 163 */
        return (JD - 2451545.0) / 36525
    }

}
