//
//  RegisterController.swift
//  VieTaxi
//
//  Created by usuario on 15/10/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import Foundation
import UIKit
class RegisterController: UIViewController, UITextFieldDelegate {
    
    static let MAX_TEXT_SIZE = 30
    
    @IBOutlet weak var Nombre: UITextField!
    @IBOutlet weak var Apellido: UITextField!
    @IBOutlet weak var Telefono: UITextField!
    @IBOutlet weak var Correo: UITextField!
    @IBOutlet weak var RFC: UITextField!
    @IBOutlet weak var Contraseña: UITextField!
    @IBOutlet weak var Cocontraseña: UITextField!
    
    @IBOutlet weak var Registrar: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Nombre.layer.cornerRadius = 15.0
        self.Apellido.layer.cornerRadius = 15.0
        self.Telefono.layer.cornerRadius = 15.0
        self.Correo.layer.cornerRadius = 15.0
        self.RFC.layer.cornerRadius = 15.0
        self.Contraseña.layer.cornerRadius = 15.0
        self.Cocontraseña.layer.cornerRadius = 15.0
        self.Registrar.layer.cornerRadius = 15.0
        

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
    
    
}
