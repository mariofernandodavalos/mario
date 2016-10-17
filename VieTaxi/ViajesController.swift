//
//  ViajesController.swift
//  VieTaxi
//
//  Created by usuario on 16/10/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import UIKit
import QuartzCore
import MapKit

class ViajesController: UIViewController, UITextFieldDelegate,UISearchBarDelegate {
    
    
    @IBOutlet weak var Mapa: MKMapView!
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    static let MAX_TEXT_SIZE = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //3
        self.pointAnnotation = MKPointAnnotation()
        self.pointAnnotation.title = "Ubicacion"
        self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: 20.692747, longitude: -103.338384)
        
        
        self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
        self.Mapa.centerCoordinate = self.pointAnnotation.coordinate
        self.Mapa.addAnnotation(self.pinAnnotationView.annotation!)
        
        // Init the zoom level
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 20.692747, longitude: -103.338384)
        let span = MKCoordinateSpanMake(0.1, 0.08)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.Mapa.setRegion(region, animated: true)
        
    }
    
    @IBAction func showSearchBar(_ sender: UIButton) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Metodos del text Field delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= ViewController.MAX_TEXT_SIZE
}
    //MARK: Metodos del SearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.Mapa.annotations.count != 0{
            annotation = self.Mapa.annotations[0]
            self.Mapa.removeAnnotation(annotation)
        }
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.Mapa.centerCoordinate = self.pointAnnotation.coordinate
            self.Mapa.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
}
