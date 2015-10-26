//
//  SCUserDefaultsManager.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit
import MapKit

class SCUserDefaultsManager: NSObject
{
    
    var isCatchingStop : Bool {
        set
        {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "isCatchingStop")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        get
        {
            return NSUserDefaults.standardUserDefaults().boolForKey("isCatchingStop")
        }
    }
    
    var hasAskedForPushNotes : Bool {
        set
        {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "hasAskedForPushNotes")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        get
        {
            return NSUserDefaults.standardUserDefaults().boolForKey("hasAskedForPushNotes")
        }
    }
    
    var trackingLocation : CLLocationCoordinate2D? {
        
        set
        {
            if (newValue) != nil
            {
                let latitudeNumberValue = NSNumber(double: newValue!.latitude)
                let longitudeNumberValue = NSNumber(double: newValue!.longitude)
                let locationDictionary = ["latitudeNumberValue" : latitudeNumberValue, "longitudeNumberValue" : longitudeNumberValue]
                NSUserDefaults.standardUserDefaults().setObject(locationDictionary, forKey: "locationDictionary")
            }
            else
            {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("locationDictionary")
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        get
        {
            let locationDictionary : AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("locationDictionary")
            
            if (locationDictionary != nil)
            {
                let latitudeNumberValue : NSNumber = locationDictionary!["latitudeNumberValue"] as! NSNumber
                let longitudeNumberValue : NSNumber = locationDictionary!["longitudeNumberValue"] as! NSNumber
                return CLLocationCoordinate2D(latitude: latitudeNumberValue.doubleValue, longitude: longitudeNumberValue.doubleValue)
            }
            else
            {
                return nil
            }
            
        }
    
    }
    
}
