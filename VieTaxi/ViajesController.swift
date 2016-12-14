//
//  ViajesController.swift
//  VieTaxi
//
//  Created by usuario on 16/10/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import MapKit
import GoogleMaps
import GooglePlaces

class ViajesController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate,GMSMapViewDelegate {
    
    @IBOutlet weak var MapView: UIView!
    
    @IBOutlet weak var Ubication: FormTextField!
    @IBOutlet weak var Direction: AutoCompleteTextField!
    private var responseData:NSMutableData?
    private var selectedPointAnnotation:MKPointAnnotation?
    private var dataTask:URLSessionDataTask?
    
    private let googleMapsKey = "AIzaSyDg2tlPcoqxx2Q2rfjhsAKS-9j0n3JA_a4"
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
        MarkerStatic.image = GMSMarker.markerImage(with: UIColor(red: 199/255, green: 150/255, blue: 19/255, alpha: 1))
        initLocationManager()
        
        Ubication.layer.shadowColor = UIColor.black.cgColor
        Ubication.layer.shadowOpacity = 0.6
        Ubication.layer.shadowRadius = 6
        Ubication.layer.shadowOffset = CGSize(width: 0.0, height: 9)
        Ubication.layer.masksToBounds = false
        
        Direction.layer.shadowColor = UIColor.black.cgColor
        Direction.layer.shadowOpacity = 0.6
        Direction.layer.shadowRadius = 6
        Direction.layer.shadowOffset = CGSize(width: 0.0, height: 9)
        Direction.layer.masksToBounds = false
        
        configureTextField()
        handleTextFieldInterfaces()
        
    }
    
    func configureTextField(){
        Direction.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        Direction.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        Direction.autoCompleteCellHeight = 35.0
        Direction.maximumAutoCompleteCount = 20
        Direction.hidesWhenSelected = true
        Direction.hidesWhenEmpty = true
        Direction.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        Direction.autoCompleteAttributes = attributes
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
                ViewMap.delegate = self
                locManager.stopUpdatingLocation()
            }
        }
    }
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
        mapView.clear()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(cameraPosition.target) { response , error in
            if let result = response?.firstResult() {
                mapView.clear()
                //self.MarkerStatic.isHidden = true
                let marker = GMSMarker()
                marker.position = cameraPosition.target
                marker.icon = GMSMarker.markerImage(with: UIColor(red: 199/255, green: 150/255, blue: 19/255, alpha: 1))
                //marker.icon =
                marker.title = "Pedir aqui"
                marker.snippet = "7 min"
                self.Ubication.text = (result.lines?[0])!+", "+(result.lines?[1])!
                marker.map = mapView
                //marker.appearAnimation = kGMSMarkerAnimationPop
                marker.opacity = 0
                marker.isFlat = true
                mapView.selectedMarker=marker
                
            }
        }
    }
    
    private func handleTextFieldInterfaces(){
        Direction.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                //self?.fetchAutocompletePlaces(keyword: text)
                self?.placeAutocomplete(Text: text)
            }
        }
    }
    
    func placeAutocomplete(Text:String) {
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.address
        placesClient?.autocompleteQuery(Text, bounds: nil, filter: filter, callback:
            { (results, error: Error?) -> Void in
            var locations = [String]()
            for result in results! {
                if let result = result as? GMSAutocompletePrediction {
                    //result.
                    locations.append(result.attributedFullText)
                    print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                }
            }
                DispatchQueue.main.async {
                    self.Direction.autoCompleteStrings = locations
                }
        })
    }
    //MARK: - Private Methods

    private func fetchAutocompletePlaces(keyword:String) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(keyword)"
        let s = CharacterSet.urlQueryAllowed as! CharacterSet
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
                                        for dict in predictions as! [NSDictionary]{
                                            locations.append(dict["description"] as! String)
                                        }
                                        DispatchQueue.main.async {
                                            self.Direction.autoCompleteStrings = locations
                                        }
                                        return
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                self.Direction.autoCompleteStrings = nil
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
    
    //MARK: Metodos del text Field delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= LoginController.MAX_TEXT_SIZE
}

}

