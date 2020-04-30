//
//  Weather.swift
//  Outfit Recommender
//
//  Created by Brian Advent- [https://github.com/brianadvent/JSONBasics/blob/master/JSON/Weather.swift]


import Foundation

struct Weather {
    let temperature:Double
    let time:Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any]) throws {
        
        guard let temperature = json["temperature"] as? Double else {throw SerializationError.missing("temperature is missing")}
        
        guard let time = json["time"] as? Double else {throw SerializationError.missing("time is missing")}
        
        self.temperature = temperature
        self.time = time
    } //error messages and declarations for apparentTemperature and time
    
    
    static let basePath = "https://api.darksky.net/forecast/c3b2b5cf5b4d050444e22e23f809fab4/"
    
    static func forecast (withLocation location: String, completion: @escaping ([Weather]) -> ()) {
        
        let url = basePath + location
        let request = URLRequest(url: URL(string: url)!) //Creates the API request
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["hourly"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                    
                    } //Grabs the weathere data with specific headers
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(forecastArray)
                
            }
            
        }
        
        task.resume()

    }
}
