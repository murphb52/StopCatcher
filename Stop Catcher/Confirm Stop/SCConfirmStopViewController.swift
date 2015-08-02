//
//  SCConfirmStopViewController.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SCConfirmStopViewController: SCViewController, MKMapViewDelegate {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let kDistanceRadius = 2000.0

    var selectedLocation : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.confirmButton.addTarget(self, action: Selector("didTapConfirmButton"), forControlEvents:UIControlEvents.TouchUpInside)
        
        let mapRegion = MKCoordinateRegionMakeWithDistance(selectedLocation, 3000, 3000)
        self.mapView.setRegion(mapRegion, animated: false)
        
        
        let currentAnnotation = MKPointAnnotation()
        currentAnnotation.coordinate = selectedLocation
        self.mapView.addAnnotation(currentAnnotation)
        
        let circleView = MKCircle(centerCoordinate: selectedLocation, radius: kDistanceRadius as CLLocationDistance)
        self.mapView.addOverlay(circleView)
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle
        {
            var circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.4)
            circle.fillColor = UIColor.redColor().colorWithAlphaComponent(0.1)
            circle.lineWidth = 1
            return circle
        }
        else
        {
            return nil
        }
    }
    
    func didTapConfirmButton()
    {
        let localNotification = UILocalNotification()
        
        let regionToDetect = CLCircularRegion(center: selectedLocation, radius: kDistanceRadius, identifier: "Location Tracking")
        
        localNotification.regionTriggersOnce = true
        localNotification.region = regionToDetect
        localNotification.alertBody = "Time to wake up!"
        localNotification.alertTitle = "Wake up!"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
