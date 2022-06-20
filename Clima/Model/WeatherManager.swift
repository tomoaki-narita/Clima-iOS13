//
//  WeatherManager.swift
//  Clima
//
//  Created by output. on 2022/04/19.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

//openWeatherのAPIキーをWeatherManager構造体で設定
struct WeatherManager{
    //APIキーを入れたURLを定数weatherURLに代入
    //温度がケルビン(k)表示になっているので摂氏(°C)に変更するために&units=metricを追記
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=e50d0b2666235aca7a47dd4017b9f634&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    //引数cityNameに入力された都市名を代入してweatherURLと結合した値を定数weatherURLに代入するメソッド
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        //1. Create a URL
        if let url = URL(string: urlString){
            
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(weatherManager: self, weather: weather)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
          
            let id = decodedData.weather[0].id
            
            let temp = decodedData.main.temp
            
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
            
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
