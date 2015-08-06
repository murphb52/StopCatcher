//
//  SCUserDefaultsManager.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit

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
    
}
