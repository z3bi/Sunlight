//
//  MathUtilities.swift
//  Sunlight
//
//  Created by Ameir Al-Zoubi on 4/29/20.
//  Copyright © 2020 Ameir Al-Zoubi. All rights reserved.
//

import Foundation

internal extension Double {

    func normalizedToScale(_ max: Double) -> Double {
        return self - (max * (floor(self / max)))
    }
}
