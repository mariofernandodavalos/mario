//
//  ProfileController.swift
//  VieTaxi-Chofer
//
//  Created by usuario on 15/12/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

import Alamofire

class ProfileController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var Editor: UIStackView!
    @IBOutlet weak var Visor: UIStackView!
    @IBOutlet weak var Vissor: UIStackView!
    
    @IBOutlet weak var TelefonoEdit: UITextField!
    @IBOutlet weak var CorreoEdit: UITextField!
    @IBOutlet weak var RFCEdit: UITextField!
    @IBOutlet weak var Contraseña: UITextField!
    @IBOutlet weak var Cocontraseña: UITextField!
    
    @IBOutlet weak var ProfileATop: UIStackView!
    @IBOutlet weak var ProfileTop: UIImageView!
    @IBOutlet weak var Profile: UIImageView!
    @IBOutlet weak var Cancelar: UIButton!
    
    @IBOutlet var Vista: UIView!
    
    @IBOutlet weak var Nombre: UILabel!
    @IBOutlet weak var Telefono: UIButton!
    @IBOutlet weak var Correo: UIButton!
    @IBOutlet weak var RFC: UIButton!
    @IBOutlet weak var Domicilio: UIButton!
    @IBOutlet weak var Licencia: UIButton!
    @IBOutlet weak var Empresa: UIButton!
    @IBOutlet weak var Star1: UIImageView!
    @IBOutlet weak var Star2: UIImageView!
    @IBOutlet weak var Star3: UIImageView!
    @IBOutlet weak var Star4: UIImageView!
    @IBOutlet weak var Star5: UIImageView!
    
    @IBOutlet weak var EditButton: UIButton!
    
    static let MAX_TEXT_SIZE = 30
    static let ColorAzul = UIColor(red: 68/255, green: 98/255, blue: 126/255, alpha: 1)
    static let ColorAmarillo = UIColor(red: 199/255, green: 150/255, blue: 19/255, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.TelefonoEdit.layer.cornerRadius = 15.0
        self.CorreoEdit.layer.cornerRadius = 15.0
        self.RFCEdit.layer.cornerRadius = 15.0
        self.Contraseña.layer.cornerRadius = 15.0
        self.Cocontraseña.layer.cornerRadius = 15.0
        
        LoadUserInfo()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.UserInfoLoad()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with: event)
        self.view.endEditing(true)
    }
    
    @IBAction func EditorButton(_ sender: UIButton) {
        if(Editor.isHidden)
        {
            Profile.isHidden = true
            Cancelar.isHidden = false
            EditButton.setTitle("   Guardar edicion", for: .normal)
            EditButton.backgroundColor? = ProfileController.ColorAmarillo
            Editor.isHidden = false
            Vissor.isHidden = true
            ProfileATop.isHidden = true
            Vista.backgroundColor = ProfileController.ColorAzul
        }
        else
        {
            let token:String = UserDefaults.standard.value(forKey: "token")! as! String
            let Emai:String = CorreoEdit.text!
            let Pasw:String = Contraseña.text!
            let Phon:String = TelefonoEdit.text!
            let Domi:String = RFCEdit.text!
            var parameters: Parameters = [
                "token":token,
                "email":Emai,
                "password":Pasw,
                "tel":Phon,
                "domicilio":Domi
            ]
            if(Emai.characters.count<1){parameters.removeValue(forKey: "email")}
            if let email = UserDefaults.standard.string(forKey: "email"){
                if(Emai == email){parameters.removeValue(forKey: "email")}
            }
            if(Pasw.characters.count<1){parameters.removeValue(forKey: "password")}
            if let password = UserDefaults.standard.string(forKey: "password"){
                if(Pasw == password){parameters.removeValue(forKey: "password")}
            }
            if(Phon.characters.count<1){parameters.removeValue(forKey: "telefono")}
            if let tel = UserDefaults.standard.string(forKey: "telefono"){
                if(Phon == tel){parameters.removeValue(forKey: "telefono")}
            }
            if(Domi.characters.count<1){parameters.removeValue(forKey: "domicilio")}
            if let domicilio = UserDefaults.standard.string(forKey: "domicilio"){
                if(Domi == domicilio){parameters.removeValue(forKey: "domicilio")}
            }
            ChangFunc(parameters: parameters)
            
        }

    }
    
    @IBAction func CancelButton(_ sender: UIButton) {
        Profile.isHidden = false
        Cancelar.isHidden = true
        EditButton.setTitle("   Editar perfil", for: .normal)
        EditButton.backgroundColor? = ProfileController.ColorAzul
        Editor.isHidden = true
        Vissor.isHidden = false
        ProfileATop.isHidden = false
        Vista.backgroundColor = UIColor.white
    }
    //MARK:LogOut
    @IBAction func LogOutAccess(_ sender: UIButton) {
        let token:String = UserDefaults.standard.value(forKey: "token")! as! String
        let parameters: Parameters = [
            "token":token
        ]
        LogOutFunc(parameters: parameters)
    }
    func LogOutFunc(parameters: Parameters){
        Alamofire.request("http://api.vietaxi.com/usuario/logout/", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)")
                    do{
                        UserDefaults.standard.setValue("", forKey: "token")
                        
                        let login = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginController
                        self.present(login!, animated: true, completion: nil)
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
                }
            }
        }
    }
    func LoadUserInfo(){
        self.Telefono.isHidden=false
        self.Correo.isHidden=false
        self.RFC.isHidden=false
        if let nombre = UserDefaults.standard.string(forKey: "nombre")
        {self.Nombre.text?=nombre
        }else{self.Nombre.text?=""}
        if let apellidos = UserDefaults.standard.string(forKey: "apellidos") {self.Nombre.text?+=" "+apellidos}
        if let tel = UserDefaults.standard.string(forKey: "telefono") {self.Telefono.setTitle("   "+tel, for: .normal)
        self.TelefonoEdit.text?=tel}else{self.Telefono.isHidden=true}
        if let email = UserDefaults.standard.string(forKey: "email") {self.Correo.setTitle("   "+email, for: .normal)
            self.CorreoEdit.text?=email}else{self.Correo.isHidden=true}
        if let rfc = UserDefaults.standard.string(forKey: "rfc") {self.RFC.setTitle("   "+rfc, for: .normal)}else{self.RFC.isHidden=true}
        if let domicilio = UserDefaults.standard.string(forKey: "domicilio") {self.Domicilio.setTitle("   "+domicilio, for: .normal)
            self.RFCEdit.text?=domicilio}else{self.Domicilio.isHidden=true}
        if let licencia = UserDefaults.standard.string(forKey: "licencia") {self.Licencia.setTitle("   "+licencia, for: .normal)
        }else{self.Licencia.isHidden=true}
        if let empresa = UserDefaults.standard.string(forKey: "empresa") {self.Empresa.setTitle("   "+empresa, for: .normal)
        }else{self.Empresa.isHidden=true}
        
        if let calificacion = UserDefaults.standard.string(forKey: "calificacion"){
            let stars = Double(calificacion)
            //Star1
            if(stars!==0.0){Star1.image = #imageLiteral(resourceName: "StarNo")}
            if(stars!>0.0){Star1.image = #imageLiteral(resourceName: "StarMedium")}
            if(stars!>0.7){Star1.image = #imageLiteral(resourceName: "Star")}
            //Star2
            if(stars!<0.7){Star2.image = #imageLiteral(resourceName: "StarNo")}
            if(stars!>1.0){Star2.image = #imageLiteral(resourceName: "StarMedium")}
            if(stars!>1.7){Star2.image = #imageLiteral(resourceName: "Star")}
            //Star3
            if(stars!<1.7){Star3.image = #imageLiteral(resourceName: "StarNo")}
            if(stars!>2.0){Star3.image = #imageLiteral(resourceName: "StarMedium")}
            if(stars!>2.7){Star3.image = #imageLiteral(resourceName: "Star")}
            //Star4
            if(stars!<2.7){Star4.image = #imageLiteral(resourceName: "StarNo")}
            if(stars!>3.0){Star4.image = #imageLiteral(resourceName: "StarMedium")}
            if(stars!>3.7){Star4.image = #imageLiteral(resourceName: "Star")}
            //Star5
            if(stars!<3.7){Star5.image = #imageLiteral(resourceName: "StarNo")}
            if(stars!>4.0){Star5.image = #imageLiteral(resourceName: "StarMedium")}
            if(stars!>4.7){Star5.image = #imageLiteral(resourceName: "Star")}
            
        }else{
            Star1.image = #imageLiteral(resourceName: "Star")
            Star2.image = #imageLiteral(resourceName: "Star")
            Star3.image = #imageLiteral(resourceName: "Star")
            Star4.image = #imageLiteral(resourceName: "Star")
            Star5.image = #imageLiteral(resourceName: "Star")
        }
        
    }
    
    func ChangFunc(parameters: Parameters){
        if(parameters.count>1){
            Alamofire.request("http://api.vietaxi.com/chofer/", method: .put, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        do{
                            let result = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                            //"Kc2yvONChc"
                            //Código de confirmación: 5372
                            if let mensaje = result["mensaje"] as? String{
                                print(mensaje)
                                DispatchQueue.main.async {
                                    self.UserInfoLoad()
                                    
                                    let alert = UIAlertController(title: "Guardado", message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                                        self.view.endEditing(true)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    self.Profile.isHidden = false
                                    self.Cancelar.isHidden = true
                                    self.EditButton.setTitle("   Editar perfil", for: .normal)
                                    self.EditButton.backgroundColor? = ProfileController.ColorAzul
                                    self.Editor.isHidden = true
                                    self.Vissor.isHidden = false
                                    self.ProfileATop.isHidden = false
                                    self.Vista.backgroundColor = UIColor.white
                                    self.view.endEditing(true)
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
                        if let mensaje = result["mensaje"] as? String{
                            print(mensaje)
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Error al guardar", message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    catch let error as NSError{
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }else{
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "No hay cambios", message: "No se detecto ningun cambio si no deseas cambiar ningun dato, oprime Cancelar", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Continuar", style: UIAlertActionStyle.default, handler: nil))
                alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                    self.Profile.isHidden = false
                    self.Cancelar.isHidden = true
                    self.EditButton.setTitle("   Editar perfil", for: .normal)
                    self.EditButton.backgroundColor? = ProfileController.ColorAzul
                    self.Editor.isHidden = true
                    self.Vissor.isHidden = false
                    self.ProfileATop.isHidden = false
                    self.Vista.backgroundColor = UIColor.white
                    self.view.endEditing(true)
                }))
                self.present(alert, animated: true, completion: nil)
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
        if textField == self.TelefonoEdit {
            self.CorreoEdit.becomeFirstResponder()
        }
        if textField == self.CorreoEdit {
            self.RFCEdit.becomeFirstResponder()
        }
        if textField == self.RFCEdit {
            self.Contraseña.becomeFirstResponder()
        }
        if textField == self.Contraseña {
            self.Cocontraseña.becomeFirstResponder()
        }
        else if textField == self.Cocontraseña {
            self.Cocontraseña.resignFirstResponder()
            let token:String = UserDefaults.standard.value(forKey: "token")! as! String
            let Emai:String = CorreoEdit.text!
            let Pasw:String = Contraseña.text!
            let Phon:String = TelefonoEdit.text!
            let Domi:String = RFCEdit.text!
            var parameters: Parameters = [
                "token":token,
                "email":Emai,
                "password":Pasw,
                "tel":Phon,
                "domicilio":Domi
            ]
            if(Emai.characters.count<1){parameters.removeValue(forKey: "email")}
            if let email = UserDefaults.standard.string(forKey: "email"){
                if(Emai == email){parameters.removeValue(forKey: "email")}
            }
            if(Pasw.characters.count<1){parameters.removeValue(forKey: "password")}
            if let password = UserDefaults.standard.string(forKey: "password"){
                if(Pasw == password){parameters.removeValue(forKey: "password")}
            }
            if(Phon.characters.count<1){parameters.removeValue(forKey: "telefono")}
            if let tel = UserDefaults.standard.string(forKey: "telefono"){
                if(Phon == tel){parameters.removeValue(forKey: "telefono")}
            }
            if(Domi.characters.count<1){parameters.removeValue(forKey: "domicilio")}
            if let domicilio = UserDefaults.standard.string(forKey: "domicilio"){
                if(Domi == domicilio){parameters.removeValue(forKey: "domicilio")}
            }
            ChangFunc(parameters: parameters)
        }
        return true
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
                            
                            self.LoadUserInfo()
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

}
