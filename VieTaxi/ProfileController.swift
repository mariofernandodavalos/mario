//
//  ProfileController.swift
//  VieTaxi
//
//  Created by usuario on 17/10/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
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
    
    @IBOutlet var Vista: UIView!
    
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func EditorButton(_ sender: UIButton) {
        if(Editor.isHidden)
        {
            EditButton.setTitle("   Guardar edicion", for: .normal)
            EditButton.backgroundColor? = ProfileController.ColorAmarillo
            Editor.isHidden = false
            Vissor.isHidden = true
            ProfileATop.isHidden = true
            Vista.backgroundColor = ProfileController.ColorAzul
        }
        else
        {
            EditButton.setTitle("   Editar perfil", for: .normal)
            EditButton.backgroundColor? = ProfileController.ColorAzul
            Editor.isHidden = true
            Vissor.isHidden = false
            ProfileATop.isHidden = false
            Vista.backgroundColor = UIColor.white
        }
    }
    
    //MARK: Metodos del text Field delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= LoginController.MAX_TEXT_SIZE
    }
}
