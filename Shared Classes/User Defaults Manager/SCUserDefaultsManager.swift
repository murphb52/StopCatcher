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
    let sharedAppUserDefaults = UserDefaults(suiteName: "group.com.stopcatcher.StopCatcher")
    
    var isCatchingStop : Bool {
        set
        {
            sharedAppUserDefaults!.set(newValue, forKey: "isCatchingStop")
            sharedAppUserDefaults!.synchronize()
        }
        
        get
        {
            return sharedAppUserDefaults!.bool(forKey: "isCatchingStop")
        }
    }
    
    var hasAskedForPushNotes : Bool {
        set
        {
            sharedAppUserDefaults!.set(newValue, forKey: "hasAskedForPushNotes")
            sharedAppUserDefaults!.synchronize()
        }
        
        get
        {
            return sharedAppUserDefaults!.bool(forKey: "hasAskedForPushNotes")
        }
    }
    
    var trackingLocation : CLLocationCoordinate2D? {
        
        set
        {
            if (newValue) != nil
            {
                let latitudeNumberValue = NSNumber(value: newValue!.latitude as Double)
                let longitudeNumberValue = NSNumber(value: newValue!.longitude as Double)
                let locationDictionary = ["latitudeNumberValue" : latitudeNumberValue, "longitudeNumberValue" : longitudeNumberValue]
                sharedAppUserDefaults!.set(locationDictionary, forKey: "locationDictionary")
            }
            else
            {
                sharedAppUserDefaults!.removeObject(forKey: "locationDictionary")
            }
            sharedAppUserDefaults!.synchronize()
        }
        
        get
        {
            let locationDictionary : AnyObject? = sharedAppUserDefaults!.object(forKey: "locationDictionary") as AnyObject?
            
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
