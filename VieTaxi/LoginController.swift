//
//  ViewController.swift
//  VieTaxi
//
//  Created by usuario on 06/10/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import UIKit
import QuartzCore
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
    
    public static var TableBarInit:UINavigationController?
     static let MAX_TEXT_SIZE = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Ingresar.layer.cornerRadius = 15.0
        self.UserLabel.layer.cornerRadius = 15.0
        self.PassLabel.layer.cornerRadius = 15.0
        LogoSave = Logo
        Facebook.imageView?.contentMode = .scaleAspectFit
        Google.imageView?.contentMode = .scaleAspectFit
        LoginController.TableBarInit=self.storyboard?.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        //GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        
    }
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        //myActivityIndicator.stopAnimating()
    }
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
        print("Sign in presented")
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
        print("Sign in dismiss")
       DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
        if GIDSignIn.sharedInstance().hasAuthInKeychain(){
            
                let TB = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! UITabBarController
                self.present(LoginController.TableBarInit!, animated: true, completion: nil)
            
        } else{
                let alert = UIAlertController(title: "Error de acceso", message: "Haz cancelado el acceso a Facebook", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //self.dismiss(animated: true, completion: nil)
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        print("Welcome: ,\(userId), \(idToken), \(fullName), \(givenName), \(familyName), \(email)")
        DispatchQueue.main.async {
            
            self.present(LoginController.TableBarInit!, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func FacebookLogin(_ sender: Any) {
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            DispatchQueue.main.async {
                let TB = self.storyboard?.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
                self.present(LoginController.TableBarInit!, animated: true, completion: nil)
                
            }
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
                DispatchQueue.main.async {
                    let TB = self.storyboard?.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
                    self.present(LoginController.TableBarInit!, animated: true, completion: nil)
                    
                }
            }
            }
        }
    }
    
    @IBAction func GoogleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        if GIDSignIn.sharedInstance().hasAuthInKeychain(){
            
            DispatchQueue.main.async {
                let TB = self.storyboard?.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
                self.present(LoginController.TableBarInit!, animated: true, completion: nil)
                
            }        }
        //GIDSignIn.sharedInstance().signOut()
    }
    
    //MARK: Metodos del text Field delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= LoginController.MAX_TEXT_SIZE
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

