//
//  PhoneController.swift
//  VieTaxi-Chofer
//
//  Created by usuario on 29/12/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore



class PhoneController : UIViewController{
    
     @IBOutlet weak var Active: UIButton!
    
     @IBOutlet weak var Cancel: UIButton!
    
    @IBOutlet weak var WindowWhite: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Active.layer.cornerRadius = 20.0
        self.Cancel.layer.cornerRadius = 20.0
        self.WindowWhite.layer.cornerRadius = 20.0
    }
    
    @IBAction func ActiveFunction(_ sender: UIButton) {
        
    }
    @IBAction func CancelFunction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
