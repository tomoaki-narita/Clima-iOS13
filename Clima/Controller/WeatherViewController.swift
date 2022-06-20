//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

//キーボードのgoボタンで検索出来るようにするためにUITextFieldDelegateを追加
class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    //WeatherManager構造体をインスタンス化
    var weatherManager = WeatherManager()
    
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        //キーボードを閉じる
        //searchTextField.endEditing(true)
        
        weatherManager.delegate = self
        //searchTextFieldで何が起こっているかviewControllerに通知
        searchTextField.delegate = self
    }
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate{
    //虫眼鏡ボタンを押した時の処理
    @IBAction func searchPressed(_ sender: UIButton) {
        
        //キーボードを閉じる
        searchTextField.endEditing(true)
        
        print(searchTextField.text!)
    }
    
    //キーボードのリターンキーが押された時に呼ばれるメソッド
    //bool値を返さなければいけないメソッドなのでtrueを返す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //キーボードを閉じる
        searchTextField.endEditing(true)
        
        print(searchTextField.text!)
        
        return true
    }
    
    //キーボードのReturnキーが押されてテキストフィールドの入力が完了する直前に呼ばれるメソッド
    //return trueでキーボード閉じる。return falseでキーボード表示したままにする。
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        //もしtextFieldのtextが空じゃなかったら(文字が入力されていたら)
        if textField.text != "" {
            
            //キーボードを閉じる
            return true
            
            //それ以外(空だったら)
        } else {
            
            //textFieldのplaceholderにType somethingと表示
            textField.placeholder = "Type something"
            
            //キーボードを表示したままにする
            return false
        }
    }
    
    
    //キーボードが閉じた後に呼ばれるメソッド
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //searchTextField.textはオプショナル型になっているので、if let文でアンラップ
        //searchTextField.textに値が入っていたら(nilじゃなかったら)、cityに代入
        if let city = searchTextField.text{
            //weatherManagerのfetchWeatherメソッドの引数cityNameにcityを設定
            weatherManager.fetchWeather(cityName: city)
        }
        //検索した後もsearchTextFieldに入力した文字が残るため、
        //searchTextFieldのtextを空の文字列にする
        searchTextField.text = ""
    }
    
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate{
    
    func didUpdateWeather(weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async{
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}


