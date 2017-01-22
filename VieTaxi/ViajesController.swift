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
import SocketIO

class ViajesController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate,GMSMapViewDelegate {
    
    let socket = SocketIOClient(socketURL: URL(string: "http://apirt.vietaxi.com")!, config: [.log(true), .forcePolling(true)])
    
    @IBOutlet weak var MapView: UIView!
    
    @IBOutlet weak var ShadowLabel: UILabel!
    @IBOutlet weak var ButtonRequest: UIButton!
    
    @IBOutlet weak var Ubication: AutoCompleteTextField!
    @IBOutlet weak var Direction: AutoCompleteTextField!
    private var responseData:NSMutableData?
    private var selectedPointAnnotation:MKPointAnnotation?
    private var dataTask:URLSessionDataTask?
    //AIzaSyDg2tlPcoqxx2Q2rfjhsAKS-9j0n3JA_a4
    private let googleMapsKey = "AIzaSyB-EV-MfJwe7_q-dl4vFY8wHrH7Z-17ziI"
    
    private let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    @IBOutlet var ViewMap: GMSMapView!
    
    var placesClient: GMSPlacesClient?
    
    @IBOutlet weak var MarkerStatic: UIImageView!
    @IBOutlet weak var HidePhone: UIStackView!
    @IBOutlet weak var PhoneLabel: UILabel!
    
    @IBOutlet weak var CardDriver: UIStackView!
    @IBOutlet weak var CardShadow: UILabel!
    
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
        SocketIOConnect()
        
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
        
        CardShadow.layer.shadowColor = UIColor.black.cgColor
        CardShadow.layer.shadowOpacity = 0.6
        CardShadow.layer.shadowRadius = 6
        CardShadow.layer.shadowOffset = CGSize(width: 0.0, height: 9)
        CardShadow.layer.masksToBounds = false
        
        self.ButtonRequest.layer.cornerRadius = 22.0
        ButtonRequest.layer.shadowColor = UIColor.black.cgColor
        ButtonRequest.layer.shadowOpacity = 0.4
        ButtonRequest.layer.shadowRadius = 4
        ButtonRequest.layer.shadowOffset = CGSize(width: 0.0, height: 6)
        ButtonRequest.layer.masksToBounds = false
        
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
        
        
        Ubication.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        Ubication.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        Ubication.autoCompleteCellHeight = 35.0
        Ubication.maximumAutoCompleteCount = 20
        Ubication.hidesWhenSelected = true
        Ubication.hidesWhenEmpty = true
        Ubication.enableAttributedText = true
        Ubication.autoCompleteAttributes = attributes
    }
    
    @IBAction func RequesTrip(_ sender: Any) {
        ButtonRequest.setTitle("Cancelar", for: .normal)
        CardDriver.isHidden = false
        CardShadow.isHidden = false
        ViewMap.settings.myLocationButton = false
        
        var token = "qnPu3sorsj"
        if let tok = UserDefaults.standard.string(forKey: "token")
        {
            token = tok
        }
        let JSONtoken = [
            "token":token/*,
            "origen":[
                "lat": 20.718961,
                "lng": -103.320940
            ],
            "destino":[
                "lat":21.718961,
                "lng":-104.320940
            ]*/
        ]
        
        let JSONsolicitar = [
            "token":token,
             "origen":[
             "lat": 20.718961,
             "lng": -103.320940
             ],
             "destino":[
             "lat":21.718961,
             "lng":-104.320940
             ]
        ] as [String : Any]
        
        let JSONInicio = [
            "origen":[
                "lat":21.718961,
                "lng":-104.320940
            ]
        ] as [String : Any]
        let JSONDestino = [
            "destino":[
                "lat": 20.718961,
                "lng": -103.320940
            ]
            ] as [String : Any]
        
       self.socket.emit("solicitar", JSONsolicitar)
        
        self.socket.emit("solicitar", token, JSONInicio, JSONDestino)
        
        self.socket.emit("registro", token)
        
        self.socket.emit("registro", JSONtoken)
        
        self.socket.emitWithAck("registro", token).timingOut(after: 0) {data in
            print("\(data)")
        }
        self.socket.emitWithAck("registro", JSONtoken).timingOut(after: 0) {data in
            print("\(data)")
        }
        
        self.socket.engineDidOpen(reason: "")
        /*
        socket.connect()
        
        
        self.socket.on("cliente") {data, ack in
            print("\(data)")
            self.socket.emit("token", token)
        }
        self.socket.emitWithAck("cliente", ["token":token]).timingOut(after: 0, callback: {data in
            print(data)
        })
        */
        
        
        //ButtonRequest.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15), execute: {
            self.CardDriver.isHidden = true
            self.CardShadow.isHidden = true
            //self.ButtonRequest.isHidden = false
            self.ViewMap.settings.myLocationButton = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                self.ButtonRequest.setTitle("Pedir Vietaxi", for: .normal)
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
                ViewMap.delegate = self
                //locManager.stopUpdatingLocation()
            }
        }
        if let mylocation = ViewMap.myLocation {
            print("Curso: \(mylocation.course)")
        }
        markerTaxi.position = (locations.last?.coordinate)!
        //markerTaxi.icon = #imageLiteral(resourceName: "TaxiTop")
        //markerTaxi.map = self.ViewMap
        markerTaxi.opacity = 0.9
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print(newHeading.magneticHeading)
        //let image = CIImage(image: #imageLiteral(resourceName: "TaxiTop"))
        DispatchQueue.main.async {
        self.markerTaxi.icon = #imageLiteral(resourceName: "TaxiTop")
            
        let degrees : CLLocationDegrees = (newHeading.magneticHeading)+90
        self.markerTaxi.rotation = degrees
        //self.markerTaxi.map = self.ViewMap
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
                if(!self.MarkerStatic.isHidden){
                    mapView.clear()
                }
                //self.MarkerStatic.isHidden = true
                if((self.Direction.text?.characters.count)!>0){
                    if(!self.MarkerStatic.isHidden){
                        self.callWebService()}
                    self.MarkerStatic.isHidden = true
                }
                else{
                self.MarkerStatic.isHidden = false
                let marker = GMSMarker()
                marker.position = cameraPosition.target
                marker.icon = GMSMarker.markerImage(with: UIColor(red: 199/255, green: 150/255, blue: 19/255, alpha: 1))
                self.Ubication.text = (result.lines?[0])!+", "+(result.lines?[1])!
                self.Ubication.accessibilityLabel = nil
                marker.map = mapView
                //marker.appearAnimation = kGMSMarkerAnimationPop
                marker.opacity = 0
                marker.isFlat = true
                //mapView.selectedMarker=marker
                }
                
            }
        }
    }
    
    private func handleTextFieldInterfaces(){
        Direction.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(keyword: text, AutoTextField: (self?.Direction)!)
                //self?.placeAutocomplete(Text: text)
            }
        }
        Ubication.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(keyword: text, AutoTextField: (self?.Ubication)!)
                //self?.placeAutocomplete(Text: text)
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
                    let str = result.attributedFullText.string
                    locations.append(str)
                    print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                }
            }
                DispatchQueue.main.async {
                    self.Direction.autoCompleteStrings = locations
                }
        })
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
        
        let origin = (Ubication.accessibilityLabel == nil) ? Ubication.text! : "place_id:"+Ubication.accessibilityLabel!
        let destination = (Direction.accessibilityLabel == nil) ? Direction.text! : "place_id:"+Direction.accessibilityLabel!
        //let timeInterval = NSDate().timeIntervalSince1970 + 100
        //https://maps.googleapis.com/maps/api/directions/json?origin=place_id:ChIJNdv8Pb9ZwokR1SHlRAL0Itw&destination=place_id:ChIJucvgmhyyKIQRwicg7tq8-Gg&departure_time=1541202457&mode=driving&key=AIzaSyB-EV-MfJwe7_q-dl4vFY8wHrH7Z-17ziI
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&departure_time=now&mode=driving&key=\(googleMapsKey)"
        
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
                                            var durationwhitrafic:[String:AnyObject]?=nil
                                            if let duration = legs[0]["duration_in_traffic"] as? [String:AnyObject] {
                                                durationwhitrafic=duration
                                            }
                                            else if let duration = legs[0]["duration"] as? [String:AnyObject] {
                                                durationwhitrafic=duration
                                            }
                                            if let distance = legs[0]["distance"] as? [String:AnyObject] {
                                                 if let disval = distance["value"] as? Double {
                                                 if let durtxt = durationwhitrafic?["text"] as? String {
                                                 if let durval = durationwhitrafic?["value"] as? Double {
                                            marker2.title = "Destino " + durtxt
                                                let Estimado = 5.70 + ((disval/1000)*2.6) + ((durval/60)*1.6)
                                                    let min = 0.95*Estimado
                                                    let max = 1.05*Estimado
                                            marker2.snippet = "$\(lround(min)) - $\(lround(max))"
                                                }}}
                                            }
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
                                        if((self.Direction.text?.characters.count)!>0){
                                            self.ViewMap.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 150.0))
                                                  }
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
    
    func addPolyLineWithEncodedStringInMap(encodedString: String) {
        
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 5
        polyLine.strokeColor = UIColor.yellow
        polyLine.map = ViewMap
        
        let smarker = GMSMarker()
        smarker.position = CLLocationCoordinate2D(latitude: 18.5235, longitude: 73.7184)
        smarker.title = "Lavale"
        smarker.snippet = "Maharshtra"
        smarker.map = ViewMap
        
        let dmarker = GMSMarker()
        dmarker.position = CLLocationCoordinate2D(latitude: 18.7603, longitude: 73.8630)
        dmarker.title = "Chakan"
        dmarker.snippet = "Maharshtra"
        dmarker.map = ViewMap
        
        view = ViewMap
        
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
    
    func SocketIOConnect(){
        var token = ""
        if let tok = UserDefaults.standard.string(forKey: "token")
        {
            token = tok
        }
        self.socket.on("connect") {data, ack in
            //print("\(self.socket.sid)")
            self.socket.joinNamespace("/chofer")
            self.socket.emit("registro", token)
        }
        self.socket.on("registro"){data, ack in
            self.SocketIOEvent(dato: data)
        }
        self.socket.on("solicitar"){data, ack in
            print("\(data)")
            self.SocketIOEvent(dato: data)
        }
        self.socket.connect()
    }
    func SocketIOEvent(dato:[Any]){
        do{
            let data = try JSONSerialization.data(withJSONObject: dato, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    print(jsonResult)
                    if let mensaje = jsonResult.value(forKey: "msj") as? [[String:AnyObject]] {
                        print(mensaje)
                    }
            }
        }catch{print("socketData Error")}
    }
}

