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

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate, MKMapViewDelegate {
        
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
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
                setMapViewDisplayed(false)
            }
        }
        else
        {
            self.setupViewForText("Looks like you are not catching a stop.\nTap here to get started")
            setMapViewDisplayed(false)
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
    
    func setMapViewDisplayed(_ display : Bool)
    {
        if display
        {
            self.mapViewHeightConstraint.constant = 120
        }
        else
        {
            self.mapViewHeightConstraint.constant = 0
        }
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
            setMapViewDisplayed(true)
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = SCUserDefaultsManager().trackingLocation!
            self.mapView.addAnnotation(pointAnnotation)
            
            zoomToFitMapAnnotations(self.mapView)
        }
        
    }

    @IBAction func didTapWidgetButton(_ sender: UIButton)
    {
        extensionContext?.open(URL(string: "stopcatcher://")!, completionHandler: nil)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation)
    {
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = mapView.userLocation.coordinate
        mapRegion.span.latitudeDelta = 0.2
        mapRegion.span.longitudeDelta = 0.2
        self.mapView.setRegion(mapRegion, animated: true)
        zoomToFitMapAnnotations(self.mapView)
    }
    
    func zoomToFitMapAnnotations(_ mapView : MKMapView)
    {
        if mapView.annotations.count == 0
        {
            return
        }
        
        var topLeftCoord = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        
        var bottomRightCoord = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        
        for annotation in mapView.annotations
        {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region : MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
        
        // Add a little extra space on the sides
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 2.0;
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 2.0;

        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation.isKind(of: MKUserLocation.classForCoder()))
        {
            return nil
        }
        
        let pinView = mapView .dequeueReusableAnnotationView(withIdentifier: "PinView")
        
        if ((pinView == nil))
        {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "PinView")
            
            let image = UIImage(named: "MapFlag")
            
            annotationView.image = image
            annotationView.frame = CGRect(x: 0, y: 0, width: 44, height: 56)
            
            return annotationView;
        }
        else
        {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
}
