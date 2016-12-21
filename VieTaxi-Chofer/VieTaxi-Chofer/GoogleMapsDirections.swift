//
//  GoogleMapsDirections.swift
//  VieTaxi-Chofer
//
//  Created by usuario on 15/12/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//
/*
import Foundation
import UIKit
import GoogleMaps

class MapTasks: NSObject {
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    
    var totalDistanceInMeters: UInt = 0
    
    var totalDistance: String!
    
    var totalDurationInSeconds: UInt = 0
    
    var totalDuration: String!
    
    
    override init() {
        super.init()
    }
    
    
    func geocodeAddress(address: String!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        if let lookupAddress = address {
            var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
            geocodeURLString = geocodeURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) as String
            
            let geocodeURL = NSURL(string: geocodeURLString)
            
            DispatchQueue.main.async {
                let geocodingResultsData = NSData(contentsOf: geocodeURL! as URL)
                
                var error: NSError?
                let dictionary: Dictionary<NSObject, AnyObject> = JSONSerialization.jsonObject(with: geocodingResultsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<NSObject, AnyObject>
                
                if (error != nil) {
                    print(error)
                    completionHandler("", false)
                }
                else {
                    // Get the response status.
                    let status = dictionary["status"] as String
                    
                    if status == "OK" {
                        let allResults = dictionary["results"] as Array<Dictionary<NSObject, AnyObject>>
                        self.lookupAddressResults = allResults[0]
                        
                        // Keep the most important values.
                        self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as String
                        let geometry = self.lookupAddressResults["geometry"] as Dictionary<NSObject, AnyObject>
                        self.fetchedAddressLongitude = ((geometry["location"] as Dictionary<NSObject, AnyObject>)["lng"] as NSNumber).doubleValue
                        self.fetchedAddressLatitude = ((geometry["location"] as Dictionary<NSObject, AnyObject>)["lat"] as NSNumber).doubleValue
                        
                        completionHandler(status: status, success: true)
                    }
                    else {
                        completionHandler(status: status, success: false)
                    }
                }
            })
        }
        else {
            completionHandler("No valid address.", false)
        }
    }
    
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: TravelModes!, completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                
                if let travel = travelMode {
                    var travelModeString = ""
                    
                    switch travelMode.rawValue {
                    case travelMode.walking.rawValue:
                        travelModeString = "walking"
                        
                    case travelMode.bicycling.rawValue:
                        travelModeString = "bicycling"
                        
                    default:
                        travelModeString = "driving"
                    }
                    
                    
                    directionsURLString += "&mode=" + travelModeString
                }
                
                
                directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                let directionsURL = NSURL(string: directionsURLString)
                
                DispatchQueue.main.asynchronously(execute: { () -> Void in
                    let directionsData = NSData(contentsOf: directionsURL! as URL)
                    
                    var error: NSError?
                    let dictionary: Dictionary<NSObject, AnyObject> = JSONSerialization.JSONObjectWithData(directionsData!, options: JSONSerialization.ReadingOptions.MutableContainers, error: &error) as Dictionary<NSObject, AnyObject>
                    
                    if (error != nil) {
                        print(error)
                        completionHandler("", false)
                    }
                    else {
                        let status = dictionary["status"] as String
                        
                        if status == "OK" {
                            self.selectedRoute = (dictionary["routes"] as Array<Dictionary<NSObject, AnyObject>>)[0]
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as Dictionary<NSObject, AnyObject>
                            
                            let legs = self.selectedRoute["legs"] as Array<Dictionary<NSObject, AnyObject>>
                            
                            let startLocationDictionary = legs[0]["start_location"] as Dictionary<NSObject, AnyObject>
                            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as Double, startLocationDictionary["lng"] as Double)
                            
                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as Dictionary<NSObject, AnyObject>
                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as Double, endLocationDictionary["lng"] as Double)
                            
                            self.originAddress = legs[0]["start_address"] as String
                            self.destinationAddress = legs[legs.count - 1]["end_address"] as String
                            
                            self.calculateTotalDistanceAndDuration()
                            
                            completionHandler(status: status, success: true)
                        }
                        else {
                            completionHandler(status: status, success: false)
                        }
                    }
                })
            }
            else {
                completionHandler("Destination is nil.", false)
            }
        }
        else {
            completionHandler("Origin is nil", false)
        }
    }
    
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as Dictionary<NSObject, AnyObject>!
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as Dictionary<NSObject, AnyObject>)["value"] as UInt
            totalDurationInSeconds += (leg["duration"] as Dictionary<NSObject, AnyObject>)["value"] as UInt
        }
        
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }
    
    
}
 */
