//
//  ViewController.swift
//  VieTaxi
//
//  Created by usuario on 06/10/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var UserLabel: UITextField!
    
    @IBOutlet weak var PassLabel: UITextField!
    
    @IBOutlet weak var Ingresar: UIButton!
    
    @IBOutlet weak var DataLogin: UIStackView!
    
    @IBOutlet weak var Logo: UIImageView!
    
    var LogoSave: UIImageView!
    var LogoChan: UIImageView!
    
     static let MAX_TEXT_SIZE = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Ingresar.layer.cornerRadius = 15.0
        self.UserLabel.layer.cornerRadius = 15.0
        self.PassLabel.layer.cornerRadius = 15.0
        LogoSave = Logo
        
        
        
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
    
    @IBAction func Focus(_ sender: UITextField) {
        Logo.isHidden = false
        
    }
    
    @IBAction func NoFocus(_ sender: UITextField) {
        Logo.isHidden = true
    }
    
}

