//
//  SCPickAStopViewController.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit
import MapKit

class SCPickAStopViewController: SCViewController, MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"))
        tapGestureRecogniser.numberOfTapsRequired = 1
        self.mapView .addGestureRecognizer(tapGestureRecogniser)
        
    }

    func handleTapGesture(recognizer : UITapGestureRecognizer)
    {
        let confirmStopViewController = SCConfirmStopViewController(nibName: "SCConfirmStopViewController", bundle: nil)
        self.navigationController?.pushViewController(confirmStopViewController, animated: true)
    }
}
