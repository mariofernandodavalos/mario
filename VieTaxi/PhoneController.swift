//
//  PhoneController.swift
//  VieTaxi
//
//  Created by usuario on 29/12/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

import Alamofire

class PhoneController : UIViewController{
    
     @IBOutlet weak var Active: UIButton!
    @IBOutlet weak var Code: UITextField!
    
    @IBOutlet weak var WindowWhite: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Active.layer.cornerRadius = 15.0
        self.Code.layer.cornerRadius = 20.0
        
    }
    
    @IBAction func ActiveFunction(_ sender: UIButton) {
       
        let token:String = UserDefaults.standard.value(forKey: "token")! as! String
        var codigo:Int = 0
        if let codig:Int = Int(Code.text!){
            codigo = codig
        }else{
            Code.textColor = UIColor.red
        }
        let parameters: Parameters = [
            "token": token,
            "codigo": codigo
        ]
        ConfirmFunc(parameters: parameters)
    }
    func ConfirmFunc(parameters: Parameters){
        Alamofire.request("http://api.vietaxi.com/persona/validarCod/", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)")
                    do{
                        let result = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                        //"Kc2yvONChc"
                        //Código de confirmación: 5372
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Usuario registrado", message: "El registro se ha completado", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction( UIAlertAction(title: "Continuar", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
                                    self.present(AppDelegate.TableBarInit!, animated: true, completion: nil)
                                }))
                                self.present(alert, animated: true, completion: nil)
                        }
                    }
                    catch let error as NSError{
                        print("Error: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print(error)
                self.Code.textColor = UIColor.red
                do{
                    print( response.data!)
                    let result = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                    if let mensaje = result["mensaje"] as? String{
                        print(mensaje)
                        self.Code.textColor = UIColor.red
                    }
                }
                catch let error as NSError{
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
