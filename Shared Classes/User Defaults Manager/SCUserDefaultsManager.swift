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
    let sharedAppUserDefaults = NSUserDefaults(suiteName: "group.com.stopcatcher.StopCatcher")
    
    var isCatchingStop : Bool {
        set
        {
            sharedAppUserDefaults!.setBool(newValue, forKey: "isCatchingStop")
            sharedAppUserDefaults!.synchronize()
        }
        
        get
        {
            return sharedAppUserDefaults!.boolForKey("isCatchingStop")
        }
    }
    
    var hasAskedForPushNotes : Bool {
        set
        {
            sharedAppUserDefaults!.setBool(newValue, forKey: "hasAskedForPushNotes")
            sharedAppUserDefaults!.synchronize()
        }
        
        get
        {
            return sharedAppUserDefaults!.boolForKey("hasAskedForPushNotes")
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
                sharedAppUserDefaults!.setObject(locationDictionary, forKey: "locationDictionary")
            }
            else
            {
                sharedAppUserDefaults!.removeObjectForKey("locationDictionary")
            }
            sharedAppUserDefaults!.synchronize()
        }
        
        get
        {
            let locationDictionary : AnyObject? = sharedAppUserDefaults!.objectForKey("locationDictionary")
            
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
    
    var lastKnownLocation : CLLocationCoordinate2D? {
        
        set
        {
            if (newValue) != nil
            {
                let latitudeNumberValue = NSNumber(double: newValue!.latitude)
                let longitudeNumberValue = NSNumber(double: newValue!.longitude)
                let locationDictionary = ["latitudeNumberValue" : latitudeNumberValue, "longitudeNumberValue" : longitudeNumberValue]
                sharedAppUserDefaults!.setObject(locationDictionary, forKey: "lastKnownlocationDictionary")
            }
            else
            {
                sharedAppUserDefaults!.removeObjectForKey("lastKnownlocationDictionary")
            }
            sharedAppUserDefaults!.synchronize()
        }

        get {
            let locationDictionary : AnyObject? = sharedAppUserDefaults!.objectForKey("lastKnownlocationDictionary")
            
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
