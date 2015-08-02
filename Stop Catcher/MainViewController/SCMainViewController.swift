//
//  SCMainViewController.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit
import MapKit

class SCMainViewController: SCViewController {

    @IBOutlet weak var catchAStopButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.catchAStopButton.addTarget(self, action: Selector("didTapCatchAStopButton"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        
        if(SCUserDefaultsManager().isCatchingStop)
        {
            self.catchAStopButton.setTitle("Stop Catching a stop", forState: UIControlState.allZeros)
        }
        else
        {
            self.catchAStopButton.setTitle("Catch a stop", forState: UIControlState.allZeros)
        }
    }
    
    func didTapCatchAStopButton()
    {
        if(SCUserDefaultsManager().isCatchingStop)
        {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            SCUserDefaultsManager().isCatchingStop = false
            self.catchAStopButton.setTitle("Catch a stop", forState: UIControlState.allZeros)
            self.catchAStopButton.addTarget(self, action: Selector("didTapCatchAStopButton"), forControlEvents: UIControlEvents.TouchUpInside)

        }
        else
        {
            let pickAStopViewController = SCPickAStopViewController(nibName: "SCPickAStopViewController", bundle: nil)
            self.navigationController?.pushViewController(pickAStopViewController, animated: true)

        }
    }
}
