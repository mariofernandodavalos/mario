//
//  RegisterController.swift
//  VieTaxi
//
//  Created by usuario on 15/10/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

import Alamofire

import FacebookCore
import FacebookLogin

import Google
import GoogleSignIn
import GGLSignIn

class RegisterController: UIViewController, UITextFieldDelegate, GIDSignInDelegate, GIDSignInUIDelegate {

    
    static let MAX_TEXT_SIZE = 30
    
    @IBOutlet weak var Nombre: UITextField!
    @IBOutlet weak var Apellido: UITextField!
    @IBOutlet weak var Telefono: UITextField!
    @IBOutlet weak var Correo: UITextField!
    @IBOutlet weak var Contraseña: UITextField!
    @IBOutlet weak var Cocontraseña: UITextField!
    @IBOutlet weak var TelefonoRedes: UITextField!
    
    @IBOutlet weak var Registrar: UIButton!
    
    @IBOutlet weak var Facebook: UIButton!
    @IBOutlet weak var Google: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Nombre.layer.cornerRadius = 15.0
        self.Apellido.layer.cornerRadius = 15.0
        self.Telefono.layer.cornerRadius = 15.0
        self.TelefonoRedes.layer.cornerRadius = 15.0
        self.Correo.layer.cornerRadius = 15.0
        self.Contraseña.layer.cornerRadius = 15.0
        self.Cocontraseña.layer.cornerRadius = 15.0
        self.Registrar.layer.cornerRadius = 15.0
        
        Facebook.imageView?.contentMode = .scaleAspectFit
        Google.imageView?.contentMode = .scaleAspectFit
    }
    //MARK: Overrides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with: event)
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK:Register
    @IBAction func RegisterFuncion(_ sender: UIButton) {
        let Name:String = Nombre.text!
        let NamL:String = Apellido.text!
        let Emai:String = Correo.text!
        let Pasw:String = Contraseña.text!
        var Phon:String = Telefono.text!
        if(Phon.characters.count<=10){Phon="+52"+Telefono.text!}
        let parameters: Parameters = [
            "modo": 0,
            "nombre": Name,
            "apellidos":NamL,
            "email":Emai,
            "password":Pasw,
            "tel":Phon
        ]
        RegisterFunc(parameters: parameters)
    }
    func RegisterFunc(parameters: Parameters){
        Alamofire.request("http://api.vietaxi.com/persona/", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)")
                    do{
                        let result = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                        //"Kc2yvONChc"
                        //Código de confirmación: 5372
                        if let token = result["token"] as? String{
                            UserDefaults.standard.setValue(token, forKey: "token")
                            DispatchQueue.main.async {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmPhoneVC") as! PhoneController
                                self.present(vc, animated: true, completion: nil)
                            }
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
                    print("JSON: \(result)")
                    if let mensaje = result["mensaje"] as? String{
                        print(mensaje)
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error de registro", message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                catch let error as NSError{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error de servidor", message: "Error 500 comuniquese con el administrador", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    //MARK: FacebookLogin
    @IBAction func FacebookLogin(_ sender: UIButton) {
        FacebookAccess()
    }
    func FacebookAccess(){
        var Pass:String = ""
        if let accessToken = AccessToken.current {
            Pass = accessToken.userId!
            FacebookParameters(token:Pass)
        }else{
            let loginManager = LoginManager()
            loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error de acceso", message: "Haz cancelado el acceso a Facebook", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    Pass = accessToken.userId!
                    self.FacebookParameters(token:Pass)
                }
            }
        }
        
    }
    func FacebookParameters(token:String){
        var Phone:String = self.TelefonoRedes.text!
        if(Phone.characters.count<=10){Phone="+52"+Telefono.text!}
        let parameters: Parameters = [
            "modo": 1,
            "tel": Phone,
            "facebook1":token,
            "facebook2":token
            
        ]
        RegisterFunc(parameters: parameters)
    }
    //MARK: GoogleDelegate
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
        print("Sign in presented")
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
        print("Sign in dismiss")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            if GIDSignIn.sharedInstance().hasAuthInKeychain(){
                let Pass:String = GIDSignIn.sharedInstance().currentUser.userID
                let Phone:String = self.TelefonoRedes.text!
                let parameters: Parameters = [
                    "modo": 2,
                    "tel": Phone,
                    "google1":Pass,
                    "google2":Pass
                ]
                self.RegisterFunc(parameters: parameters)
            } else{
                let alert = UIAlertController(title: "Error de acceso", message: "Haz cancelado el acceso a Facebook", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    }
    //MARK: GoogleLogin
    @IBAction func GoogleLogin(_ sender: UIButton) {
        if((TelefonoRedes.text?.characters.count)!>0){
            GoogleAccess()
        }else{
            let alert = UIAlertController(title: "Error de registro", message: "Escribe un telefono para registrarte con tus redes sociales", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func GoogleAccess(){
        var Pass:String = ""
        GIDSignIn.sharedInstance().uiDelegate = self
        /*
         GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
         GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")*/
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/userinfo.profile")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/userinfo.email")
        
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain(){
            GIDSignIn.sharedInstance().signInSilently()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                if GIDSignIn.sharedInstance().hasAuthInKeychain(){
                    Pass = GIDSignIn.sharedInstance().currentUser.userID
                    let Phone:String = self.TelefonoRedes.text!
                    //113038717866896628337
                    let parameters: Parameters = [
                        "modo": 2,
                        "tel": Phone,
                        "google1":Pass,
                        "google2":Pass
                    ]
                    self.RegisterFunc(parameters: parameters)
                }})
        }
        else {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    //MARK: TextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= LoginController.MAX_TEXT_SIZE
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.Nombre {
            self.Apellido.becomeFirstResponder()
        }
        if textField == self.Apellido {
            self.Telefono.becomeFirstResponder()
        }
        if textField == self.Telefono {
            self.Correo.becomeFirstResponder()
        }
        if textField == self.Correo {
            self.Contraseña.becomeFirstResponder()
        }
        if textField == self.Contraseña {
            self.Cocontraseña.becomeFirstResponder()
        }
        else if textField == self.Cocontraseña {
            self.Cocontraseña.resignFirstResponder()
            let Name:String = Nombre.text!
            let NamL:String = Apellido.text!
            let Emai:String = Correo.text!
            let Pasw:String = Contraseña.text!
            let Phon:String = Telefono.text!
            let parameters: Parameters = [
                "modo": 0,
                "nombre": Name,
                "apellidos":NamL,
                "email":Emai,
                "password":Pasw,
                "tel":Phon
            ]
            RegisterFunc(parameters: parameters)
        }
        else if textField == self.TelefonoRedes{
            self.TelefonoRedes.resignFirstResponder()
            if((TelefonoRedes.text?.characters.count)!>0){
                GoogleAccess()
            }else{
                let alert = UIAlertController(title: "Error de registro", message: "Escribe un telefono para registrarte con tus redes sociales", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        return true
    }
    @IBOutlet weak var RegistroData: UIStackView!
    @IBAction func Focus(_ sender: Any) {
        self.RegistroData.isHidden = true
    }
    @IBAction func NoFocus(_ sender: UITextField) {
        self.RegistroData.isHidden = false
    }
}
