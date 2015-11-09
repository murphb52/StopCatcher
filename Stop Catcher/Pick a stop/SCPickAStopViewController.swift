//
//  SCPickAStopViewController.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit
import MapKit

class SCPickAStopViewController: SCViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedLocation : CLLocationCoordinate2D!
    var currentRadius : Double = 0.0
    var currentAnnotation : MKPointAnnotation!
    var continueButton : UIBarButtonItem!
    var locationManager : CLLocationManager!
    
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var blurredView: UIVisualEffectView!
    @IBOutlet weak var buttonHolderView: UIView!
    
    @IBOutlet weak var radiusSlider: UISlider!
    
    let maxRadius : Double = 2000.0
    let minRadius : Double = 250.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pick A Location!"
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: Selector("handleTapGesture:"))
        self.mapView .addGestureRecognizer(longPressGesture)
        
        self.continueButton = UIBarButtonItem(title: "Continue", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("handleTappedContinueButton"))
        self.continueButton.enabled = false;
        self.navigationItem.rightBarButtonItem = self.continueButton
        
        self.buttonHolderView.layer.cornerRadius = 10
        self.buttonHolderView.layer.masksToBounds = true
     
        let authStatus = CLLocationManager.authorizationStatus()
        self.switchOnAuthStatus(authStatus)
        
    }

    func handleTapGesture(recognizer : UILongPressGestureRecognizer)
    {
        if(recognizer.state == UIGestureRecognizerState.Ended)
        {
            self.removeAllAnnotations()
            self.mapView.removeOverlays(self.mapView.overlays)
            
            let tappedPoint = recognizer.locationInView(self.mapView)
            
            let tappedLocation = self.mapView.convertPoint(tappedPoint, toCoordinateFromView: self.view)
            
            currentAnnotation = MKPointAnnotation()
            
            currentAnnotation.coordinate = tappedLocation
            
            selectedLocation = tappedLocation
            
            self.mapView.addAnnotation(currentAnnotation)
            
            let circleView = MKCircle(centerCoordinate: selectedLocation, radius: maxRadius/2 as CLLocationDistance)
            self.mapView.addOverlay(circleView)
            
            self.continueButton.enabled = true;
            
            self.radiusSlider.hidden = false;
        }

    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
    {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.4)
        circle.fillColor = UIColor.redColor().colorWithAlphaComponent(0.1)
        circle.lineWidth = 1
        return circle
    }
    
    //***** Remove all annotations and only leave the user location annotation if it is present
    func removeAllAnnotations()
    {
        let userLocationAnnotation = mapView.userLocation
        
        self.mapView.removeAnnotations(mapView.annotations)
        
        self.mapView.addAnnotation(userLocationAnnotation)

    }
    
    //***** Animate the addition of the annotation
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView])
    {
        
        for view in views {
            let mkView = view 
            if view.annotation is MKUserLocation {
                continue;
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            let point:MKMapPoint  =  MKMapPointForCoordinate(mkView.annotation!.coordinate);
            if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                continue;
            }
            
            let endFrame:CGRect = mkView.frame;
            
            // Move annotation out of view
            mkView.frame = CGRectMake(mkView.frame.origin.x, mkView.frame.origin.y - self.view.frame.size.height, mkView.frame.size.width, mkView.frame.size.height);
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations:{() in
                mkView.frame = endFrame
                // Animate squash
                }, completion:{(Bool) in
                    UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                        mkView.transform = CGAffineTransformMakeScale(1.0, 0.8)
                        
                        }, completion: {(Bool) in
                            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                                mkView.transform = CGAffineTransformIdentity
                                }, completion: nil)
                    })
                    
            })
        }
    }

    
    func handleTappedContinueButton()
    {
        let confirmStopViewController = SCConfirmStopViewController(nibName: "SCConfirmStopViewController", bundle: nil)
        confirmStopViewController.selectedLocation = selectedLocation
        confirmStopViewController.radius = self.currentRadius
        self.navigationController?.pushViewController(confirmStopViewController, animated: true)
    }
    
    @IBAction func radiusSliderValueDidChange(sender: AnyObject) {

        // 0 == min
        // 1 == max
        
        self.mapView.removeOverlays(self.mapView.overlays)
        let radius = Double(self.radiusSlider.value) * maxRadius
        let circleView = MKCircle(centerCoordinate: selectedLocation, radius: radius)
        self.mapView.addOverlay(circleView)
        
        self.currentRadius = radius
    }
    
    @IBAction func askForUserLocation(sender: AnyObject)
    {
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        self.switchOnAuthStatus(status)
    }
    
    func switchOnAuthStatus(authStatus : CLAuthorizationStatus)
    {
        self.blurredView.alpha = 0;
        self.blurredView.hidden = false
UIView.animateWithDuration(0.3, animations: { () -> Void in
    
    switch authStatus
    {
    case .Restricted:
        self.blurredView.alpha = 1
    case .NotDetermined:
        self.blurredView.alpha = 1
    case .Denied:
        self.blurredView.alpha = 1
    case .AuthorizedWhenInUse:
        self.blurredView.alpha = 0
    case .AuthorizedAlways:
        self.blurredView.alpha = 0
    }
    
}) { (completed) -> Void in
    
    switch authStatus
    {
    case .Restricted:
        self.blurredView.hidden = false
    case .NotDetermined:
        self.blurredView.hidden = false
    case .Denied:
        self.blurredView.hidden = false
    case .AuthorizedWhenInUse:
        self.blurredView.hidden = true
    case .AuthorizedAlways:
        self.blurredView.hidden = true
    }
    
        }

    }
}
