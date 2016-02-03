//
//  TodayViewController.swift
//  Distance to Stop
//
//  Created by Brian Murphy on 03/02/2016.
//  Copyright © 2016 Stop Catcher. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation
import MapKit

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
        
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupViewForLoading()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void))
    {
        if SCUserDefaultsManager().isCatchingStop
        {
            self.setupViewForLoading()
            
            if isLocationPermissionGranted(CLLocationManager.authorizationStatus())
            {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
            else
            {
                self.setupViewForText("Looks like you have turned off your location permission.\nKeep an eye on the app to see how close you are to your stop")
            }
        }
        else
        {
            self.setupViewForText("Looks like you are not catching a stop.\nTap here to get started")
        }
        
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func isLocationPermissionGranted(status : CLAuthorizationStatus) -> Bool
    {
        switch(status)
        {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            return true
        case .Denied, .Restricted, .NotDetermined:
            return false
        }
    }
    
    func setupViewForLoading()
    {
        loadingActivityIndicator.startAnimating()
        self.mainLabel.hidden = true
    }
    
    func setupViewForText(text : String)
    {
        loadingActivityIndicator.stopAnimating()
        self.mainLabel.text = text
        self.mainLabel.hidden = false
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if SCUserDefaultsManager().isCatchingStop
        {
            let mostRecentLocation : CLLocation = locations.last!
            
            let destinationLocation2D : CLLocationCoordinate2D = SCUserDefaultsManager().trackingLocation!
            let destinationLocation = CLLocation(latitude: destinationLocation2D.latitude, longitude: destinationLocation2D.longitude)
            
            let distance : CLLocationDistance = destinationLocation.distanceFromLocation(mostRecentLocation)
            
            let distanceFormatter = MKDistanceFormatter()
            distanceFormatter.unitStyle = .Full
            
            setupViewForText("Distance to stop: \(distanceFormatter.stringFromDistance(distance))\nTap to view on a map")
        }
        
    }

    @IBAction func didTapWidgetButton(sender: UIButton)
    {
        extensionContext?.openURL(NSURL(string: "stopcatcher://")!, completionHandler: nil)
    }
}
