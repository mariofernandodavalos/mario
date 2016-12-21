//
//  TabBarSelectedController.swift
//  VieTaxi
//
//  Created by usuario on 09/12/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import Foundation
import UIKit
class BaseTabBarController: UITabBarController {
    
    @IBInspectable var defaultIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }
    
}
