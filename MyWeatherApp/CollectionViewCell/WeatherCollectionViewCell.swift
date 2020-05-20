 //
//  WeatherCollectionViewCell.swift
//  MyWeatherApp
//
//  Created by Yauheni Bunas on 5/12/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    static let identifier = "WeatherCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    func configure(with model: HourlyWeatherEntry) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh a" // "a" prints "pm" or "am"
        
        let hourString = formatter.string(from: Date(timeIntervalSince1970: Double(model.time)))
        
        self.tempLabel.text = "\(Int(model.temperature))°"
        self.timeLabel.text = hourString
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.image = UIImage.getUIImage(iconName: model.icon.lowercased())
    }
}
