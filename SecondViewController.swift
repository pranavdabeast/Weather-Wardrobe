//
//  SecondViewController.swift
//  Weather Wardrobe
//
//  Created by Pranav Mukund on 4/24/20.
//  Copyright © 2020 Pranav Mukund. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class SecondViewController: UIViewController {

    let defaults = UserDefaults.standard //Userdefaults to store clothing preferences
    
    struct Keys {
           static let seventyaboveweather = "seventyaboveweather"
           static let fortyaboveweather = "fortyaboveweather"
           static let fortybelowweather = "fortybelowweather"
           static let locationEntry = "locationEntry"
       } //To prevent spelling errors in keys for Defaults
    
    @IBOutlet weak var textDisplay: UITextView!
    
    let locationManager = CLLocationManager() //For location/Weather purposes
    var Latitude = 0.0
    var Longitude = 0.0
    
    func shorten12Temp(array: [Weather]) -> Array<Double>  {
         
         var temperaturearray = [Double]()
         var itemcount = 0
             
         for items in array {

             if itemcount < 12 {
                 temperaturearray.append(items.apparentTemperature) //Appends temperature(double) into a new array
                 itemcount = itemcount + 1
             }

         }

         return(temperaturearray)
     } //Function that shortens list of 48 hourly data objects to 12- takes in array of weather objects and outputs array of doubles

    func shorten12Time(array: [Weather]) -> Array<Double> {
        
        var timearray = [Double]()
        var itemcount = 0
        
        for items in array {

            if itemcount < 12 {
                timearray.append(items.time)//Appends times(double) into a new array
                itemcount = itemcount + 1
            }

        } //Function that shortens list of 48 hourly data objects to 12- takes in array of weather objects and outputs array of doubles
        return(timearray)
        
    }

    func unixConverter(timearray : Array<Double>) -> Array<String> {
        var timestrings = [String]()
        
        for times in timearray {
                                                  
                           let date = Date(timeIntervalSince1970: times)
                           let dateFormatter = DateFormatter()
                           dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
                           dateFormatter.timeZone = .current
                           let localDate = dateFormatter.string(from: date)
                           timestrings.append(localDate)
                           
                   }
        return timestrings
    }// Function that converts UNIX-style times into hour-minute formats

    func predictClothes(temp12: Array<Double>, times : Array<String>) -> Array<String> {
        
        let seventyabove = defaults.value(forKey: Keys.seventyaboveweather) as? String ?? "" //Preferences from User Defaults
        let fortyabove = defaults.value(forKey: Keys.fortyaboveweather) as? String ?? ""
        let fortybelow = defaults.value(forKey: Keys.fortybelowweather) as? String ?? ""
        
        var totalsum = 0 //Used for average calculation
        var itemcount = 0 //Used to count the total number of items in order to calculate average
        var thresholdmin : Double = 0 //Used to determine levels for temperature classification
        var thresholdmax : Double = 0
        var index = 0 //Simple index for use in for loops
        var tempspikeresults = [String]() //Array for addition of strings
        var clothespredictorarray = [String]()
        var dictindex = 0 //For domain jumps in spikes/dips
        var prevstring:String = "" //For comparisons to previous weather spikes
        var changecounter = 0 //To count weather changes
        
        for hours in temp12 {
            totalsum = totalsum + Int(hours)
            itemcount = itemcount + 1
        }//Averaging function
        
        let average = (totalsum / itemcount)
        
        /* The following chunk of code is a general predictor for clothes based on the average temperature over the next 12 hours. It also establishes the ranges for certain types of clothing*/
        if average > 70 {
            clothespredictorarray.append("Average Temperature over the next 12 hours = \(average). Wear \(seventyabove)") //Adds general clothing reccomendation to final clothing array
            thresholdmin = 70
            thresholdmax = 120
            dictindex = 1
        }
        if average < 70 && average > 40 {
            clothespredictorarray.append("Average Temperature over the next 12 hours = \(average). Wear \(fortyabove)")
            thresholdmin = 40
            thresholdmax = 70
            dictindex = 2
            
        }
        if average < 40 {
            clothespredictorarray.append("Average Temperature over the next 12 hours = \(average). Wear \(fortybelow)")
            thresholdmin = 0
            thresholdmax = 40
            dictindex = 3
        }

        let highnumber = thresholdmax + 30 //To establish boundaries for the other categories of temperature/clothing
        let lownumber = thresholdmin - 30
        
        //Checks if temperature jumps into a higher or lower category and appends the result to temperaturespikearray
        for temp in temp12 {
            
                if temp > thresholdmin && temp < thresholdmax {
                    tempspikeresults.append("Temperature returns to average")
                
                }
                
                if temp > thresholdmax && temp < highnumber {
                    tempspikeresults.append("Temperature raises")
                    
                }
                    
                if temp < thresholdmin && temp > lownumber {
                    tempspikeresults.append("Temperature dips")
                }
                
            index = index + 1
        }
        
        index = 0 //Re-using index
        
        
        //Appends time for each temperature spike or drop and reccomends clothing for those spikes or drops
        for items in tempspikeresults {
            
            if items == "Temperature returns to average" {
                
                if index == 0 {
                    prevstring = items
                }
                
            }
            
            if items == "Temperature raises" {
                
                if index == 0 || items != prevstring {
                    dictindex = dictindex - 1
                }

                if dictindex == 1 {
                    clothespredictorarray.append("\(items) at \(times[index]). Wear \(seventyabove)")
                }

                if dictindex == 2 {
                    clothespredictorarray.append("\(items) at \(times[index]). Wear \(fortyabove)")
                }
                changecounter = changecounter + 1
            }
            
            if items == "Temperature dips" {
                
                if index == 0 || items != prevstring {
                    dictindex = dictindex + 1
                }
                
                if dictindex == 2 {
                    clothespredictorarray.append("\(items) at \(times[index]). Wear \(fortyabove)")
                }
                
                if dictindex == 3 {
                    clothespredictorarray.append("\(items) at \(times[index]). Wear \(fortybelow)")
                }
                changecounter = changecounter + 1
            }
            
            index = index + 1
            prevstring = items
        }
        
        if changecounter == 0 {
            clothespredictorarray.append("No major changes in temperature over the next 12 hours")
        }
        return(clothespredictorarray)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getLocation()
    }
    
    @IBAction func predictButtonTapped(_ sender: Any) {
        
         var temperaturearray = [Double]()
         var timearray = [Double]()
         var clothespredictorarray = [String]()
         var timestrings = [String]()
         let coordinatesAPI = "\(Latitude),\(Longitude)"
        
         Weather.forecast(withLocation: coordinatesAPI) { (results:[Weather]) in

                 temperaturearray = self.shorten12Temp(array:results) //Caling shorten 12 by passing an array, called "array" of results
                 timearray = self.shorten12Time(array: results) //Calling shorten12 for the times
                 timestrings = self.unixConverter(timearray: timearray)//Calling unixConverter
                 clothespredictorarray = self.predictClothes(temp12: temperaturearray, times: timestrings)
                             
                 let joinedclothespredictorarray = clothespredictorarray.joined(separator: "\n") //megring results in clothespredictorarray to display on UI
                             
                 DispatchQueue.main.async {
                     self.textDisplay.text = "\(joinedclothespredictorarray)"
                 }//Displays clothespredictorarray on phone screen
         }
    }//When predictButton is tapped, the main code is run with the algorithm.
    
    func getLocation() {
        
            let locationEntryPreference = defaults.value(forKey: Keys.locationEntry) as? String ?? ""
//            guard let locationfield = locationEntryPreference else { return }
            
            self.locationManager.getLocation(forPlaceCalled: locationEntryPreference) { location in
                guard let location = location else { return }
                self.Latitude = location.coordinate.latitude //setting latitude
                self.Longitude = location.coordinate.longitude //setting longitude
    //            print(self.Latitude)
    //            print(self.Longitude)
                
            }
        }//getLocation gets coordinates of the location that the user typed in.
}

extension CLLocationManager {
    
    
    func getLocation(forPlaceCalled name: String,
                     completion: @escaping(CLLocation?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            guard let location = placemark.location else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }

            completion(location)
        }
    }
}//To translate user input to coordinates

