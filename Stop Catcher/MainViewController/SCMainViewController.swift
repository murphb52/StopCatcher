//
//  SCMainViewController.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit
import MapKit

class SCMainViewController: SCViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate
{
    var locationManager : CLLocationManager!

    
    @IBOutlet weak var blurredViewButton: UIButton!
    @IBOutlet weak var blurredViewLabel: UILabel!
    @IBOutlet weak var blurredView: UIView!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var blurredViewAlertView: UIView!
    
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var stopWatchButton: UIButton!
    
    @IBOutlet weak var beginTrackingButton: UIButton!
    
    @IBOutlet weak var stopWatchHolderView: UIView!
    @IBOutlet weak var stopWatchWidthConstrant: NSLayoutConstraint!
    var stopWatchButtonIsLarge : Bool = false
    
    let maxRadius : Double = 2000.0
    let minRadius : Double = 250.0
    
    @IBOutlet weak var centeredMapFlag: UIImageView!
    
    @IBOutlet weak var stopWatchHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    var hasPickedTime = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Stop Catcher"

        self.mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        
        self.myLocationButton.layer.borderColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0).CGColor
        self.myLocationButton.layer.borderWidth = 1;
        self.myLocationButton.layer.cornerRadius = 10;
        self.myLocationButton.layer.masksToBounds = true
        self.myLocationButton.addTarget(self, action: Selector("handleMyLocationButtonTapped"), forControlEvents: UIControlEvents.TouchUpInside)

        self.stopWatchHolderView.layer.borderColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0).CGColor
        self.stopWatchHolderView.layer.borderWidth = 1;
        self.stopWatchHolderView.layer.cornerRadius = 10;
        self.stopWatchHolderView.layer.masksToBounds = true
        self.stopWatchButton.addTarget(self, action: Selector("handleStopwatchButtonTapped"), forControlEvents: UIControlEvents.TouchUpInside)

        let grayColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        let purpleColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0)
        self.beginTrackingButton.addTarget(self, action: Selector("handleBeginTrackingButtonTapped"), forControlEvents: UIControlEvents.TouchUpInside)
        self.beginTrackingButton.layer.cornerRadius = 5;
        self.beginTrackingButton.layer.masksToBounds = true
        self.beginTrackingButton.tintColor = grayColor
        self.beginTrackingButton.backgroundColor = purpleColor
        
        //***** Setup locationPermission button
        self.blurredViewButton.addTarget(self, action: Selector("handleEnablePermissionButtonTap"), forControlEvents: UIControlEvents.TouchUpInside)
        self.blurredViewButton.layer.cornerRadius = 5;
        self.blurredViewButton.layer.masksToBounds = true
        self.blurredViewButton.tintColor = grayColor
        self.blurredViewButton.backgroundColor = purpleColor
        
        self.blurredViewAlertView.layer.cornerRadius = 5
        self.blurredViewAlertView.layer.masksToBounds = true
                
        let circleView = MKCircle(centerCoordinate: self.mapView.region.center, radius: maxRadius/2 as CLLocationDistance)
        self.mapView.addOverlay(circleView)
        
        let pickedTime = NSDate(timeIntervalSince1970: 0)
        self.timePicker.setDate(pickedTime, animated: true)
        
        self.updateUI()
        
        //***** Setup our view for the state of our authStatus
        setupViewForAuthStatus(CLLocationManager.authorizationStatus(), animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
        setupViewForAuthStatus(CLLocationManager.authorizationStatus(), animated: false)
    }
    
    func handleEnablePermissionButtonTap()
    {
        //***** If we have not asked for permission we request permission
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined)
        {
            locationManager.requestAlwaysAuthorization()
        }
        //***** If we have asked before we simply point the user to the settings
        else
        {
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(settingsUrl!)
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        setupViewForAuthStatus(status, animated: true)
    }

    func setupViewForAuthStatus(authStatus: CLAuthorizationStatus, animated: Bool)
    {
        switch(authStatus)
        {
        case .AuthorizedAlways:
            setupForAuthorizedLocationPermission(animated)
            break
        case .AuthorizedWhenInUse:
            setupForUnAuthorizedLocationPermission(animated)
            break
        case .Denied:
            setupForUnAuthorizedLocationPermission(animated)
            break
        case .Restricted:
            setupForUnAuthorizedLocationPermission(animated)
        case .NotDetermined:
            setupForUnAuthorizedLocationPermission(animated)
            break
        }
    }
    
    func setupForAuthorizedLocationPermission(animated: Bool)
    {
        self.mapView.showsUserLocation = true

        let duration = animated ? 0.3 : 0.0
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            self.blurView.alpha = 0;
            
        })
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setupForUnAuthorizedLocationPermission(animated: Bool)
    {
        let duration = animated ? 0.3 : 0.0
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            self.blurView.alpha = 1;
            
        })
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func handleMyLocationButtonTapped()
    {
        let userLocation = self.mapView.userLocation
        let coords = userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(coords, maxRadius*2.0, maxRadius*2.0)
        mapView.setRegion(region, animated: true)
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        if(SCUserDefaultsManager().isCatchingStop == false)
        {
            self.updateRadiusCircle()
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
    {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0)
        circle.fillColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0).colorWithAlphaComponent(0.3)
        circle.lineWidth = 1
        return circle
    }
    
    func handleStopwatchButtonTapped()
    {
        var newButtonWidth : CGFloat
        var newButtonHeight : CGFloat
        var image : UIImage
        
        if(self.stopWatchButtonIsLarge)
        {
            newButtonWidth = 44.0
            newButtonHeight = 44.0
            image = UIImage(named: "Stopwatch")!
        }
        else
        {
            newButtonWidth = 216
            newButtonHeight = 162
            image = UIImage(named: "TickImage")!
        }

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.stopWatchWidthConstrant.constant = newButtonWidth
            self.stopWatchHeightConstraint.constant = newButtonHeight
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()

        }) { (finished) -> Void in
            
            self.stopWatchButtonIsLarge = !self.stopWatchButtonIsLarge
        }
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            
            self.stopWatchButton.alpha = 0;
            
        }) { (finished) -> Void in
            
            self.stopWatchButton.setImage(image, forState: UIControlState())
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.stopWatchButton.alpha = 1
            })
            
        }
        
    }

    @IBAction func handleTimePickerValueChanged(sender: AnyObject)
    {
        self.hasPickedTime = true
    }
    
    func updateUI()
    {
        if(SCUserDefaultsManager().isCatchingStop == true)
        {
            self.beginTrackingButton.setTitle("Stop Tracking", forState: UIControlState())
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.centeredMapFlag.alpha = 0;
            })
            
            self.removeAllAnnotations()
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = SCUserDefaultsManager().trackingLocation!
            self.mapView.addAnnotation(pointAnnotation)
        }
        else
        {
            self.beginTrackingButton.setTitle("Begin Tracking", forState: UIControlState())
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.centeredMapFlag.alpha = 1;
            })
            
            self.removeAllAnnotations()
        }
        
        self.updateRadiusCircle()
    }

    //***** Remove all annotations and only leave the user location annotation if it is present
    func removeAllAnnotations()
    {
        let userLocationAnnotation = mapView.userLocation
        
        self.mapView.removeAnnotations(mapView.annotations)
        
        self.mapView.addAnnotation(userLocationAnnotation)
    }
    
    func updateRadiusCircle()
    {
        if(SCUserDefaultsManager().isCatchingStop == true)
        {
            self.mapView.removeOverlays(self.mapView.overlays)
            let circleView = MKCircle(centerCoordinate: SCUserDefaultsManager().trackingLocation!, radius: maxRadius)
            self.mapView.addOverlay(circleView)
        }
        else
        {
            self.mapView.removeOverlays(self.mapView.overlays)
            let circleView = MKCircle(centerCoordinate: mapView.centerCoordinate, radius: maxRadius)
            self.mapView.addOverlay(circleView)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        
        switch(CLLocationManager.authorizationStatus())
        {
        case .AuthorizedAlways:
            return UIStatusBarStyle.LightContent
        case .AuthorizedWhenInUse:
            return UIStatusBarStyle.LightContent
        case .Denied:
            return UIStatusBarStyle.Default
        case .Restricted:
            return UIStatusBarStyle.Default
        case .NotDetermined:
            return UIStatusBarStyle.Default
        }
    }
    
    func didTapConfirmButton()
    {
        //***** Check if we have asked for push notications
        if(SCUserDefaultsManager().hasAskedForPushNotes)
        {
            
            let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
            if (notificationSettings!.types == UIUserNotificationType.None)
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
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
            SCUserDefaultsManager().hasAskedForPushNotes = true
        }
        
    }
    
    func setupStopToCatch()
    {
        SCUserDefaultsManager().isCatchingStop = true
        
        let localNotification = UILocalNotification()
        
        let regionToDetect = CLCircularRegion(center: self.mapView.centerCoordinate, radius: maxRadius, identifier: "Location Tracking")
        
        localNotification.regionTriggersOnce = true
        localNotification.region = regionToDetect
        localNotification.alertBody = "Time to wake up!"
        localNotification.alertTitle = "Wake up!"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        let timedNotification = UILocalNotification()
        timedNotification.fireDate = NSDate(timeIntervalSinceNow: self.timePicker.countDownDuration)
        timedNotification.alertBody = "Timed wake up!"
        timedNotification.alertTitle = "Wake up!"
        
        UIApplication.sharedApplication().scheduleLocalNotification(timedNotification)
    }
    
    func handleBeginTrackingButtonTapped()
    {
        var title : String?
        var message : String?
        
        if (SCUserDefaultsManager().isCatchingStop)
        {
            title = "Stop Tracking"
            message = "Are you sure you want to stop tracking this location?"
        }
        else
        {
            title = "Begin Tracking"
            message = "Are you sure you want to start tracking this location?"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            if (SCUserDefaultsManager().isCatchingStop == true)
            {
                SCUserDefaultsManager().isCatchingStop = false
                SCUserDefaultsManager().trackingLocation = nil
            }
            else
            {
                SCUserDefaultsManager().isCatchingStop = true
                SCUserDefaultsManager().trackingLocation = self.mapView.centerCoordinate
                
                self.didTapConfirmButton()
            }
            
            self.updateUI()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            
            
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: Refactoring 
    
    func showBlurredOverlay()
    {
        
    }
    
    func hideBlurredOverlay()
    {
        
    }
    
    func updateViewForCatchingStop()
    {
        
    }
    
    func updateViewForNotCatchingAStop()
    {
        
    }
    
    //MARK: Selectors for confirm button
    
    func didTapCatchAStopButton()
    {
        
    }
    
    func didTapConfirmCatchAStopButton()
    {
        
    }
    
    func didTapStopCatchingAStopButton()
    {
        
    }
    
    func didTapConfirmStopCatchingStopButton()
    {
        
    }
    
    func didTapOverlayButton()
    {
        
    }
    
    //MARK: Map Button
    
    func didTapClockButton()
    {
        
    }
    
    func didTapMyLocationButton()
    {
        
    }
    
    //MARK: Local Notifications
    
    func addLocationNotificationAtCurrentPoint()
    {
        
    }
    
    func removeAllLocalNotifications()
    {
        
    }

    //MARK: MapView Methods

    
}
