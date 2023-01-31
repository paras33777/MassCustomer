//
//  NFNavigationController.swift
//  Newforce
//
//
//  Created by Admin on 03/07/19.
//  Copyright © 2019 Newforce Ltd. All rights reserved.
//

import UIKit

class NFNavigationController: UINavigationController {
    //MARK: ******************* IBOUTLET
    //MARK: ******************* VARIABLE
    //MARK: ******************* IBACTIONS
    //MARK: ******************* VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = .white
        
//        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 20)!]
//
//        self.navigationBar.barTintColor = hexStringToUIColor(hex: Color.blueApp.rawValue)
        self.navigationBar.isHidden = true
    }
    
}
