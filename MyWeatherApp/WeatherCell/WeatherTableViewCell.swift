//
//  WeatherTableViewCell.swift
//  MyWeatherApp
//
//  Created by Yauheni Bunas on 5/10/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var highTempLabel : UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    static let identifier = "WeatherTableViewCell"
    
    let dateFormat = "EEEE"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil )
    }
    
    func configure(with model: DailyWeatherEntry) {
        self.highTempLabel.textAlignment = .center
        self.lowTempLabel.textAlignment = .center
        self.highTempLabel.text = "\(Int(model.temperatureHigh))°"
        self.lowTempLabel.text = "\(Int(model.temperatureLow))°"
        self.dayLabel.text  = getDayForDate(Date(timeIntervalSince1970: Double(model.time)))
        self.iconImageView.contentMode = .scaleAspectFit
        
        self.iconImageView.image = UIImage.getUIImage(iconName: model.icon.lowercased())
    }
    
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: inputDate)
    }
}

