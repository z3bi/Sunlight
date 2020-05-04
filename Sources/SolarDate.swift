//
//  SolarDate.swift
//  Sunlight
//
//  Created by Ameir Al-Zoubi on 4/29/20.
//  Copyright © 2020 Ameir Al-Zoubi. All rights reserved.
//

import Foundation

struct SolarDate {
    let date: DateComponents
    let coordinates: Coordinates
    let solar: SolarPosition

    let solarNoon: Date
    let sunrise: Date
    let sunset: Date

    init?(coordinates: Coordinates, date: DateComponents?) {
        var date = date ?? SolarDate.cal.dateComponents([.year, .month, .day], from: Date())
        date.hour = 0
        date.minute = 0

        let julianDay = Astronomical.julianDay(dateComponents: date)

        let prevSolar = SolarPosition(julianDay: julianDay - 1)
        let solar = SolarPosition(julianDay: julianDay)
        let nextSolar = SolarPosition(julianDay: julianDay + 1)
        let m0 = Astronomical.approximateTransit(longitude: coordinates.longitudeAngle, siderealTime: solar.apparentSiderealTime, rightAscension: solar.rightAscension)
        let solarAltitude = Angle(-50.0 / 60.0)

        self.date = date
        self.coordinates = coordinates
        self.solar = solar
        self.prevSolar = prevSolar
        self.nextSolar = nextSolar
        self.approxTransit = m0


        let transitTime = Astronomical.correctedTransit(approximateTransit: m0, longitude: coordinates.longitudeAngle, siderealTime: solar.apparentSiderealTime,
                                                     rightAscension: solar.rightAscension, previousRightAscension: prevSolar.rightAscension, nextRightAscension: nextSolar.rightAscension)
        let sunriseTime = Astronomical.correctedHourAngle(approximateTransit: m0, angle: solarAltitude, coordinates: coordinates, afterTransit: false, siderealTime: solar.apparentSiderealTime,
                                                       rightAscension: solar.rightAscension, previousRightAscension: prevSolar.rightAscension, nextRightAscension: nextSolar.rightAscension,
                                                       declination: solar.declination, previousDeclination: prevSolar.declination, nextDeclination: nextSolar.declination)
        let sunsetTime = Astronomical.correctedHourAngle(approximateTransit: m0, angle: solarAltitude, coordinates: coordinates, afterTransit: true, siderealTime: solar.apparentSiderealTime,
                                                      rightAscension: solar.rightAscension, previousRightAscension: prevSolar.rightAscension, nextRightAscension: nextSolar.rightAscension,
                                                      declination: solar.declination, previousDeclination: prevSolar.declination, nextDeclination: nextSolar.declination)

        guard let transitComp = SolarDate.setTime(date: date, time: transitTime),
            let sunriseComp = SolarDate.setTime(date: date, time: sunriseTime),
            let sunsetComp = SolarDate.setTime(date: date, time: sunsetTime),
            let transitDate = SolarDate.calUTC.date(from: transitComp),
            let sunriseDate = SolarDate.calUTC.date(from: sunriseComp),
            let sunsetDate = SolarDate.calUTC.date(from: sunsetComp) else {
            return nil
        }

        self.solarNoon = transitDate
        self.sunrise = sunriseDate
        self.sunset = sunsetDate
    }

    func timeForSolarAngle(_ angle: Angle, afterTransit: Bool) -> Date? {
        let hours = Astronomical.correctedHourAngle(approximateTransit: approxTransit, angle: angle, coordinates: coordinates, afterTransit: afterTransit, siderealTime: solar.apparentSiderealTime,
                                               rightAscension: solar.rightAscension, previousRightAscension: prevSolar.rightAscension, nextRightAscension: nextSolar.rightAscension,
                                               declination: solar.declination, previousDeclination: prevSolar.declination, nextDeclination: nextSolar.declination)
        guard let components = SolarDate.setTime(date: date, time: hours) else {
            return nil
        }

        return SolarDate.calUTC.date(from: components)
    }

    private let prevSolar: SolarPosition
    private let nextSolar: SolarPosition
    private let approxTransit: Double

    private static let cal = Calendar(identifier: .gregorian)

    static let calUTC: Calendar = {
        guard let utc = TimeZone(identifier: "UTC") else {
            fatalError("Unable to instantiate UTC TimeZone.")
        }

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = utc
        return cal
    }()

    private static func setTime(date: DateComponents, time: Double) -> DateComponents? {
        guard time.isNormal else {
            return nil
        }

        let hours = floor(time)
        let minutes = floor((time - hours) * 60)
        let seconds = floor((time - (hours + minutes/60)) * 60 * 60)

        var components = date
        components.hour = Int(hours)
        components.minute = Int(minutes)
        components.second = Int(seconds)

        return components
    }

}
