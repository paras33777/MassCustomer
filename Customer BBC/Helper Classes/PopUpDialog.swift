//
//  PopUpDialog.swift
//  BBC Retail
//
//  Created by Prashant Kumar on 14/04/22.
//

import UIKit
import Foundation
import PopupDialog

struct DropdownPopUp {
    let dropDownVC = DropDownController(nibName: "DropdownPopUp", bundle: nil)
    //MARK: ****************DropDown
    init(title:String,type:DataType,dropDownType:DropdownType,data: [DropDownModel],sender :UIViewController) {
        let popup = PopupDialog(viewController: dropDownVC, buttonAlignment: .horizontal, transitionStyle: .zoomIn, tapGestureDismissal: true)
        dropDownVC.dataList = data
        dropDownVC.tblView.reloadData()
        dropDownVC.lblTitle.text = title
        dropDownVC.dataType = type
        dropDownVC.dropdownType = dropDownType
        sender.present(popup, animated: true, completion: nil)
    }
}
    struct DropdownActionPopUp {
        let alertActionVC = AlertActionController(nibName: "AlertAction", bundle: nil)
        //MARK: ****************DropDown
        init(title:String,header:String,action:DropdownAction,type:DropdownActionType,sender :UIViewController,image:UIImage?,tapDismiss:Bool) {
            let popup = PopupDialog(viewController: alertActionVC, buttonAlignment: .horizontal, transitionStyle: .zoomIn, tapGestureDismissal: tapDismiss)
            alertActionVC.lblTitle.text = title
            alertActionVC.imgVW.image = image
            alertActionVC.lblHeader.text = header
            alertActionVC.action = action
            alertActionVC.actionType = type
            sender.present(popup, animated: true, completion: nil)
        }

}
