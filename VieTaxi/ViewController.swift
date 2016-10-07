//
//  ViewController.swift
//  VieTaxi
//
//  Created by usuario on 06/10/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {

    
    @IBOutlet weak var UserLabel: UITextField!
    
    @IBOutlet weak var PassLabel: UITextField!
    
    @IBOutlet weak var Ingresar: UIButton!
    
    @IBOutlet weak var DataLogin: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Ingresar.layer.cornerRadius = 15.0
        self.UserLabel.layer.cornerRadius = 15.0
        self.PassLabel.layer.cornerRadius = 15.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

