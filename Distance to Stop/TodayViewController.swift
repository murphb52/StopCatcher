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
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void))
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
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func isLocationPermissionGranted(_ status : CLAuthorizationStatus) -> Bool
    {
        switch(status)
        {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .denied, .restricted, .notDetermined:
            return false
        }
    }
    
    func setupViewForLoading()
    {
        loadingActivityIndicator.startAnimating()
        self.mainLabel.isHidden = true
    }
    
    func setupViewForText(_ text : String)
    {
        loadingActivityIndicator.stopAnimating()
        self.mainLabel.text = text
        self.mainLabel.isHidden = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if SCUserDefaultsManager().isCatchingStop
        {
            let mostRecentLocation : CLLocation = locations.last!
            
            let destinationLocation2D : CLLocationCoordinate2D = SCUserDefaultsManager().trackingLocation!
            let destinationLocation = CLLocation(latitude: destinationLocation2D.latitude, longitude: destinationLocation2D.longitude)
            
            let distance : CLLocationDistance = destinationLocation.distance(from: mostRecentLocation)
            
            let distanceFormatter = MKDistanceFormatter()
            distanceFormatter.unitStyle = .full
            
            setupViewForText("Distance to stop: \(distanceFormatter.string(fromDistance: distance))\nTap to view in the app")
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = SCUserDefaultsManager().trackingLocation!
        }
        
    }

    @IBAction func didTapWidgetButton(_ sender: UIButton)
    {
        extensionContext?.open(URL(string: "stopcatcher://")!, completionHandler: nil)
    }
}
