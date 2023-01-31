//
//  AddCardVC.swift
//  Customer BBC
//
//  Created by PARAS on 30/09/22.
//

import UIKit
import StripeCore
import Stripe
import FTIndicator


class AddCardVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cardNameTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    
    
    //    MARK: - VARIABLES
        var token = String()
        var amount = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    //  MARK: - ACTIONs
   
    
    
    @IBAction func payOnPress(_ sender: UIButton) {
        if cardNameTextField.isEmptyy(){
            FTIndicator.showToastMessage("Enter card holder name")
            return
        }
        if cardNumberTextField.isEmptyy(){
            FTIndicator.showToastMessage("Enter card number")
            return
        }
        if expiryDateTextField.isEmptyy(){
            FTIndicator.showToastMessage("Enter expiry date")
            return
        }
        if cvvTextField.isEmptyy(){
            FTIndicator.showToastMessage("Enter cvv")
            return
        }
        
        self.showIndicator()
        let comps = expiryDateTextField.text?.components(separatedBy: " / ")
        let f = UInt(comps!.first!)
        let l = UInt(comps!.last!)
        
        let cardParams = STPCardParams()
        cardParams.name = cardNameTextField.text!
        cardParams.number = cardNumberTextField.text!
        cardParams.expMonth = f!
        cardParams.expYear =  l!
        cardParams.cvc = cvvTextField.text!
        
        STPAPIClient.shared.createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
            print("Printing Strip response:\(String(describing: token?.allResponseFields))\n\n")
            print("Printing Strip Token:\(String(describing: token?.tokenId))")
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                self.hideIndicator()
                FTIndicator.showToastMessage("Card Details are invalid")
                
            }
            
            if token != nil{
                self.token = token?.tokenId ?? ""
                let userID = "\(Singleton.sharedInstance.userInfo.userId ?? "")"//UserDefaults.standard.value(forKey: UserDefaultKey.kUserID) as? Int ?? 0
//                let param: [String: Any] = [
//                    "amount":self.amount,
//                    "token":token?.tokenId ?? "",
//                    "type":self.type,
//                    "price_id": self.priceId,
//                    "timeperiod": self.timePeriod
//
//                ]
//                self.model.userSubscriptionApi(param: param)
//
            }
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    //  MARK: - FUNCTIONS
    func modifyCreditCardString(creditCardString : String) -> String {
        let trimmedString = creditCardString.components(separatedBy: .whitespaces).joined()
        let arrOfCharacters = Array(trimmedString)
        var modifiedCreditCardString = ""
        
        if(arrOfCharacters.count > 0) {
            for i in 0...arrOfCharacters.count-1 {
                modifiedCreditCardString.append(arrOfCharacters[i])
                if((i+1) % 4 == 0 && i+1 != arrOfCharacters.count){
                    modifiedCreditCardString.append(" ")
                }
            }
        }
        return modifiedCreditCardString
    }
    
    func expDateValidation(dateStr:String) {
        
        let currentYear = Calendar.current.component(.year, from: Date()) % 100   // This will give you current year (i.e. if 2019 then it will be 19)
        let currentMonth = Calendar.current.component(.month, from: Date()) // This will give you current month (i.e if June then it will be 6)
        
        let enteredYear = Int(dateStr.suffix(2)) ?? 0 // get last two digit from entered string as year
        let enteredMonth = Int(dateStr.prefix(2)) ?? 0 // get first two digit from entered string as month
        print(dateStr) // This is MM/YY Entered by user
        
        if enteredYear > currentYear {
            if (1 ... 12).contains(enteredMonth) {
                print("Entered Date Is Right")
            } else {
                print("Entered Date Is Wrong")
            }
        } else if currentYear == enteredYear {
            if enteredMonth >= currentMonth {
                if (1 ... 12).contains(enteredMonth) {
                    print("Entered Date Is Right")
                } else {
                    print("Entered Date Is Wrong")
                }
            } else {
                print("Entered Date Is Wrong")
            }
        } else {
            print("Entered Date Is Wrong")
        }
    }

    //  MARK: - TEXTFIELD DELEGATE
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text ?? "").count + string.count - range.length
        if(textField == cardNumberTextField) {
            if newLength <= 19{
                return true
            }else{
                self.expiryDateTextField.becomeFirstResponder()
                return false
            }
        }
        if(textField == expiryDateTextField) {
            if newLength <= 7{
                return true
            }else{
                self.cvvTextField.becomeFirstResponder()
                return false
            }
        }
        if(textField == cvvTextField) {
            if newLength <= 3{
                return true
            }else{
                self.cvvTextField.resignFirstResponder()
                return false
            }
        }
        
        return true
    }

}
extension UITextField {

    func isEmptyy() -> Bool {
        return self.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
    }
    
}
