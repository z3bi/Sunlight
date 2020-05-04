//
//  SunlightTests.swift
//  SunlightTests
//
//  Created by Ameir Al-Zoubi on 4/29/20.
//  Copyright © 2020 Ameir Al-Zoubi. All rights reserved.
//

import XCTest
@testable import Sunlight

class SunlightTests: XCTestCase {

    func date(year: Int, month: Int, day: Int, hours: Double = 0) -> DateComponents {
        var cal = Calendar(identifier: Calendar.Identifier.gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        var comps = DateComponents()
        comps.calendar = cal
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = Int(hours)
        comps.minute = Int((hours - floor(hours)) * 60)
        return comps
    }

    func testSolarPosition() {

        // values from Astronomical Algorithms page 165

        var jd = Astronomical.julianDay(year: 1992, month: 10, day: 13)
        var solar = SolarPosition(julianDay: jd)

        var T = Astronomical.julianCentury(julianDay: jd)
        var L0 = Astronomical.meanSolarLongitude(julianCentury: T)
        var ε0 = Astronomical.meanObliquityOfTheEcliptic(julianCentury: T)
        let εapp = Astronomical.apparentObliquityOfTheEcliptic(julianCentury: T, meanObliquityOfTheEcliptic: ε0)
        let M = Astronomical.meanSolarAnomaly(julianCentury: T)
        let C = Astronomical.solarEquationOfTheCenter(julianCentury: T, meanAnomaly: M)
        let λ = Astronomical.apparentSolarLongitude(julianCentury: T, meanLongitude: L0)
        let δ = solar.declination
        let α = solar.rightAscension.unwound()

        XCTAssertEqual(T, -0.072183436,
            accuracy: 0.00000000001)

        XCTAssertEqual(L0.degrees, 201.80720,
            accuracy: 0.00001)

        XCTAssertEqual(ε0.degrees, 23.44023,
            accuracy: 0.00001)

        XCTAssertEqual(εapp.degrees, 23.43999,
            accuracy: 0.00001)

        XCTAssertEqual(M.degrees, 278.99397,
            accuracy: 0.00001)

        XCTAssertEqual(C.degrees, -1.89732,
            accuracy: 0.00001)

        // lower accuracy than desired
        XCTAssertEqual(λ.degrees, 199.90895,
            accuracy: 0.00002)

        XCTAssertEqual(δ.degrees, -7.78507,
            accuracy: 0.00001)

        XCTAssertEqual(α.degrees, 198.38083,
            accuracy: 0.00001)

        // values from Astronomical Algorithms page 88

        jd = Astronomical.julianDay(year: 1987, month: 4, day: 10)
        solar = SolarPosition(julianDay: jd)
        T = Astronomical.julianCentury(julianDay: jd)

        let θ0 = Astronomical.meanSiderealTime(julianCentury: T)
        let θapp = solar.apparentSiderealTime
        let Ω = Astronomical.ascendingLunarNodeLongitude(julianCentury: T)
        ε0 = Astronomical.meanObliquityOfTheEcliptic(julianCentury: T)
        L0 = Astronomical.meanSolarLongitude(julianCentury: T)
        let Lp = Astronomical.meanLunarLongitude(julianCentury: T)
        let ΔΨ = Astronomical.nutationInLongitude(solarLongitude: L0, lunarLongitude: Lp, ascendingNode: Ω)
        let Δε = Astronomical.nutationInObliquity(solarLongitude: L0, lunarLongitude: Lp, ascendingNode: Ω)
        let ε = Angle(ε0.degrees + Δε)

        XCTAssertEqual(θ0.degrees, 197.693195,
            accuracy: 0.000001)

        XCTAssertEqual(θapp.degrees, 197.6922295833,
            accuracy: 0.0001)

        // values from Astronomical Algorithms page 148

        XCTAssertEqual(Ω.degrees, 11.2531,
            accuracy: 0.0001)

        XCTAssertEqual(ΔΨ, -0.0010522,
            accuracy:  0.0001)

        XCTAssertEqual(Δε, 0.0026230556,
            accuracy: 0.00001)

        XCTAssertEqual(ε0.degrees, 23.4409463889,
            accuracy: 0.000001)

        XCTAssertEqual(ε.degrees, 23.4435694444,
            accuracy: 0.00001)
    }

    func testAltitudeOfCelestialBody() {
        let φ: Angle = 38 + (55 / 60) + (17.0 / 3600)
        let δ: Angle = -6 - (43 / 60) - (11.61 / 3600)
        let H: Angle = 64.352133
        let h = Astronomical.altitudeOfCelestialBody(observerLatitude: φ, declination: δ, localHourAngle: H)
        XCTAssertEqual(h.degrees, 15.1249,
            accuracy: 0.0001)
    }

    func testTransitAndHourAngle() {
        // values from Astronomical Algorithms page 103
        let longitude: Angle = -71.0833
        let Θ: Angle = 177.74208
        let α1: Angle = 40.68021
        let α2: Angle = 41.73129
        let α3: Angle = 42.78204
        let m0 = Astronomical.approximateTransit(longitude: longitude, siderealTime: Θ, rightAscension: α2)

        XCTAssertEqual(m0, 0.81965,
            accuracy: 0.00001)

        let transit = Astronomical.correctedTransit(approximateTransit: m0, longitude: longitude, siderealTime: Θ, rightAscension: α2, previousRightAscension: α1, nextRightAscension: α3) / 24

        XCTAssertEqual(transit, 0.81980,
            accuracy: 0.00001)

        let δ1: Angle = 18.04761
        let δ2: Angle = 18.44092
        let δ3: Angle = 18.82742

        let rise = Astronomical.correctedHourAngle(approximateTransit: m0, angle: -0.5667, coordinates: Coordinates(latitude: 42.3333, longitude: longitude.degrees), afterTransit: false, siderealTime: Θ,
            rightAscension: α2, previousRightAscension: α1, nextRightAscension: α3, declination: δ2, previousDeclination: δ1, nextDeclination: δ3) / 24
        XCTAssertEqual(rise, 0.51766,
            accuracy: 0.00001)
    }

    func testSolarTime() {
        /*
        Comparison values generated from http://aa.usno.navy.mil/rstt/onedaytable?form=1&ID=AA&year=2015&month=7&day=12&state=NC&place=raleigh
        */

        let coordinates = Coordinates(latitude: 35 + 47/60, longitude: -78 - 39/60)
        let solar = SolarDate(coordinates: coordinates, date: date(year: 2015, month: 7, day: 12, hours: 0))!

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        formatter.dateStyle = .short
        formatter.timeStyle = .long

        let transit = solar.solarNoon
        let sunrise = solar.sunrise
        let sunset = solar.sunset
        let twilightStart = solar.timeForSolarAngle(-6, afterTransit: false)!
        let twilightEnd = solar.timeForSolarAngle(-6, afterTransit: true)!
        let invalid = solar.timeForSolarAngle(-36, afterTransit: true)
        XCTAssertEqual(formatter.string(from: twilightStart), "7/12/15, 5:38:21 AM EDT")
        XCTAssertEqual(formatter.string(from: sunrise), "7/12/15, 6:07:54 AM EDT")
        XCTAssertEqual(formatter.string(from: transit), "7/12/15, 1:20:14 PM EDT")
        XCTAssertEqual(formatter.string(from: sunset), "7/12/15, 8:32:16 PM EDT")
        XCTAssertEqual(formatter.string(from: twilightEnd), "7/12/15, 9:01:45 PM EDT")
        XCTAssertNil(invalid)
    }

    func testCalendricalDate() {
        // generated from http://aa.usno.navy.mil/data/docs/RS_OneYear.php for KUKUIHAELE, HAWAII
        let coordinates = Coordinates(latitude: 20 + 7/60, longitude: -155 - 34/60)
        let day1solar = SolarDate(coordinates: coordinates, date: date(year: 2015, month: 4, day: 2, hours: 0))!
        let day2solar = SolarDate(coordinates: coordinates, date: date(year: 2015, month: 4, day: 3, hours: 0))!

        let day1 = day1solar.sunrise
        let day2 = day2solar.sunrise

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Pacific/Honolulu")
        formatter.dateStyle = .short
        formatter.timeStyle = .long

        XCTAssertEqual(formatter.string(from: day1), "4/2/15, 6:14:59 AM HST")
        XCTAssertEqual(formatter.string(from: day2), "4/3/15, 6:14:08 AM HST")
    }

    func testInterpolation() {

        // values from Astronomical Algorithms page 25

        let interpolatedValue = Astronomical.interpolate(value: 0.877366, previousValue: 0.884226, nextValue: 0.870531, factor: 4.35/24)
        XCTAssertEqual(interpolatedValue, 0.876125,
                                            accuracy: 0.000001)

        let i1 = Astronomical.interpolate(value: 1, previousValue: -1, nextValue: 3, factor: 0.6)
        XCTAssertEqual(i1, 2.2, accuracy: 0.000001)
    }

    func testAngleInterpolation() {
        let i1 = Astronomical.interpolateAngles(value: 1, previousValue: -1, nextValue: 3, factor: 0.6)
        XCTAssertEqual(i1.degrees, 2.2, accuracy: 0.000001)

        let i2 = Astronomical.interpolateAngles(value: 1, previousValue: 359, nextValue: 3, factor: 0.6)
        XCTAssertEqual(i2.degrees, 2.2, accuracy: 0.000001)
    }

    func testJulianDay() {
        /*
        Comparison values generated from http://aa.usno.navy.mil/data/docs/JulianDate.php
        */

        XCTAssertEqual(Astronomical.julianDay(year: 2010, month: 1, day: 2), 2455198.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2011, month: 2, day: 4), 2455596.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2012, month: 3, day: 6), 2455992.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2013, month: 4, day: 8), 2456390.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2014, month: 5, day: 10), 2456787.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2015, month: 6, day: 12), 2457185.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2016, month: 7, day: 14), 2457583.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2017, month: 8, day: 16), 2457981.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2018, month: 9, day: 18), 2458379.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2019, month: 10, day: 20), 2458776.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2020, month: 11, day: 22), 2459175.500000)
        XCTAssertEqual(Astronomical.julianDay(year: 2021, month: 12, day: 24), 2459572.500000)

        let jdVal = 2457215.67708333
        XCTAssertEqual(Astronomical.julianDay(year: 2015, month: 7, day: 12, hours: 4.25), jdVal, accuracy: 0.000001)

        var components = DateComponents()
        components.year = 2015
        components.month = 7
        components.day = 12
        components.hour = 4
        components.minute = 15
        XCTAssertEqual(Astronomical.julianDay(dateComponents: components), jdVal, accuracy: 0.000001)

        XCTAssertEqual(Astronomical.julianDay(year: 2015, month: 7, day: 12, hours: 8.0), 2457215.833333, accuracy: 0.000001)
        XCTAssertEqual(Astronomical.julianDay(year: 1992, month: 10, day: 13, hours: 0.0), 2448908.5, accuracy: 0.000001)

        XCTAssertEqual(Astronomical.julianDay(dateComponents: DateComponents()), 1721425.5, accuracy: 0.000001)
    }

    func testJulianHours() {
        let j1 = Astronomical.julianDay(year: 2010, month: 1, day: 3)
        let j2 = Astronomical.julianDay(year: 2010, month: 1, day: 1, hours: 48)
        XCTAssertEqual(j1, j2)
    }
}
