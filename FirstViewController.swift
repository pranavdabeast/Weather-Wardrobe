//
//  FirstViewController.swift
//  Weather Wardrobe
//
//  Created by Pranav Mukund on 4/24/20.
//  Copyright © 2020 Pranav Mukund. All rights reserved.
//

import UIKit
 
class FirstViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard //Userdefaults to store clothing preferences

    @IBOutlet weak var seventyAboveField: UITextField!
    @IBOutlet weak var fortyAboveField: UITextField!
    @IBOutlet weak var fortyBelowField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    
    struct Keys {
        static let seventyaboveweather = "seventyaboveweather"
        static let fortyaboveweather = "fortyaboveweather"
        static let fortybelowweather = "fortybelowweather"
        static let locationEntry = "locationEntry"
    } //To prevent spelling errors in keys for Defaults
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        seventyAboveField.delegate = self
        fortyAboveField.delegate = self
        fortyBelowField.delegate = self
        zipCodeField.delegate = self
        
        checkForSavedPreferences()
        

    }
    

    @IBAction func savePreferencesButtonTapped(_ sender: Any) {
        saveWeatherPreferences()
    }//Sets input information as default
    
    func saveWeatherPreferences() {
        defaults.set(seventyAboveField.text!, forKey: Keys.seventyaboveweather)
        defaults.set(fortyAboveField.text!, forKey: Keys.fortyaboveweather)
        defaults.set(fortyBelowField.text!, forKey: Keys.fortybelowweather)
        defaults.set(zipCodeField.text!, forKey: Keys.locationEntry)
    } //Sets input information as default
    
    func checkForSavedPreferences() {
        let seventyaboveclothingpreference = defaults.value(forKey: Keys.seventyaboveweather) as? String ?? ""
        let fortyaboveclothingpreference = defaults.value(forKey: Keys.fortyaboveweather) as? String ?? ""
        let fortybelowclothingpreference = defaults.value(forKey: Keys.fortybelowweather) as? String ?? ""
        let locationEntryPreference = defaults.value(forKey: Keys.locationEntry) as? String ?? ""
        
        seventyAboveField.text = seventyaboveclothingpreference
        fortyAboveField.text = fortyaboveclothingpreference
        fortyBelowField.text = fortybelowclothingpreference
        zipCodeField.text = locationEntryPreference
        
    } //Fills in default information when app is opened
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        seventyAboveField.resignFirstResponder()
        fortyAboveField.resignFirstResponder()
        fortyBelowField.resignFirstResponder()
        zipCodeField.resignFirstResponder()
        return true
    }
    
}

