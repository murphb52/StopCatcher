//
//  SCMainViewController.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit
import MapKit

class SCMainViewController: SCViewController, CLLocationManagerDelegate
{
    var locationManager : CLLocationManager!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var blurredView: UIView!
    @IBOutlet weak var enableLocationPermissionButton: UIButton!
    
    @IBOutlet weak var myLocationButton: UIButton!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Stop Catcher"

        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //***** Setup locationPermission button
        self.enableLocationPermissionButton.addTarget(self, action: Selector("handleEnablePermissionButtonTap"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.myLocationButton.layer.borderColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0).CGColor
        self.myLocationButton.layer.borderWidth = 1;
        self.myLocationButton.layer.cornerRadius = 10;
        self.myLocationButton.layer.masksToBounds = true
        self.myLocationButton.addTarget(self, action: Selector("handleMyLocationButtonTapped"), forControlEvents: UIControlEvents.TouchUpInside)
        
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
        let region = MKCoordinateRegionMakeWithDistance(coords, 2000, 2000)
        mapView.setRegion(region, animated: true)
    }

}
