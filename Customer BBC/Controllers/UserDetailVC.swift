//
//  UserDetailVC.swift
//  Customer BBC
//
//  Created by PARAS on 29/09/22.
//

import UIKit
import FTIndicator

class UserDetailVC: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userNumberLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userNameLabel.text = Singleton.sharedInstance.userInfo.firstname ?? ""
        self.userEmailLabel.text = Singleton.sharedInstance.userInfo.email ?? ""
        self.userNumberLabel.text = UserDefaults.standard.string(forKey: "Mobile") ?? ""
//Singleton.sharedInstance.userInfo.mobile ?? ""

    }
    
    @IBAction func deleteAction(_ sender: UIButton){
        let dropDown =  DropdownActionPopUp.init(title: "Are you sure you want to delete this account?",header:"",action: .YesNo, type: .deleteAccount, sender: self, image: nil,tapDismiss:true)
       
          dropDown.alertActionVC.delegate = self
    }
    
    @IBAction func backAction(_sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: - DELETE Account API
    func deleteUserAPI(){
        self.showIndicator()
        WebServiceManager.sharedInstance.deleteUserAPI { msg, status in
            self.hideIndicator()
            if status == "1"{
                Singleton.sharedInstance.userInfo = nil
                Singleton.sharedInstance.storeInfo = nil
                Singleton.sharedInstance.cartInfo.cartList = [Productlist]()
                if let bundleID = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: bundleID)
                }
                FTIndicator.showToastMessage(msg!)

                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstController") as! FirstController
                let window = UIApplication.shared.keyWindow
                window?.rootViewController = homeVC
                window?.makeKeyAndVisible()
             }else{
             FTIndicator.showToastMessage(msg!)
             }
        }

         }
}
extension UserDetailVC:DropdownActionDelegate{
    func dropdownActionBool(yesClicked: Bool, type: DropdownActionType) {
        if yesClicked{
            if type == .storeInactive{
                
            }else{

                deleteUserAPI()

            }
        }
    }
}
