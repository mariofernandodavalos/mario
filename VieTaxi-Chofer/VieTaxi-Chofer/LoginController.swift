//
//  ViewController.swift
//  VieTaxi-Chofer
//
//  Created by usuario on 15/12/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import UIKit
import QuartzCore

import Alamofire

class LoginController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var UserLabel: UITextField!
    
    @IBOutlet weak var PassLabel: UITextField!
    
    @IBOutlet weak var Ingresar: UIButton!
    
    @IBOutlet weak var DataLogin: UIStackView!
    
    @IBOutlet weak var Logo: UIImageView!
    
    @IBOutlet weak var VieTaxi: UIImageView!
    
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
    //MARK: Overrides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with: event)
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.UserInfoLoad()
    }
    //MARK:Login
    @IBAction func LoginFunction(_ sender: UIButton) {
        let User:String = UserLabel.text!
        let Pass:String = PassLabel.text!
        let parameters: Parameters = [
            "modo": 0,
            "app": 2,
            "email":User,
            "password":Pass
        ]
        LoginFunc(parameters: parameters)
    }
    func LoginFunc(parameters: Parameters){
        Alamofire.request("http://api.vietaxi.com/usuario/login/", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)")
                    do{
                        let result = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                        if let token = result["token"] as? String{
                            UserDefaults.standard.setValue(token, forKey: "token")
                            self.UserInfoLoad()
                        self.present(AppDelegate.TableBarInit!, animated: true, completion: nil)
                        }
                    }
                    catch let error as NSError{
                        print("Error: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print(error)
                do{
                    let result = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                    if let mensaje = result["mensaje"] as? String{
                        print(mensaje)
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error de acceso", message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                catch let error as NSError{
                    print("Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error de servidor", message: "Error 500 comuniquese con el administrador", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    func UserInfoLoad(){
        if let tok = UserDefaults.standard.string(forKey: "token")
        {
            print(tok)
            Alamofire.request("http://api.vietaxi.com/chofer/?token="+tok).validate().responseJSON { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        do{
                            let result = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                            if let nombre = result["nombre"] as? String{UserDefaults.standard.setValue(nombre, forKey: "nombre")}
                            if let apellidos = result["apellidos"] as? String{UserDefaults.standard.setValue(apellidos, forKey: "apellidos")}
                            if let telefono = result["telefono"] as? String{UserDefaults.standard.setValue(telefono, forKey: "telefono")}
                            if let email = result["email"] as? String{UserDefaults.standard.setValue(email, forKey: "email")}
                            if let rfc = result["rfc"] as? String{UserDefaults.standard.setValue(rfc, forKey: "rfc")}
                            if let calificacion = result["calificacion"] as? String{UserDefaults.standard.setValue(calificacion, forKey: "calificacion")}
                            if let domicilio = result["domicilio"] as? String{UserDefaults.standard.setValue(domicilio, forKey: "domicilio")}
                            if let licencia = result["licencia"] as? String{UserDefaults.standard.setValue(licencia, forKey: "licencia")}
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    //MARK: TextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= LoginController.MAX_TEXT_SIZE
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.UserLabel {
            self.PassLabel.becomeFirstResponder()
        }
        else if textField == self.PassLabel {
            self.PassLabel.resignFirstResponder()
            let User:String = UserLabel.text!
            let Pass:String = PassLabel.text!
            let parameters: Parameters = [
                "modo": 0,
                "app": 2,
                "email":User,
                "password":Pass
            ]
            LoginFunc(parameters: parameters)
        }
        return true
    }
    func Focus(_ sender: UITextField) {
        self.Logo.isHidden = false
        self.VieTaxi.isHidden = true
    }
    
    func NoFocus(_ sender: UITextField) {
        self.Logo.isHidden = true
        self.VieTaxi.isHidden = false
    }
    
}

