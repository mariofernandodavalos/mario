//
//  ViewController.swift
//  VieTaxi
//
//  Created by usuario on 06/10/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import UIKit
import QuartzCore

import Alamofire

import FacebookCore
import FacebookLogin

import Google
import GoogleSignIn
import GGLSignIn

class LoginController: UIViewController, UITextFieldDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var UserLabel: UITextField!
    
    @IBOutlet weak var PassLabel: UITextField!
    
    @IBOutlet weak var Ingresar: UIButton!
    
    @IBOutlet weak var DataLogin: UIStackView!
    
    @IBOutlet weak var Logo: UIImageView!
    
    @IBOutlet weak var VieTaxi: UIImageView!
    
    @IBOutlet weak var Facebook: UIButton!
    @IBOutlet weak var Google: UIButton!
    
    var LogoSave: UIImageView!
    var LogoChan: UIImageView!
    
     static let MAX_TEXT_SIZE = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Ingresar.layer.cornerRadius = 15.0
        self.UserLabel.layer.cornerRadius = 15.0
        self.PassLabel.layer.cornerRadius = 15.0
        LogoSave = Logo
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
    //MARK:Login
    @IBAction func LoginAccess(_ sender: UIButton) {
        let User:String = UserLabel.text!
        let Pass:String = PassLabel.text!
        let parameters: Parameters = [
            "modo": 0,
            "app": 1,
            "email":User,
            "password":Pass
        ]
        LoginFunc(parameters: parameters)
    }
    func LoginFunc(parameters: Parameters){
        var params = parameters
        Alamofire.request("http://api.vietaxi.com/usuario/login/", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                let modo:Int = params.removeValue(forKey: "modo") as! Int
                UserDefaults.standard.setValue(modo, forKey: "modo")
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
            Alamofire.request("http://api.vietaxi.com/persona/?token="+tok).validate().responseJSON { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        do{
                            let result = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                            if let nombre = result["nombre"] as? String{UserDefaults.standard.setValue(nombre, forKey: "nombre")}
                            if let apellidos = result["apellidos"] as? String{UserDefaults.standard.setValue(apellidos, forKey: "apellidos")}
                            if let tel = result["tel"] as? String{UserDefaults.standard.setValue(tel, forKey: "tel")}
                            if let email = result["email"] as? String{UserDefaults.standard.setValue(email, forKey: "email")}
                            if let rfc = result["rfc"] as? String{UserDefaults.standard.setValue(rfc, forKey: "rfc")}
                            if let calificacion = result["calificacion"] as? String{UserDefaults.standard.setValue(calificacion, forKey: "calificacion")}
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
    //MARK: FacebookLogin
    @IBAction func FacebookLogin(_ sender: Any) {
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
        //"facebook":"10210320611905144"
    }
    func FacebookParameters(token:String){
        UserDefaults.standard.setValue(token, forKey: "UserID")
        let parameters: Parameters = [
            "modo": 1,
            "app": 1,
            "facebook1":token,
            "facebook2":token
            
        ]
        LoginFunc(parameters: parameters)
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
            let UserID:String = GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 200).absoluteString
            UserDefaults.standard.setValue(UserID, forKey: "UserID")
                let parameters: Parameters = [
                    "modo": 2,
                    "app": 1,
                    "google1":Pass,
                    "google2":Pass
                ]
                self.LoginFunc(parameters: parameters)
        } else{
                let alert = UIAlertController(title: "Error de acceso", message: "Haz cancelado el acceso a Google+", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
        }
    }

   //MARK: GoogleLogin
    @IBAction func GoogleLogin(_ sender: UIButton) {
        GoogleAccess()
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
                    let Pass:String = GIDSignIn.sharedInstance().currentUser.userID
                    let UserID:String = String(describing: GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 200))
                    UserDefaults.standard.setValue(UserID, forKey: "UserID")
                    //113038717866896628337
                    let parameters: Parameters = [
                        "modo": 2,
                        "app": 1,
                        "google1":Pass,
                        "google2":Pass
                    ]
                    self.LoginFunc(parameters: parameters)
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
        if textField == self.UserLabel {
            self.PassLabel.becomeFirstResponder()
        }
        else if textField == self.PassLabel {
            self.PassLabel.resignFirstResponder()
            let User:String = UserLabel.text!
            let Pass:String = PassLabel.text!
            let parameters: Parameters = [
                "modo": 0,
                "app": 1,
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

