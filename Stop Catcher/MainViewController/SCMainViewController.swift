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
        
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
    }
    
    func didTapCatchAStopButton()
    {
        let pickAStopViewController = SCPickAStopViewController(nibName: "SCPickAStopViewController", bundle: nil)
        self.navigationController?.pushViewController(pickAStopViewController, animated: true)
    }

}
