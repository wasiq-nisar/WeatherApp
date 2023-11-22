//
//  WeatherManager.swift
//  Clima
//
//  Created by Muhammad Wasiq  on 08/11/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=bef6986f5eef0a173600edafeffe05c2&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String){
        //1. Create URL
        if let url = URL(string: urlString){
            //2. Create URL Session
            let session = URLSession(configuration: .default)
            
            //3. Give Session a Task
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if(error != nil){
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let data = data{
                    if let weather = parseJSON(weatherData: data){
                        // let weatherVC = WeatherViewController()
                        // weatherVC.didUpdateWeather(weather: weather)
                        // We can do this but this make our app tightly coupled So we use concept of Delegate
                        delegate?.didUpdateWeather(weather: weather)
                    }
                }
            })
            
            //4. Start the Task
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self , from: weatherData)
            
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(weather.conditionName)
            return weather
        }
        catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
