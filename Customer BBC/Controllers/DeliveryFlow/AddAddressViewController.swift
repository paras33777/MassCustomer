//
//  AddAddressViewController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 14/11/22.
//

import UIKit
import CoreLocation
import FTIndicator
import PhoneNumberKit

class AddAddressViewController: UIViewController,CLLocationManagerDelegate,UITextFieldDelegate {
    
    //    MARK: - OUTLETS
    @IBOutlet weak var textFieldPincode: SkyFloatingLabelTextField!
    @IBOutlet weak var buttonDefault: UIButton!
    @IBOutlet weak var textFieldCountry: SkyFloatingLabelTextField!
    @IBOutlet weak var textFieldState: SkyFloatingLabelTextField!
    @IBOutlet weak var textFieldTown: SkyFloatingLabelTextField!
    @IBOutlet weak var textFieldLandMark: SkyFloatingLabelTextField!
    @IBOutlet weak var textFieldArea: SkyFloatingLabelTextField!
    @IBOutlet weak var textFieldFlatNo: SkyFloatingLabelTextField!
    @IBOutlet weak var textFieldMobile: SkyFloatingLabelTextField!
    @IBOutlet weak var textFieldCountryCode: SkyFloatingLabelTextField!
    @IBOutlet weak var textFieldName: SkyFloatingLabelTextField!
    @IBOutlet weak var buttonSave: UIButton!
    
    //    MARK: - VARIBLES
    let locationManager = CLLocationManager()
    var lat:Double? = nil
    var long:Double? = nil
    var countryCode = ""
    var defaultaddress = ""
    var number = ""
    var addressList = [AddressListData]()
    var come = ""
    var indexId:Int? = nil
    
//    MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.come == "edit"{
            self.textFieldCountry.text = self.addressList[self.indexId ?? 0].deliveryCountry ?? ""
            self.textFieldLandMark.text = self.addressList[self.indexId!].deliveryLandmark ?? ""
            self.textFieldPincode.text = self.addressList[self.indexId!].deliveryPincode ?? ""
            self.textFieldArea.text = self.addressList[self.indexId!].deliveryArea ?? ""
            self.textFieldFlatNo.text = self.addressList[self.indexId!].deliveryHouseNo ?? ""
            self.textFieldTown.text = self.addressList[self.indexId!].deliveryCity ?? ""
            self.textFieldState.text = self.addressList[self.indexId!].deliveryState ?? ""
            self.textFieldCountryCode.text = " + \(self.addressList[self.indexId!].deliveryCountryCode ?? "")"
            self.textFieldName.text = self.addressList[self.indexId!].deliveryName ?? ""
            self.textFieldMobile.text = self.addressList[self.indexId!].deliveryPhoneNumber ?? ""
            if self.addressList[self.indexId!].deliveryPhoneNumber ?? "" == "0"{
                self.buttonDefault.isSelected = false
                self.defaultaddress = "0"
            }else{
                self.buttonDefault.isSelected = true
                self.defaultaddress = "1"
            }
            self.lat = Double(self.addressList[self.indexId ?? 0].lat ?? "")
            self.long = Double(self.addressList[self.indexId ?? 0].longitude ?? "")
            self.buttonSave.setTitle("Update Address", for: .normal)
        }else{
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
            self.buttonSave.setTitle("Save Address", for: .normal)
        }
        self.textFieldMobile.delegate = self
    }
    
    //    MARK: - LOACTION UPDATE DELEGATES
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.getAddressFromLatLon(pdblLatitude: "\(locValue.latitude)", withLongitude: "\(locValue.longitude)")
        self.lat = locValue.latitude
        self.long = locValue.longitude
    }
    
    //    MARK: - GET ALL ADDRESS FUNCTION
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        let lon: Double = Double("\(pdblLongitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                print(pm.country ?? "")
                print(pm.locality ?? "")
                print(pm.subLocality ?? "")
                print(pm.thoroughfare ?? "")
                print(pm.postalCode ?? "")
                print(pm.subThoroughfare ?? "")
                print(pm.administrativeArea ?? "")
                var addressString : String = ""
                if pm.subLocality != nil {
                    addressString = addressString + pm.subLocality! + ", "
                }
                if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare! + ", "
                }
                if pm.locality != nil {
                    addressString = addressString + pm.locality! + ", "
                }
                if pm.country != nil {
                    addressString = addressString + pm.country! + ", "
                }
                if pm.postalCode != nil {
                    addressString = addressString + pm.postalCode! + " "
                }
                
                self.textFieldCountry.text = pm.country ?? ""
                self.textFieldPincode.text = pm.postalCode ?? ""
                self.textFieldArea.text = pm.subLocality ?? ""
                self.textFieldFlatNo.text = pm.thoroughfare ?? ""
                self.textFieldTown.text = pm.locality
                self.textFieldState.text = pm.administrativeArea ?? ""
                self.textFieldCountryCode.text = "\(pm.isoCountryCode ?? "") +\(self.getCountryPhonceCode(pm.isoCountryCode ?? ""))"
                self.countryCode = pm.isoCountryCode ?? ""
                print(addressString)
            }
        })
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.textFieldMobile{
            self.phonenumber()
        }
        return true
    }
    
    
//    MARK: *************************TEXTFIELD VALIDATION*************************
    
    func ValidateAddressDetailsFields(){
    do {
           
        if self.come == "edit"{
            let dname = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldName.text!, fieldName: "delivery name")
            let ccode = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: self.textFieldCountryCode.text!, fieldName: "delivery country code")
            let mobile = try Validation.shared.validate(type: ValidationType.mobileNumber, inputValue: self.textFieldMobile.text!, fieldName: "mobile number")
            let pincode = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldPincode.text!, fieldName: "delivery pincode")
            let faltno = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldFlatNo.text!, fieldName: "delivery flatno")
            let area = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldArea.text!, fieldName: "area")
            let city = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldTown.text!, fieldName: "delivery city")
            let state = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldState.text!, fieldName: "delivery state")
            let country = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldCountry.text!, fieldName: "delivery country")
            let lat = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: "\(self.lat ?? 0.0)", fieldName: "lat")
            let long = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: "\(self.long ?? 0.0)", fieldName: "long")
            self.updateAddressAPI(user_id: Singleton.sharedInstance.userInfo.userId ?? "", id: self.addressList[self.indexId ?? 0].Id ?? "", deliveryName: dname, deliveryCountryCode: ccode, deliveryPhoneNumber: mobile, deliveryPincode: pincode, deliveryHouseNo: faltno, deliveryArea: area, deliveryCity: city, deliveryState: state, deliveryCountry: country, lat: lat, longitude: long)
        }else{
            let dname = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldName.text!, fieldName: "delivery name")
            let ccode = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: self.getCountryPhonceCode(self.countryCode), fieldName: "delivery country code")
            let mobile = try Validation.shared.validate(type: ValidationType.mobileNumber, inputValue: textFieldMobile.text!, fieldName: "mobile number")
            let pincode = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldPincode.text!, fieldName: "delivery pincode")
            let faltno = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldFlatNo.text!, fieldName: "delivery flatno")
            let area = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldArea.text!, fieldName: "area")
            let landmark = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldLandMark.text!, fieldName: "delivery landmark")
            let city = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldTown.text!, fieldName: "delivery city")
            let state = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldState.text!, fieldName: "delivery state")
            let country = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: textFieldCountry.text!, fieldName: "delivery country")
            let defaulttype = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: self.defaultaddress, fieldName: "default address")
            let lat = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: "\(self.lat ?? 0.0)", fieldName: "lat")
            let long = try Validation.shared.validate(type: ValidationType.isBlank, inputValue: "\(self.long ?? 0.0)", fieldName: "long")
            self.addAddressAPI(user_id: Singleton.sharedInstance.userInfo.userId ?? "", deliveryName: dname, deliveryCountryCode: ccode, deliveryPhoneNumber: mobile, deliveryPincode: pincode, deliveryHouseNo: faltno, deliveryArea: area, deliveryCity: city, deliveryState: state, deliveryCountry: country, defaultAddress: defaulttype, lat: lat, longitude: long)
        }
        }catch(let error) {
            let message = (error as! ValidationError).message
            FTIndicator.showToastMessage(message)
        }
    }
    
    
// MARK: - ********************ADD ADDRESS API********************
    
    func addAddressAPI(user_id:String,deliveryName: String,deliveryCountryCode: String,deliveryPhoneNumber: String,deliveryPincode: String,deliveryHouseNo: String,deliveryArea: String,deliveryCity: String,deliveryState: String,deliveryCountry:String,defaultAddress:String,lat:String, longitude:String){
        SKActivityIndicator.show()
        WebServiceManager.sharedInstance.addAddress(user_id: user_id, deliveryName: deliveryName, deliveryCountryCode: deliveryCountryCode, deliveryPhoneNumber: deliveryPhoneNumber, deliveryPincode: deliveryPincode, deliveryHouseNo: deliveryHouseNo, deliveryArea: deliveryArea, deliveryCity: deliveryCity, deliveryState: deliveryState, deliveryCountry: deliveryCountry, defaultAddress: defaultAddress, lat: lat, longitude: longitude){ msg, status in
            SKActivityIndicator.dismiss()
            if status == "1"{
                self.navigationController?.popViewController(animated: true)
                FTIndicator.showToastMessage(msg)
            }else{
                FTIndicator.showToastMessage(msg)
             }
          }
       }

// MARK: - ********************UPDATE ADDRESS API********************
    
    func updateAddressAPI(user_id:String,id:String,deliveryName: String,deliveryCountryCode: String,deliveryPhoneNumber: String,deliveryPincode: String,deliveryHouseNo: String,deliveryArea: String,deliveryCity: String,deliveryState: String,deliveryCountry:String,lat:String, longitude:String){
        SKActivityIndicator.show()
        WebServiceManager.sharedInstance.updateAddress(user_id: user_id, id: id, deliveryName: deliveryName, deliveryCountryCode: deliveryCountryCode, deliveryPhoneNumber: deliveryPhoneNumber, deliveryPincode: deliveryPincode, deliveryHouseNo: deliveryHouseNo, deliveryArea: deliveryArea, deliveryCity: deliveryCity, deliveryState: deliveryState, deliveryCountry: deliveryCountry,lat: lat, longitude: longitude){ addressList,msg, status in
            SKActivityIndicator.dismiss()
            if status == "1"{
                self.navigationController?.popViewController(animated: true)
                FTIndicator.showToastMessage(msg)
            }else{
                FTIndicator.showToastMessage(msg)
             }
          }
       }


    func phonenumber(){
        let phoneNumberKit = PhoneNumberKit()

        do {
            let phoneNumber = try phoneNumberKit.parse(self.textFieldMobile.text ?? "", withRegion: self.countryCode, ignoreType: false)
            let formatedNumber = phoneNumberKit.format(phoneNumber, toType: .national)
            print(formatedNumber)

        }
        catch {
            print("Generic parser error")
        }
    }
    
//    MARK: **************GET COUNTRY PHONE CODE *************************
    
    func getCountryPhonceCode (_ country : String) -> String{
        let countryDictionary  = ["AF":"93",
                                  "AL":"355",
                                  "DZ":"213",
                                  "AS":"1",
                                  "AD":"376",
                                  "AO":"244",
                                  "AI":"1",
                                  "AG":"1",
                                  "AR":"54",
                                  "AM":"374",
                                  "AW":"297",
                                  "AU":"61",
                                  "AT":"43",
                                  "AZ":"994",
                                  "BS":"1",
                                  "BH":"973",
                                  "BD":"880",
                                  "BB":"1",
                                  "BY":"375",
                                  "BE":"32",
                                  "BZ":"501",
                                  "BJ":"229",
                                  "BM":"1",
                                  "BT":"975",
                                  "BA":"387",
                                  "BW":"267",
                                  "BR":"55",
                                  "IO":"246",
                                  "BG":"359",
                                  "BF":"226",
                                  "BI":"257",
                                  "KH":"855",
                                  "CM":"237",
                                  "CA":"1",
                                  "CV":"238",
                                  "KY":"345",
                                  "CF":"236",
                                  "TD":"235",
                                  "CL":"56",
                                  "CN":"86",
                                  "CX":"61",
                                  "CO":"57",
                                  "KM":"269",
                                  "CG":"242",
                                  "CK":"682",
                                  "CR":"506",
                                  "HR":"385",
                                  "CU":"53",
                                  "CY":"537",
                                  "CZ":"420",
                                  "DK":"45",
                                  "DJ":"253",
                                  "DM":"1",
                                  "DO":"1",
                                  "EC":"593",
                                  "EG":"20",
                                  "SV":"503",
                                  "GQ":"240",
                                  "ER":"291",
                                  "EE":"372",
                                  "ET":"251",
                                  "FO":"298",
                                  "FJ":"679",
                                  "FI":"358",
                                  "FR":"33",
                                  "GF":"594",
                                  "PF":"689",
                                  "GA":"241",
                                  "GM":"220",
                                  "GE":"995",
                                  "DE":"49",
                                  "GH":"233",
                                  "GI":"350",
                                  "GR":"30",
                                  "GL":"299",
                                  "GD":"1",
                                  "GP":"590",
                                  "GU":"1",
                                  "GT":"502",
                                  "GN":"224",
                                  "GW":"245",
                                  "GY":"595",
                                  "HT":"509",
                                  "HN":"504",
                                  "HU":"36",
                                  "IS":"354",
                                  "IN":"91",
                                  "ID":"62",
                                  "IQ":"964",
                                  "IE":"353",
                                  "IL":"972",
                                  "IT":"39",
                                  "JM":"1",
                                  "JP":"81",
                                  "JO":"962",
                                  "KZ":"77",
                                  "KE":"254",
                                  "KI":"686",
                                  "KW":"965",
                                  "KG":"996",
                                  "LV":"371",
                                  "LB":"961",
                                  "LS":"266",
                                  "LR":"231",
                                  "LI":"423",
                                  "LT":"370",
                                  "LU":"352",
                                  "MG":"261",
                                  "MW":"265",
                                  "MY":"60",
                                  "MV":"960",
                                  "ML":"223",
                                  "MT":"356",
                                  "MH":"692",
                                  "MQ":"596",
                                  "MR":"222",
                                  "MU":"230",
                                  "YT":"262",
                                  "MX":"52",
                                  "MC":"377",
                                  "MN":"976",
                                  "ME":"382",
                                  "MS":"1",
                                  "MA":"212",
                                  "MM":"95",
                                  "NA":"264",
                                  "NR":"674",
                                  "NP":"977",
                                  "NL":"31",
                                  "AN":"599",
                                  "NC":"687",
                                  "NZ":"64",
                                  "NI":"505",
                                  "NE":"227",
                                  "NG":"234",
                                  "NU":"683",
                                  "NF":"672",
                                  "MP":"1",
                                  "NO":"47",
                                  "OM":"968",
                                  "PK":"92",
                                  "PW":"680",
                                  "PA":"507",
                                  "PG":"675",
                                  "PY":"595",
                                  "PE":"51",
                                  "PH":"63",
                                  "PL":"48",
                                  "PT":"351",
                                  "PR":"1",
                                  "QA":"974",
                                  "RO":"40",
                                  "RW":"250",
                                  "WS":"685",
                                  "SM":"378",
                                  "SA":"966",
                                  "SN":"221",
                                  "RS":"381",
                                  "SC":"248",
                                  "SL":"232",
                                  "SG":"65",
                                  "SK":"421",
                                  "SI":"386",
                                  "SB":"677",
                                  "ZA":"27",
                                  "GS":"500",
                                  "ES":"34",
                                  "LK":"94",
                                  "SD":"249",
                                  "SR":"597",
                                  "SZ":"268",
                                  "SE":"46",
                                  "CH":"41",
                                  "TJ":"992",
                                  "TH":"66",
                                  "TG":"228",
                                  "TK":"690",
                                  "TO":"676",
                                  "TT":"1",
                                  "TN":"216",
                                  "TR":"90",
                                  "TM":"993",
                                  "TC":"1",
                                  "TV":"688",
                                  "UG":"256",
                                  "UA":"380",
                                  "AE":"971",
                                  "GB":"44",
                                  "US":"1",
                                  "UY":"598",
                                  "UZ":"998",
                                  "VU":"678",
                                  "WF":"681",
                                  "YE":"967",
                                  "ZM":"260",
                                  "ZW":"263",
                                  "BO":"591",
                                  "BN":"673",
                                  "CC":"61",
                                  "CD":"243",
                                  "CI":"225",
                                  "FK":"500",
                                  "GG":"44",
                                  "VA":"379",
                                  "HK":"852",
                                  "IR":"98",
                                  "IM":"44",
                                  "JE":"44",
                                  "KP":"850",
                                  "KR":"82",
                                  "LA":"856",
                                  "LY":"218",
                                  "MO":"853",
                                  "MK":"389",
                                  "FM":"691",
                                  "MD":"373",
                                  "MZ":"258",
                                  "PS":"970",
                                  "PN":"872",
                                  "RE":"262",
                                  "RU":"7",
                                  "BL":"590",
                                  "SH":"290",
                                  "KN":"1",
                                  "LC":"1",
                                  "MF":"590",
                                  "PM":"508",
                                  "VC":"1",
                                  "ST":"239",
                                  "SO":"252",
                                  "SJ":"47",
                                  "SY":"963",
                                  "TW":"886",
                                  "TZ":"255",
                                  "TL":"670",
                                  "VE":"58",
                                  "VN":"84",
                                  "VG":"284",
                                  "VI":"340"]
            print(countryDictionary.count)
        if countryDictionary[country] != nil {
            return countryDictionary[country]!
        }
        
        else {
            return ""
        }
    }
   
    
//MARK: ****************UPDATE DELIVERY ADDRESS API**************************
    func updateDefaultAddressApi(user_id:String, addressId: String, defaultAddress: String){
        WebServiceManager.sharedInstance.updateDefaiultAddress(addressId: addressId, user_id: user_id, defaultAddress: defaultAddress){msg, status  in
            if status == "1"{
             print("Update successfully")
            }else{
                print("Not Update: ERROR")
            }
        }
    }
    
//    MARK: - BUTTON ACTION
    @IBAction func CurrentLoactionAction(_ sender: UIButton) {

            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.locationManager.delegate = self
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    self.locationManager.startUpdatingLocation()
                }
               
            }
}

    @IBAction func buttonDefaultAddressAction(_ sender: UIButton) {
        if self.come == "edit"{
            if self.buttonDefault.isSelected == false{
                self.buttonDefault.isSelected = true
                self.defaultaddress = "1"
                self.updateDefaultAddressApi(user_id: Singleton.sharedInstance.userInfo.userId ?? "", addressId: self.addressList[self.indexId!].Id ?? "", defaultAddress: self.defaultaddress)
            }else{
                self.buttonDefault.isSelected = false
                self.defaultaddress = "0"
                self.updateDefaultAddressApi(user_id: Singleton.sharedInstance.userInfo.userId ?? "", addressId: self.addressList[self.indexId!].Id ?? "", defaultAddress: self.defaultaddress)
            }
        }else{
            if self.buttonDefault.isSelected == false{
                self.buttonDefault.isSelected = true
                self.defaultaddress = "1"
            }else{
                self.buttonDefault.isSelected = false
                self.defaultaddress = "0"
            }
        }
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        self.ValidateAddressDetailsFields()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
