//
//  ViewController.swift
//  MyWeatherApp
//
//  Created by Yauheni Bunas on 5/10/20.
//  Copyright © 2020 Yauheni Bunas. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var table: UITableView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    let apiKey = "" //"Here-should-be-your-key"
    let weatherAPIUrlFormat = "https://api.darksky.net/forecast/%@/%f,%f?exclude[flags,minutely]&units=ca"
    let backgroundCollor: UIColor = UIColor(red: 52/255.0, green:  109/255.0, blue: 179/255.0, alpha: 1.0)
    
    var dailyModels = [DailyWeatherEntry]()
    var hourlyModels = [HourlyWeatherEntry]()
    var currentWeather: CurrentWeather?
    var placeName = "Current Location"
    
    private var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        table.backgroundColor = backgroundCollor
        view.backgroundColor = backgroundCollor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupLocation()
    }
    
    // Location
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        locationManager.getPlace(for: currentLocation) { placemark in
            guard let placemark = placemark else { return }
            
            self.placeName = placemark.locality!
        }
        
        
        let weatherUrl = NSString(format: weatherAPIUrlFormat as NSString, apiKey, lat, long)

        URLSession.shared.dataTask(with:  URL(string: weatherUrl as String)!, completionHandler: {data, response, error in
            guard let data = data, error == nil else { return }

            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            } catch {
                print("Error: \(error)")
            }
            
            guard let result = json else { return }
            
            var myNewResult = result.daily.data
            myNewResult.remove(at: 0)
            
            self.dailyModels.append(contentsOf: myNewResult)
            self.currentWeather = result.currently
            self.hourlyModels = result.hourly.data
            
            DispatchQueue.main.async {
                self.table.reloadData()
                self.table.tableHeaderView = self.createTableHeader()
            }
        }).resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return dailyModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            
            cell.configure(with: hourlyModels)
            cell.backgroundColor = backgroundCollor
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        
        cell.configure(with: dailyModels[indexPath.row])
        cell.backgroundColor = backgroundCollor
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }
        
        return 40
    }
    
    private func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/2))
        
        headerView.backgroundColor = backgroundCollor
        addBackgroundVideo(headerView: headerView)
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: headerView.frame.size.width - 20, height: headerView.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 10 + locationLabel.frame.size.height, width: headerView.frame.size.width - 20, height: headerView.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 10 + locationLabel.frame.size.height + summaryLabel.frame.size.height, width: headerView.frame.size.width - 20, height: headerView.frame.size.height/2))
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(summaryLabel)
        
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        tempLabel.textAlignment = .center
        
        guard let currentWeather = self.currentWeather  else {
            return UIView()
        }
        
        
        locationLabel.text = placeName
        locationLabel.font = UIFont(name: "Helvetica-Bold", size: 20)
        tempLabel.text = "\(Int(currentWeather.temperature))°"
        tempLabel.font = UIFont(name: "Helvetica", size: 64)
        summaryLabel.text = currentWeather.summary
        
        return headerView
    }
    
    private func addBackgroundVideo(headerView: UIView) {
        let fileUrl = getVideoURL(weatherName: "cloud")
        let playerItem = AVPlayerItem(url: fileUrl)
        
        let player = AVPlayer(playerItem: playerItem)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = headerView.layer.bounds
        
        player.play()
        player.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(rewindVideo(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        headerView.layer.insertSublayer(playerLayer, at: 0)
    }
    
    @objc private func rewindVideo(notification: Notification) {
        playerLayer.player?.seek(to: .zero)
    }
    
    private func getVideoURL(weatherName name: String) -> URL {
        if name.contains("clear") {
            return Bundle.main.url(forResource: "clear_video", withExtension: "mp4")!
        } else if name.contains("rain") {
            return Bundle.main.url(forResource: "rain_video", withExtension: "mp4")!
        }
        
        return Bundle.main.url(forResource: "cloud_video", withExtension: "mp4")!
    }
}
