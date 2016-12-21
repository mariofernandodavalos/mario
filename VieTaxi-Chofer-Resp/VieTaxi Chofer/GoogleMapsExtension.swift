//
//  GoogleMapsExtension.swift
//  VieTaxi
//
//  Created by usuario on 12/12/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//
/*
import Foundation
import GoogleMaps
import UIKit

extension ViajesController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapView.clear()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        let handler = { (response : GMSReverseGeocodeResponse!, error: NSError!) -> Void in
            if let result = response.firstResult() {
                let marker = GMSMarker()
                marker.position = cameraPosition.target
                marker.title = result.lines?[0]
                marker.snippet = result.lines?[1]
                marker.map = mapView
            }
        }
        GMSGeocoder().reverseGeocodeCoordinate(cameraPosition.target, completionHandler: handler as! GMSReverseGeocodeCallback)
    }
}*/
