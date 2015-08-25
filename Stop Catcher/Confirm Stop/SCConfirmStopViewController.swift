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

class SCConfirmStopViewController: SCViewController, MKMapViewDelegate, UIAlertViewDelegate {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let kDistanceRadius = 2000.0

    var selectedLocation : CLLocationCoordinate2D!
    var radius : Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.confirmButton.addTarget(self, action: Selector("didTapConfirmButton"), forControlEvents:UIControlEvents.TouchUpInside)
        
        let mapRegion = MKCoordinateRegionMakeWithDistance(selectedLocation, 3000, 3000)
        self.mapView.setRegion(mapRegion, animated: false)
        
        
        let currentAnnotation = MKPointAnnotation()
        currentAnnotation.coordinate = selectedLocation
        self.mapView.addAnnotation(currentAnnotation)
        
        let circleView = MKCircle(centerCoordinate: selectedLocation, radius: radius as CLLocationDistance)
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
        //***** Check if we have asked for push notications
        if(SCUserDefaultsManager().hasAskedForPushNotes)
        {

            let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
            if (notificationSettings.types == UIUserNotificationType.None)
            {
                //***** Tell them to turn on Push notes
                let pushNotesAlertView = UIAlertView(title: "Notifications!", message: "Notifications are turned off!\nStop Catcher will only ever send you notifications to wake you up", delegate: self, cancelButtonTitle: "Cancel")
                pushNotesAlertView.addButtonWithTitle("Settings")
                pushNotesAlertView.show()
            }
            else
            {
                //***** Finish setting up the current catch
                self.setupStopToCatch()
            }

        }
        //***** Ask for push notes
        else
        {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: nil))
            SCUserDefaultsManager().hasAskedForPushNotes = true
        }
        
    }
    
    func setupStopToCatch()
    {
        SCUserDefaultsManager().isCatchingStop = true
        
        let localNotification = UILocalNotification()
        
        let regionToDetect = CLCircularRegion(center: selectedLocation, radius: radius, identifier: "Location Tracking")
        
        localNotification.regionTriggersOnce = true
        localNotification.region = regionToDetect
        localNotification.alertBody = "Time to wake up!"
        localNotification.alertTitle = "Wake up!"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        let timedNotification = UILocalNotification()
        timedNotification.fireDate = NSDate(timeIntervalSinceNow: self.datePicker.countDownDuration)
        timedNotification.alertBody = "Timed wake up!"
        timedNotification.alertTitle = "Wake up!"
        
        UIApplication.sharedApplication().scheduleLocalNotification(timedNotification)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int)
    {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
}
