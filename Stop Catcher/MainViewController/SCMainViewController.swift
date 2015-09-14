//
//  SCMainViewController.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit
import MapKit

class SCMainViewController: SCViewController, CLLocationManagerDelegate, MKMapViewDelegate
{
    var locationManager : CLLocationManager!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var blurredView: UIView!
    @IBOutlet weak var enableLocationPermissionButton: UIButton!
    
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var stopWatchButton: UIButton!
    
    @IBOutlet weak var beginTrackingButton: UIButton!
    
    @IBOutlet weak var stopWatchHolderView: UIView!
    @IBOutlet weak var stopWatchWidthConstrant: NSLayoutConstraint!
    var stopWatchButtonIsLarge : Bool = false
    
    let maxRadius : Double = 2000.0
    let minRadius : Double = 250.0
    
    @IBOutlet weak var stopWatchHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Stop Catcher"

        self.mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //***** Setup locationPermission button
        self.enableLocationPermissionButton.addTarget(self, action: Selector("handleEnablePermissionButtonTap"), forControlEvents: UIControlEvents.TouchUpInside)
        
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
        self.beginTrackingButton.layer.cornerRadius = 5;
        self.beginTrackingButton.layer.masksToBounds = true
        self.beginTrackingButton.tintColor = grayColor
        self.beginTrackingButton.backgroundColor = purpleColor

        
        let circleView = MKCircle(centerCoordinate: self.mapView.region.center, radius: maxRadius/2 as CLLocationDistance)
        self.mapView.addOverlay(circleView)
        
        //***** Setup our view for the state of our authStatus
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
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
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
    }
    
    func setupForUnAuthorizedLocationPermission(animated: Bool)
    {
        let duration = animated ? 0.3 : 0.0
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            self.blurView.alpha = 1;
            
        })
    }
    
    func handleMyLocationButtonTapped()
    {
        let userLocation = self.mapView.userLocation
        let coords = userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(coords, maxRadius*2.0, maxRadius*2.0)
        mapView.setRegion(region, animated: true)
    }

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool)
    {
        self.mapView.removeOverlays(self.mapView.overlays)
        let circleView = MKCircle(centerCoordinate: mapView.centerCoordinate, radius: maxRadius)
        self.mapView.addOverlay(circleView)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle
        {
            var circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0)
            circle.fillColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0).colorWithAlphaComponent(0.3)
            circle.lineWidth = 1
            return circle
        }
        else
        {
            return nil
        }
    }
    
    func handleStopwatchButtonTapped()
    {
        var newButtonWidth : CGFloat
        var newButtonHeight : CGFloat
        var labelAlpha : CGFloat
        var image : UIImage
        
        if(self.stopWatchButtonIsLarge)
        {
            newButtonWidth = 44.0
            newButtonHeight = 44.0
            labelAlpha = 0
            image = UIImage(named: "Stopwatch")!
        }
        else
        {
            newButtonWidth = 216
            newButtonHeight = 162
            labelAlpha = 1
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
            
            self.stopWatchButton.setImage(image, forState: UIControlState.allZeros)
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.stopWatchButton.alpha = 1
            })
            
        }
        
    }
}
