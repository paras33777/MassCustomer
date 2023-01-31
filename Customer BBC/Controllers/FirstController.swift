//
//  ViewController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 11/04/22.
//

import UIKit
import FTIndicator
import CountryPickerView
//git push
class FirstController: UIViewController {
//MARK: - IBOUTLET
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var imgVWFlag: UIImageView!
    @IBOutlet weak var txtCodeDialCode: UITextField!
    
    @IBOutlet weak var vwSubmitOtp: UIView!
    @IBOutlet var  otpTextFieldView: OTPFieldView!
    @IBOutlet weak var lblResend: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtOtpFill: OTPTextField!
    
    @IBOutlet weak var vwSendDetails: UIView!
    @IBOutlet weak var txtFName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtLName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    
   
    //MARK: - VARIABLES
    var code = String()
    let cpvInternal = CountryPickerView()
    var countdownTimer:Timer!
    var totalTime = 30
    var termText = ""
    let term = ""
    var otp = String()
    var userInfo : Userinfo!
    let hiddenOrigin: CGPoint = {
        let y = UIScreen.main.bounds.height + 60
        let x = CGFloat(0)
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    let fullScreenSize :CGSize = {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let coordinate = CGSize.init(width: width, height: height)
        return coordinate
    }()
    let fullScreenOrigin: CGPoint = {
        let x = CGFloat(0)
        var y = CGFloat(UIScreen.main.bounds.origin.y)
        
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    //MARK: - IBACTIONS
    @IBAction func btnNextAction(_ sender: UIButton) {
        ValidatePhoneField()
    }
    @IBAction func openPickerAction(_ sender: UIButton) {
        
        cpvInternal.showCountriesList(from: self)
          
    }
    @IBAction func btnSubmitOTP(_ sender: UIButton) {
        if self.otp == "" {
            FTIndicator.showToastMessage("Please enter OTP")
        }
       else if self.otp.count != 4{
            FTIndicator.showToastMessage("Please enter valid OTP")
       }else{
       veryfyOTP()
       }
    }
    @IBAction func btnSubmitOTPBack(_ sender: UIButton) {
        self.endTimer()
        hideBottomVw(vw: vwSubmitOtp)
        hideBottomVw(vw: vwSendDetails)
    }
    @IBAction func btnSubmitDetailsAction(_ sender: UIButton){
      ValidateBasicDetailsFields()
     }
    //MARK: - VIEW LIFE CYCLE
    override func viewDidLoad(){
        super.viewDidLoad()
        setupOtpView()
        setupCountyField()
        updateUI()
    }
    //MARK: - UPDATE UI
    func updateUI(){
        txtFName.placeholder = "First Name *"
        txtLName.placeholder = "Last Name *"
        txtEmail.placeholder = "Email *"
        var termText = "Didn't receive a code? Resend in 00:00 sec"
        let term = "Resend"
           
    vwSubmitOtp.alpha = 0
    txtOtpFill.textContentType = .oneTimeCode
    self.view.addSubview(vwSubmitOtp)
    hideBottomVw(vw: vwSubmitOtp)
        vwSendDetails.alpha = 0
        txtOtpFill.textContentType = .oneTimeCode
        self.view.addSubview(vwSendDetails)
        hideBottomVw(vw: vwSendDetails)
    }
    //MARK: - SET UP COUNTRY FIELD
    func setupCountyField(){
       // cpvInternal.showPhoneCodeInView = true
        cpvInternal.delegate = self
        cpvInternal.dataSource = self
        
      let country =  cpvInternal.getCountryByCode("IN")
        let image =   country!.flag
        self.imgVWFlag.image = image
        txtCodeDialCode.text = "\(country!.code) \(country!.phoneCode)"
        if #available(iOS 16.0, *) {
            let codee = country?.phoneCode.replacingOccurrences(of: "+", with: "")
            self.code = codee ?? ""
        } else {
            let codee = country?.phoneCode.replacingOccurrences(of: "+", with: "")
            self.code = codee ?? ""
            // Fallback on earlier versions
        }
        
       
    }
    // MARK: - VERIFY OTP API
    func veryfyOTP(){
        showIndicator()
        WebServiceManager.sharedInstance.verifyOTPAPI(countryCode: self.code, mobileNumber: txtPhoneNumber.text!, otp: self.otp){  userInfo,msg, status  in
          self.hideIndicator()
           if status == "1"{
               self.hideBottomVw(vw: self.vwSubmitOtp)
               guard let info = userInfo else{return}
               self.userInfo = userInfo
               if info.firstname == "" || info.lastname == "" || info.email == ""{
                   self.showBottomVw(vw: self.vwSendDetails)
               }else{
                   self.setRootVC()
               }
               FTIndicator.showToastMessage(msg)
           }else{
               FTIndicator.showToastMessage(msg)
           }
        }
    }
    // MARK: - VALIDATION
    func ValidatePhoneField(){
    do {
       // let countryCode = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: txtCodeDialCode.text!, fieldName: "country code")
        let phone = try Validation.shared.validate(type: ValidationType.mobileNumber, inputValue: txtPhoneNumber.text!, fieldName: "mobile number")
       
        loginAPI(countryCode: self.code, mobileNumber: phone)
        } catch(let error) {
            let message = (error as! ValidationError).message
            FTIndicator.showToastMessage(message)
        }
    }
    func ValidateBasicDetailsFields(){
    do {
        let fname = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: txtFName.text!, fieldName: "first name")
        let lname = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: txtLName.text!, fieldName: "last name")
        let email = try Validation.shared.validate(type: ValidationType.email, inputValue: txtEmail.text!, fieldName: "email")
       updateUserInfoAPI(email: email, firstname: fname, lastname: lname)
        } catch(let error) {
            let message = (error as! ValidationError).message
            FTIndicator.showToastMessage(message)
        }
    }
    // MARK: - LOGIN API
    func loginAPI(countryCode: String, mobileNumber: String){
        SKActivityIndicator.show()
        WebServiceManager.sharedInstance.loginAPI(countryCode: countryCode, mobileNumber: mobileNumber) { msg, status in
            SKActivityIndicator.dismiss()
            if status == "1"{
                let number = countryCode + mobileNumber
                UserDefaults.standard.setValue(number, forKey: "Mobile")
                self.startTimer()
                self.showBottomVw(vw: self.vwSubmitOtp)
               // self.navigationController?.popViewController(animated: true)
                FTIndicator.showToastMessage(msg)
            }else{
                FTIndicator.showToastMessage(msg)
             }
          }
       }
    // MARK: - UPDATE USER INFO API
    func updateUserInfoAPI( email: String,firstname: String, lastname: String){
        SKActivityIndicator.show()
        WebServiceManager.sharedInstance.updateUserInfoAPI( email: email, firstname: firstname, lastname: lastname, userID: userInfo!.userId ?? "") {userInfo, msg, status in
            SKActivityIndicator.dismiss()
            if status == "1"{
                self.hideBottomVw(vw: self.vwSendDetails)
             //   guard let info = userInfo else{return}
                self.setRootVC()
            }else{
                FTIndicator.showToastMessage(msg)
             }
          }
       }
    
    //MARK: - SET ROOT VC
    func setRootVC(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavi") as! UINavigationController
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
   }
extension FirstController{
    //MARK: SHOW HIDE BOTTTOM SHEETS
    @objc func hideBottomVw(vw:UIView){
        //   self.inputField.text = ""
        //    self.inputField.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            vw.frame.origin = self.hiddenOrigin
            vw.layoutIfNeeded()
            vw.alpha = 0
           })
           }
    func showBottomVw(vw:UIView){
        //   style()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [.beginFromCurrentState], animations: {
            vw.frame.origin = self.fullScreenOrigin
            vw.frame = CGRect.init(origin: self.fullScreenOrigin, size: self.fullScreenSize)
            // self.inputField.becomeFirstResponder()
            vw.layoutIfNeeded()
            vw.alpha = 1
        })
    }
    //MARK: *******START UPDATE END TIMER
    func startTimer() {
        totalTime = 30
        endTimer()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        lblResend.alpha = 1
        lblResend.text = "Didn't receive a code? Resend in \(timeFormatted(totalTime)) sec"
        let attrs11 = [NSAttributedString.Key.font : UIFont.init(name: "Montserrat-Regular", size: 15.0), NSAttributedString.Key.foregroundColor : UIColor.black]

        let attrs22 = [NSAttributedString.Key.font : UIFont.init(name: "Montserrat-Bold", size: 15.0), NSAttributedString.Key.foregroundColor : UIColor.black]

        let attributedString11 = NSMutableAttributedString(string:"Didn't receive a code? Resend in ", attributes:attrs11)

        let attributedString22 = NSMutableAttributedString(string:"\(timeFormatted(totalTime)) sec", attributes:attrs22)
        attributedString11.append(attributedString22)

        if totalTime != 0 {
            totalTime -= 1
            lblResend.attributedText = attributedString11
        } else {
            termText = "Didn't receive a code? Resend"
            
            lblResendOtpSet()
            endTimer()
           }
       }
    
    func endTimer() {
        if countdownTimer != nil{
            totalTime = 30
            countdownTimer.invalidate()
        }
    }
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
    func checkRange(_ range: NSRange, contain index: Int) -> Bool{
        return index > range.location && index < range.location + range.length
    }
    func lblResendOtpSet(){
        let formattedText = addBoldText(fullString: termText, boldPartOfString: term, baseFont: UIFont.init(name: "Montserrat-Regular", size: 14.0)!, boldFont: UIFont.init(name: "Montserrat-Bold", size: 15.0)!, boldColor: hexStringToUIColor(hex: Color.logoYellow.rawValue), baseColor: UIColor.black)
        lblResend.attributedText = formattedText
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTermTapped))
        lblResend.addGestureRecognizer(tap)
        lblResend.isUserInteractionEnabled = true
        lblResend.textAlignment = .center
    }
    func addBoldText(fullString: String, boldPartOfString: String, baseFont: UIFont, boldFont: UIFont,boldColor:UIColor,baseColor:UIColor) -> NSAttributedString {
        
       var attributedString = NSMutableAttributedString()
        attributedString = NSMutableAttributedString(string: termText as String, attributes: [NSAttributedString.Key.font:UIFont.init(name: "Montserrat-Regular", size: 14.0)!,NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:hexStringToUIColor(hex: Color.red.rawValue), range: NSRange(location:termText.count-term.count,length:term.count))
        attributedString.addAttribute( NSAttributedString.Key.font,value:UIFont.init(name: "Montserrat-Medium", size: 15.0)!, range: NSRange(location:termText.count-term.count,length:term.count))
        return attributedString
    }
    
    //MARK: ************Handler Term Tapped
    @objc func handleTermTapped(gesture: UITapGestureRecognizer) {
        let termString = termText as NSString
        let termRange = termString.range(of: term)
        let tapLocation = gesture.location(in: lblResend)
        let index = lblResend.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        if checkRange(termRange, contain: index) == true {
           ValidatePhoneField()
            return
        }
    }
    
}
//MARK: *********** OTP Field Func
extension FirstController:OTPFieldViewDelegate{
    func setupOtpView(){
        self.otpTextFieldView.fieldsCount = 4
        self.otpTextFieldView.fieldBorderWidth = 2
        self.otpTextFieldView.defaultBorderColor = UIColor.darkGray
        self.otpTextFieldView.filledBorderColor = hexStringToUIColor(hex: Color.red.rawValue)
        self.otpTextFieldView.cursorColor = UIColor.blue
        self.otpTextFieldView.displayType = .underlinedBottom
        self.otpTextFieldView.fieldSize = 40
        self.otpTextFieldView.separatorSpace = 15
        self.otpTextFieldView.shouldAllowIntermediateEditing = false
        self.otpTextFieldView.delegate = self
        self.otpTextFieldView.initializeUI()
        
    }
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        if  hasEntered{
            btnSubmit.isUserInteractionEnabled = true
        }else{
            btnSubmit.isUserInteractionEnabled = false
        }
        return false
    }
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        print("OTPString: \(otpString)")
        otp = otpString
    }
}
extension FirstController: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        // Only countryPickerInternal has it's delegate set
        let image =   country.flag
        self.imgVWFlag.image = image
        txtCodeDialCode.text = "\(country.code) \(country.phoneCode)"
        let codee = country.phoneCode.replacingOccurrences(of: "+", with: "")
        self.code = codee 
      //  self.code = codee
    }
}

extension FirstController: CountryPickerViewDataSource {
    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country] {
        
            return ["IN", "US"].compactMap { countryPickerView.getCountryByCode($0) }
      
    }
    
    func sectionTitleForPreferredCountries(in countryPickerView: CountryPickerView) -> String? {
//        if countryPickerView.tag == cpvMain.tag && showPreferredCountries.isOn {
//            return "Preferred title"
//        }
        return nil
    }
    
    func showOnlyPreferredSection(in countryPickerView: CountryPickerView) -> Bool {
        return false//countryPickerView.tag == cpvMain.tag && showOnlyPreferredCountries.isOn
    }
    
    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return "Select a Country"
    }
        
    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
//        if countryPickerView.tag == cpvMain.tag {
//            switch searchBarPosition.selectedSegmentIndex {
//            case 0: return .tableViewHeader
//            case 1: return .navigationBar
//            default: return .hidden
//            }
//        }
        return .tableViewHeader
    }
    
    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
        return true//countryPickerView.tag == cpvMain.tag && showPhoneCodeInList.isOn
    }
    
    func showCountryCodeInList(in countryPickerView: CountryPickerView) -> Bool {
       return false//countryPickerView.tag == cpvMain.tag && showCountryCodeInList.isOn
    }
}
extension FirstController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtLName || textField == txtFName{
            guard range.location < 31 - 1 else{return false}
            if range.location == 0 && string == " " { // prevent space on first character
                   return false
               }

               if textField.text?.last == " " && string == " " { // allowed only single space
                   return false
               }

               if string == " " { return true } // now allowing space between name

               if string.rangeOfCharacter(from: CharacterSet.letters.inverted) != nil {
                   return false
               }

               return true

            
        }else  if textField == txtPhoneNumber{
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if range.location > 10 - 1 {
              //  textField.text?.removeLast()
                return false
            }
            return string == numberFiltered
            }else{
            return true
        }
    }
}
