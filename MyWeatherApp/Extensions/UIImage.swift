//
//  UIImage.swift
//  MyWeatherApp
//
//  Created by Yauheni Bunas on 5/20/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import UIKit

extension UIImage {
    static func getUIImage(iconName icon: String) -> UIImage {
        if icon.contains("clear") {
            return UIImage(named: "clear")!
        } else if icon.contains("rain") {
            return UIImage(named: "rain")!
        }
        
        return UIImage(named: "cloud")!
    }
}
