//
//  ViajesController.swift
//  VieTaxi-Chofer
//
//  Created by usuario on 15/12/16.
//  Copyright © 2016 vietaxi. All rights reserved.

import UIKit
import QuartzCore
import CoreLocation
import MapKit
import GoogleMaps
import GooglePlaces

class ViajesController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate,GMSMapViewDelegate {
    
    @IBOutlet weak var MapView: UIView!
    
    @IBOutlet weak var ShadowLabel: UILabel!
    @IBOutlet weak var ButtonRequest: UIButton!
    
    @IBOutlet weak var CardDriver: UIStackView!
    @IBOutlet weak var CardShadow: UILabel!
    
    @IBOutlet weak var PhoneLabel: UILabel!
    
    private var responseData:NSMutableData?
    private var selectedPointAnnotation:MKPointAnnotation?
    private var dataTask:URLSessionDataTask?
    //AIzaSyDg2tlPcoqxx2Q2rfjhsAKS-9j0n3JA_a4
    private let googleMapsKey = "AIzaSyBjReNZ9xANHA3b4nulrfIua4z2pbl1VXw"
    
    private let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    @IBOutlet var ViewMap: GMSMapView!
    
    var placesClient: GMSPlacesClient?
    
    @IBOutlet weak var MarkerStatic: UIImageView!
    
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    static let MAX_TEXT_SIZE = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        markerTaxi.icon = #imageLiteral(resourceName: "TaxiTop")
        initLocationManager()
        
        self.ButtonRequest.layer.cornerRadius = 22.0
        ButtonRequest.layer.shadowColor = UIColor.black.cgColor
        ButtonRequest.layer.shadowOpacity = 0.4
        ButtonRequest.layer.shadowRadius = 4
        ButtonRequest.layer.shadowOffset = CGSize(width: 0.0, height: 6)
        ButtonRequest.layer.masksToBounds = false
        
        
    }
    @IBAction func RequesTrip(_ sender: UIButton) {
        ButtonRequest.setTitle("VieTaxi Fuera", for: .normal)
        ButtonRequest.backgroundColor = UIColor(red: 186/255, green: 56/255, blue: 48/255, alpha: 1)
        //CardDriver.isHidden = false
        //CardShadow.isHidden = false
        ViewMap.settings.myLocationButton = false
        //ButtonRequest.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15), execute: {
            self.CardDriver.isHidden = true
            self.CardShadow.isHidden = true
            //self.ButtonRequest.isHidden = false
            self.ViewMap.settings.myLocationButton = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                self.ButtonRequest.backgroundColor = UIColor(red: 153/255, green: 186/255, blue: 65/255, alpha: 1)
                self.ButtonRequest.setTitle("VieTaxi Libre", for: .normal)
            })
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func initLocationManager() {
        seenError = false
        locationFixAchieved = false
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingHeading()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locManager.stopUpdatingLocation()
        if ((error) != nil) {
            if (seenError == false) {
                seenError = true
                print(error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            let locationArray = locations as NSArray
            let locationObj = locationArray.lastObject as! CLLocation
            let coord = locationObj.coordinate
            
            print(coord.latitude)
            print(coord.longitude)
            self.currentLocation = self.locManager.location
            if(self.currentLocation != nil){
                print(self.currentLocation.coordinate.latitude)
                print(self.currentLocation.coordinate.longitude)
                
                let camera = GMSCameraPosition.camera(withLatitude: self.currentLocation.coordinate.latitude,
                                                      longitude: self.currentLocation.coordinate.longitude, zoom: 18)
                ViewMap.camera = camera
                ViewMap.isMyLocationEnabled = true
                ViewMap.settings.myLocationButton = true
                ViewMap.mapType = kGMSTypeTerrain
                if let mylocation = ViewMap.myLocation {
                    print("User's location: \(mylocation)")
                } else {
                    print("User's location is unknown")
                }
                markerTaxi.position = (locations.last?.coordinate)!
                //markerTaxi.icon = #imageLiteral(resourceName: "TaxiTop")
                markerTaxi.map = self.ViewMap
                markerTaxi.opacity = 0.9
                ViewMap.delegate = self
                //locManager.stopUpdatingLocation()
            }
        }
        if let mylocation = ViewMap.myLocation {
            print("Curso: \(mylocation.course)")
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print(newHeading.magneticHeading)
        //let image = CIImage(image: #imageLiteral(resourceName: "TaxiTop"))
        DispatchQueue.main.async {
        self.markerTaxi.icon = #imageLiteral(resourceName: "TaxiTop")
            
        let degrees : CLLocationDegrees = (newHeading.magneticHeading)+90
        self.markerTaxi.rotation = degrees
        self.markerTaxi.map = self.ViewMap
        self.markerTaxi.opacity = 0.9
     }
    }
    var markerTaxi = GMSMarker()
    var oldHeading = Int(10)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LabelHasbeenUpdated"), object: nil)
        if (shouldIAllow == true) {
            print("Location to Allowed")
            // Start location services
            locManager.startUpdatingLocation()
        } else {
            print("Denied access: \(locationStatus)")
        }
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if(!self.MarkerStatic.isHidden){
            mapView.clear()
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(cameraPosition.target) { response , error in
            if let result = response?.firstResult() {
                
                self.markerTaxi.title = result.lines?[0]
                self.markerTaxi.snippet = result.lines?[1]
                //mapView.selectedMarker=self.markerTaxi
                
            }
        }
    }
  
    
    
    //MARK: - Private Methods

    private func fetchAutocompletePlaces(keyword:String, AutoTextField:AutoCompleteTextField) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&location=\(self.currentLocation.coordinate.latitude),\(self.currentLocation.coordinate.longitude)&radius=7000&input=\(keyword)"
        let s = CharacterSet.urlQueryAllowed 
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = NSURL(string: encodedString) {
                let request = NSURLRequest(url: url as URL)
                dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                            
                            if let status = result["status"] as? String{
                                if status == "OK"{
                                    if let predictions = result["predictions"] as? NSArray{
                                        var locations = [String]()
                                        var placesids = [String]()
                                        for dict in predictions as! [NSDictionary]{
                                            placesids.append(dict["place_id"] as! String)
                                            locations.append(dict["description"] as! String)
                                        }
                                        DispatchQueue.main.async {
                                            AutoTextField.autoCompleteStrings = locations
                                            AutoTextField.autoCompletePlaceId = placesids
                                        }
                                        return
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                AutoTextField.autoCompleteStrings = nil
                                AutoTextField.autoCompletePlaceId = nil
                            }
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with: event)
        self.view.endEditing(true)
       // callWebService()
    }
    
    func callWebService(){
        
        let origin = "place_id:"
        let destination = "place_id:"
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode: driving&key=\(googleMapsKey)"
        let s = CharacterSet.urlQueryAllowed 
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = NSURL(string: encodedString) {
        let request = NSURLRequest(url: url as URL)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            
            // notice that I can omit the types of data, response and error
            do{
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    
                    //print(jsonResult)
                    //let routes = jsonResult.value(forKey: "routes")  as! [String:Any]
                    if let routesInfo = jsonResult.value(forKey: "routes") as? [[String:AnyObject]] {
                        for routes in routesInfo {
                            if let legs = routes["legs"] as? [[String:AnyObject]]{
                                DispatchQueue.main.async {
                                    if let start_location = legs[0]["start_location"] as? [String:AnyObject] {
                                    if let end_location = legs[0]["end_location"] as? [String:AnyObject] {
                                        if let endlat = end_location["lat"] as? Double {
                                        if let endlng = end_location["lng"] as? Double {
                                        if let strlat = start_location["lat"] as? Double {
                                        if let strlng = start_location["lng"] as? Double {
                                             let StartLocation = CLLocationCoordinate2DMake(strlat,strlng)
                                             let EndLocation = CLLocationCoordinate2DMake(endlat,endlng)
                                            let marker = GMSMarker()
                                            marker.position = StartLocation
                                            marker.icon = GMSMarker.markerImage(with: UIColor(red: 199/255, green: 150/255, blue: 19/255, alpha: 1))
                                            marker.map = self.ViewMap
                                            marker.appearAnimation = kGMSMarkerAnimationPop
                                            marker.opacity = 0.8
                                            marker.isFlat = true
                                            
                                            let marker2 = GMSMarker()
                                            marker2.position = EndLocation
                                            marker2.icon = GMSMarker.markerImage(with: UIColor(red: 199/255, green: 150/255, blue: 19/255, alpha: 1))
                                            marker2.title = "Destino"
                                            marker2.snippet = "7 min"
                                            marker2.map = self.ViewMap
                                            marker2.appearAnimation = kGMSMarkerAnimationPop
                                            marker2.opacity = 0.8
                                            marker2.isFlat = true
                                            self.ViewMap.selectedMarker=marker2
                                            }}}}
                                    }}
                            }}
                            DispatchQueue.main.async {
                            if let bounds = routes["bounds"] as? [String:AnyObject]{
                                if let northeast = bounds["northeast"] as? [String:AnyObject] {
                                if let southwest = bounds["southwest"] as? [String:AnyObject] {
                                    if let endlat = northeast["lat"] as? Double {
                                    if let endlng = northeast["lng"] as? Double {
                                    if let strlat = southwest["lat"] as? Double {
                                    if let strlng = southwest["lng"] as? Double {
                                        let southWest = CLLocationCoordinate2DMake(strlat,strlng)
                                        let northEast = CLLocationCoordinate2DMake(endlat,endlng)
                                        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                                            self.ViewMap.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 150.0))
                                        
                                                    }}}}
                                    }}
                            }}
                            DispatchQueue.main.async {
                            if let overview = routes["overview_polyline"] as? [String:AnyObject] {
                                if let point = overview["points"] as? String {
                                    let path = GMSPath(fromEncodedPath: point)
                                    let polyline = GMSPolyline(path: path)
                                    polyline.strokeColor = UIColor(red: 199/255, green: 150/255, blue: 19/255, alpha: 1)
                                    polyline.strokeWidth = 6.0
                                    polyline.map = self.ViewMap
                                }
                            }}
                        }
                        
                    }
                }
            }
            catch{
                
                print("Somthing wrong")
            }
        });
        
        // do whatever you need with the task e.g. run
        task.resume()
            }
        }
    }

    @IBAction func DrawlinPolilyne(_ sender: AutoCompleteTextField) {
        //self.MarkerStatic.isHidden = false
        ViewMap.clear()
        callWebService()
    }
    //MARK: Metodos del text Field delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= LoginController.MAX_TEXT_SIZE
}
    
    @IBAction func CallPhone(_ sender: UIButton) {
        Caller.call(tel: "3331083140")
        //HidePhone.isHidden = !HidePhone.isHidden
        PhoneLabel.isHidden = !PhoneLabel.isHidden
    }

}

