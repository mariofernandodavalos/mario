//
//  PagoController.swift
//  VieTaxi
//
//  Created by usuario on 17/10/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import UIKit
import QuartzCore
class PagoController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var Num: UITextField!
    @IBOutlet weak var Mes: UITextField!
    @IBOutlet weak var Ano: UITextField!
    @IBOutlet weak var Cvv: UITextField!
    @IBOutlet weak var Agrega: UIButton!
    static let MAX_TEXT_SIZE = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Num.layer.cornerRadius = 15.0
        self.Mes.layer.cornerRadius = 15.0
        self.Ano.layer.cornerRadius = 15.0
        self.Cvv.layer.cornerRadius = 15.0
        self.Agrega.layer.cornerRadius = 15.0
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
