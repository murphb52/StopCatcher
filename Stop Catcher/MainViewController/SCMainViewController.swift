//
//  SCMainViewController.swift
//  Stop Catcher
//
//  Created by Brian Murphy on 02/08/2015.
//  Copyright (c) 2015 Stop Catcher. All rights reserved.
//

import UIKit
import MapKit

class SCMainViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate
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
    
    @IBOutlet weak var centeredMapImageView: UIImageView!
    @IBOutlet weak var stopWatchHolderView: UIView!
    @IBOutlet weak var stopWatchWidthConstrant: NSLayoutConstraint!
    var stopWatchButtonIsLarge : Bool = false
    
    let maxRadius : Double = 200.0
    
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
        
        
        self.myLocationButton.layer.borderColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0).cgColor
        self.myLocationButton.layer.borderWidth = 1;
        self.myLocationButton.layer.cornerRadius = 10;
        self.myLocationButton.layer.masksToBounds = true
        self.myLocationButton.addTarget(self, action: #selector(SCMainViewController.handleMyLocationButtonTapped), for: UIControlEvents.touchUpInside)

        self.stopWatchHolderView.layer.borderColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0).cgColor
        self.stopWatchHolderView.layer.borderWidth = 1;
        self.stopWatchHolderView.layer.cornerRadius = 10;
        self.stopWatchHolderView.layer.masksToBounds = true
        self.stopWatchButton.addTarget(self, action: #selector(SCMainViewController.handleStopwatchButtonTapped), for: UIControlEvents.touchUpInside)

        let grayColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        let purpleColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0)
        self.beginTrackingButton.layer.cornerRadius = 5;
        self.beginTrackingButton.layer.masksToBounds = true
        self.beginTrackingButton.tintColor = grayColor
        self.beginTrackingButton.backgroundColor = purpleColor
        
        //***** Setup locationPermission button
        self.blurredViewButton.addTarget(self, action: #selector(SCMainViewController.didTapOverlayButton), for: UIControlEvents.touchUpInside)
        self.blurredViewButton.layer.cornerRadius = 5;
        self.blurredViewButton.layer.masksToBounds = true
        self.blurredViewButton.tintColor = grayColor
        self.blurredViewButton.backgroundColor = purpleColor
        
        self.blurredViewAlertView.layer.cornerRadius = 5
        self.blurredViewAlertView.layer.masksToBounds = true
                
        let circleView = MKCircle(center: self.mapView.region.center, radius: maxRadius/2 as CLLocationDistance)
        self.mapView.add(circleView)
        
        let pickedTime = Date(timeIntervalSince1970: 0)
        self.timePicker.setDate(pickedTime, animated: true)
        
        self.updateUI()
        
        //***** Setup our view for the state of our authStatus
        setupViewForAuthStatus(CLLocationManager.authorizationStatus(), animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
        setupViewForAuthStatus(CLLocationManager.authorizationStatus(), animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateUI()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        setupViewForAuthStatus(status, animated: true)
    }
    
    //MARK: Refactoring
    
    func setupViewForAuthStatus(_ authStatus: CLAuthorizationStatus, animated: Bool)
    {
        switch(authStatus)
        {
        case .authorizedAlways, .authorizedWhenInUse:
            self.hideBlurredOverlay(animated)
            break
        case .denied, .restricted, .notDetermined:
            self.showBlurredOverlay(animated)
            break
        }
        
        self.updateUI()
    }
    
    func showBlurredOverlay(_ animated : Bool)
    {
        self.mapView.showsUserLocation = true
        
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration, animations: { () -> Void in
            
            self.blurView.alpha = 1;
            
        })
        
        UIApplication.shared.setStatusBarStyle(.default, animated: animated)
    }
    
    func hideBlurredOverlay(_ animated : Bool)
    {
        self.mapView.showsUserLocation = true
        
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration, animations: { () -> Void in
            
            self.blurView.alpha = 0;
            
        })
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: animated)
    }
    
    func updateUI()
    {
        if(SCUserDefaultsManager().isCatchingStop == true)
        {
            self.updateViewForCatchingStop()
        }
        else
        {
            self.updateViewForNotCatchingAStop()
        }
    }
    
    func updateViewForCatchingStop()
    {
        self.beginTrackingButton .removeTarget(nil, action: nil, for: .allEvents)
        self.beginTrackingButton.setTitle("Stop Tracking", for: UIControlState())
        self.beginTrackingButton.addTarget(self, action: #selector(SCMainViewController.didTapConfirmStopCatchingStopButton), for: UIControlEvents.touchUpInside)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.centeredMapFlag.alpha = 0;
        })
        
        self.removeAllAnnotations()
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = SCUserDefaultsManager().trackingLocation!
        self.mapView.addAnnotation(pointAnnotation)
        self.updateRadiusCircle()
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
    
    func updateViewForNotCatchingAStop()
    {
        self.beginTrackingButton .removeTarget(nil, action: nil, for: .allEvents)
        self.beginTrackingButton.setTitle("Begin Tracking", for: UIControlState())
        self.beginTrackingButton.addTarget(self, action: #selector(SCMainViewController.didTapConfirmCatchAStopButton), for: UIControlEvents.touchUpInside)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.centeredMapFlag.alpha = 1;
        })
        
        self.removeAllAnnotations()
        self.updateRadiusCircle()
    }
    
    //MARK: Selectors for confirm button
    
    func didTapConfirmCatchAStopButton()
    {
        //***** Check if we have asked for push notications
        if(SCUserDefaultsManager().hasAskedForPushNotes)
        {
            
            let notificationSettings = UIApplication.shared.currentUserNotificationSettings
            if (notificationSettings!.types == UIUserNotificationType())
            {
                if(self.mapView.userLocation.location == nil)
                {
                    let alertController = UIAlertController(title: "Uh-oh", message: "Looks like we cannot get your location right now. Please try again later", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)

                    return;
                }
                
                let hud = MBProgressHUD .showAdded(to: self.view, animated: true)
                hud?.dimBackground = true
            
                let request = MKDirectionsRequest()
                request.transportType = .transit
                
                let startPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake((self.mapView.userLocation.location?.coordinate.latitude)!, (self.mapView.userLocation.location?.coordinate.longitude)!), addressDictionary: nil)
                request.source = MKMapItem(placemark: startPlacemark)
                
                let location = self.mapView.convert(self.mapView.center, toCoordinateFrom: self.view)
                let endPlacemark = MKPlacemark(coordinate: location, addressDictionary: nil)
                request.destination = MKMapItem(placemark: endPlacemark)
                
                let directions = MKDirections(request: request)
                directions.calculateETA { (response, error) -> Void in
                    
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    if (response != nil)
                    {
                        let totalTravelTimeSeconds : Double = (response?.expectedTravelTime)!
                        let totalTravelTimeMinutes : Double = totalTravelTimeSeconds / 60 as Double;
                        let totalTravelTimeHours : Double = totalTravelTimeMinutes / 60 as Double;
                        
                        let remainderMinutes = Int(floor(totalTravelTimeMinutes.truncatingRemainder(dividingBy: 60)))
                        let remainderHours = Int(floor(totalTravelTimeHours))
                        
                        var travelTime : String?
                        if(remainderHours == 1)
                        {
                            travelTime = "\(remainderHours) Hour"
                        }
                        else if (remainderHours > 1)
                        {
                            travelTime = "\(remainderHours) Hours"
                        }
                        
                        if(remainderMinutes == 1)
                        {
                            if(travelTime != nil)
                            {
                                travelTime?.append("' \(remainderMinutes) Minutes")
                            }
                            else
                            {
                                travelTime = ("\(remainderMinutes) Minute")
                            }
                            
                        }
                        else if (remainderMinutes > 1)
                        {
                            if(travelTime != nil)
                            {
                                travelTime?.append("' \(remainderMinutes) Minutes")
                            }
                            else
                            {
                                travelTime = ("\(remainderMinutes) Minutes")
                            }
                        }
                        
                        if (travelTime == nil)
                        {
                            travelTime = "a few seconds"
                        }
                        
                        let alertController = UIAlertController(title: "Arrival Time", message: "Looks like you can reach this destination in \(travelTime!)\nDont forget to set your alarm!", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)

                    }
                    else
                    {
                        let alertController = UIAlertController(title: "Uh-oh", message: "Looks like we cannot get an estimated arrival time right now.\nThere may not be travel information available for this region", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }

            }
            else
            {
                SCUserDefaultsManager().isCatchingStop = true
                
                SCUserDefaultsManager().trackingLocation = self.mapView.convert(self.mapView.center, toCoordinateFrom: self.view)
                
                self.addLocationNotificationAtCurrentPoint()
                self.updateUI()
            }
            
        }
        //***** Ask for push notes
        else
        {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            SCUserDefaultsManager().hasAskedForPushNotes = true
        }
    }
    
    func didTapConfirmStopCatchingStopButton()
    {
        self.removeAllLocalNotifications()
        SCUserDefaultsManager().isCatchingStop = false
        SCUserDefaultsManager().trackingLocation = nil
        UIApplication.shared.cancelAllLocalNotifications()
        self.updateUI()
    }
    
    func didTapOverlayButton()
    {
        //***** If we have not asked for permission we request permission
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined)
        {
            locationManager.requestAlwaysAuthorization()
        }
            //***** If we have asked before we simply point the user to the settings
        else
        {
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(settingsUrl!)
        }
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
        let localNotification = UILocalNotification()
        
        let regionToDetect = CLCircularRegion(center: self.mapView.centerCoordinate, radius: maxRadius, identifier: "Location Tracking")
        
        localNotification.regionTriggersOnce = true
        localNotification.region = regionToDetect
        localNotification.alertBody = "Looks like you are near your stop!"
        localNotification.alertTitle = "Get ready!"
        
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
        let timedNotification = UILocalNotification()
        timedNotification.fireDate = Date(timeIntervalSinceNow: self.timePicker.countDownDuration)
        timedNotification.alertBody = "Check you haven't missed your stop!"
        timedNotification.alertTitle = "Time to check!"
        
        UIApplication.shared.scheduleLocalNotification(timedNotification)
    }
    
    func removeAllLocalNotifications()
    {
        UIApplication.shared.cancelAllLocalNotifications()
    }

    //MARK: MapView Methods
    
    func handleMyLocationButtonTapped()
    {
        let userLocation = self.mapView.userLocation
        let coords = userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(coords, maxRadius*2.0, maxRadius*2.0)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        if(SCUserDefaultsManager().isCatchingStop == false)
        {
            self.updateRadiusCircle()
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0)
        circle.fillColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0).withAlphaComponent(0.3)
        circle.lineWidth = 1
        return circle
    }

    //***** Remove all annotations and only leave the user location annotation if it is present
    func removeAllAnnotations()
    {
        self.mapView.removeAnnotations(mapView.annotations)
    }
    
    func updateRadiusCircle()
    {
        if(SCUserDefaultsManager().isCatchingStop == true)
        {
            self.mapView.removeOverlays(self.mapView.overlays)
            let circleView = MKCircle(center: SCUserDefaultsManager().trackingLocation!, radius: maxRadius)
            self.mapView.add(circleView)
        }
        else
        {
            self.mapView.removeOverlays(self.mapView.overlays)
            let circleView = MKCircle(center: self.mapView.convert(self.mapView.center, toCoordinateFrom: self.view), radius: maxRadius)
            self.mapView.add(circleView)
        }
    }
    
    //MARK: Selecting Countdown Time
    
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
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            self.stopWatchWidthConstrant.constant = newButtonWidth
            self.stopWatchHeightConstraint.constant = newButtonHeight
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            }, completion: { (finished) -> Void in
                
                self.stopWatchButtonIsLarge = !self.stopWatchButtonIsLarge
        }) 
        
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            
            self.stopWatchButton.alpha = 0;
            
            }, completion: { (finished) -> Void in
                
                self.stopWatchButton.setImage(image, for: UIControlState())
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    self.stopWatchButton.alpha = 1
                })
                
        }) 
    }
    
    @IBAction func handleTimePickerValueChanged(_ sender: AnyObject)
    {
        self.hasPickedTime = true
    }
    
}
