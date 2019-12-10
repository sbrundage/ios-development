//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Stephen Brundage on 12/8/19.
//  Copyright © 2019 Stephen Brundage. All rights reserved.
//

import Foundation

// Weather Manager Delegate Protocol
protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
}

// Handles weather data 
struct WeatherManager {
    
    var weatherURL = "https://api.openweathermap.org/data/2.5/weather?units=imperial"
    
    var delegate: WeatherManagerDelegate?
    
    init() {
        weatherURL = weatherURL + "&appid=\(API_KEY)"
    }
    
    func fetchCityName(cityName: String) {
        let urlString = weatherURL + "&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(weather: weather)
                    } else {
                        print("There was issue with parseJSON")
                    }
                }
            }
            
            task.resume()
        } else { print("Could not perform request") }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let weatherModel = try decoder.decode(WeatherData.self, from: weatherData)
            let id = weatherModel.weather[0].id
            let temp = weatherModel.main.temp
            let name = weatherModel.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
        } catch {
            print(error)
            return nil
        }
    }
}
