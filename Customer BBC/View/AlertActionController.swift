//
//  AlertActionController.swift
//  Newforce
//
//  Created by Apple on 08/08/19.
//  Copyright © 2019 Newforce Ltd. All rights reserved.
//

import UIKit
protocol DropdownActionDelegate: AnyObject{
    func dropdownActionBool(yesClicked:Bool,type:DropdownActionType)
}
class AlertActionController: UIViewController {
    //MARK: *************IBOUTLET
    @IBOutlet weak var stackButtons: UIStackView!
    @IBOutlet weak var imgVW: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var heightImage: NSLayoutConstraint!
    //MARK: *************CONSTANTS
    var delegate : DropdownActionDelegate!
    var action: DropdownAction!
    var actionType: DropdownActionType!
   
    //MARK: *************IBACTION
    @IBAction func btnYesAction(_ sender: UIButton) {
        self.dismiss(animated: true)
        delegate?.dropdownActionBool(yesClicked:true,type:actionType)
    }
    @IBAction func btnNoAction(_ sender: UIButton) {
        delegate?.dropdownActionBool(yesClicked: false,type:actionType)
        self.dismiss(animated: true)
    }
    //MARK: *************VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
            }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if imgVW.image == nil{
            heightImage.constant = 0
        }
        if action == DropdownAction.Okay{
            stackButtons.subviews[1].isHidden = true
            btnYes.backgroundColor = .white
            btnYes.setTitle("Okay", for: .normal)
        }
    }

       }
