import Foundation
import PhoneNumberKit



class ValidationError: Error {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
}
enum ValidationType {
    case email
    case userName
    case emailPhone
    case phoneNo
    case password
    case passwordMatch
    case mobileNumber
    case mobileCountryValid
    case requiredField(field: String)
    case age
    case isBlank
    case CBPisBlank
    case isBlankSignature
    case isSelectBlank
    case uploadresume
    case skills
    case minSkill
    case selectAdmin
    case searchData
}

enum AlertMessages: String {
    case resume = "Please Upload Resume First"
    case skills = "Please Add Skills First"
    case empty = "Please enter "
    case CBPempty = "Please enter  "
    case emptySign = "Please draw your "
    case selectEmpty = "Please Select your "
    case inValidEmail = "Invalid Email"
    case invalidMobile = "Please enter valid "
    case invalidFirstLetterCaps = "First Letter should be capital"
    case inValidPhone = "Please enter valid mobile number"
    case userNameMin = "Username must contain more than three characters"
    case userNameMax = "Username shoudn't conain more than 18 characters"
    case invalidUserName = "Invalid username, username should not contain whitespaces,  or special characters"
    case invalidAlphabeticString = "Invalid String"
    case passwordNotMatch = "Password is not Matching"
    case inValidPSW = "Password contains minimum 8 characters at least 1 Alphabet and 1 Number"
    case minSkill = "Please Add Minimum 3 Skills First"
    case selectAdmin = "Please select admin ID"
    case searchData = "Please search for approval data at particular id first"
    
}

class Validation: NSObject {
    let phoneNumberKit = PhoneNumberKit()
    public static let shared = Validation()
    func validate(type: ValidationType, inputValue: String,fieldName:String)throws -> String{
        switch type{
        case .isBlank :
            if inputValue == "Select Option"{
                throw ValidationError(AlertMessages.empty.rawValue + fieldName)
            }else if inputValue.isEmpty{
                throw ValidationError(AlertMessages.empty.rawValue + fieldName)
            }else{
                return inputValue
            }
        case .searchData :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.searchData.rawValue)
            }else{
                return inputValue
            }
        case .CBPisBlank :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.CBPempty.rawValue + fieldName)
            }else{
                return inputValue
            }
        case .isBlankSignature :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.emptySign.rawValue + fieldName)
            }else{
                return inputValue
            }
        case .isSelectBlank :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.selectEmpty.rawValue + fieldName)
            }else{
                return inputValue
            }
        case .minSkill :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.minSkill.rawValue)
            }else{
                return inputValue
            }
        case .selectAdmin :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.selectAdmin.rawValue)
            }else{
                return inputValue
            }
        case .skills :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.skills.rawValue)
            }else{
                return inputValue
            }
        case .uploadresume :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.resume.rawValue)
            }else{
                return inputValue
            }
        case .emailPhone:
            let phoneNumberKit = PhoneNumberKit()
            let region = Locale.current.regionCode
            let Code =  phoneNumberKit.countryCode(for: region!)
            let intValue = NSNumber(value: Code!).intValue
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.empty.rawValue + fieldName)
            }else if inputValue.isNumeric{
                if inputValue.isPhoneNumber {
                    return  String(intValue) + inputValue//"+" +
                }else{
                    throw ValidationError(AlertMessages.inValidPhone.rawValue)
                }
            }else{
                do {
                    if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: inputValue, options: [], range: NSRange(location: 0, length: inputValue.count)) == nil {
                        throw ValidationError(AlertMessages.inValidEmail.rawValue)
                    }
                } catch {
                    throw ValidationError(AlertMessages.inValidEmail.rawValue)
                }
                return inputValue
            }
        case .email:
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.empty.rawValue + fieldName)
            }else{
                do {
                    if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: inputValue, options: [], range: NSRange(location: 0, length: inputValue.count)) == nil {
                        throw ValidationError(AlertMessages.inValidEmail.rawValue)
                    }
                } catch {
                    throw ValidationError(AlertMessages.inValidEmail.rawValue)
                }
            }
            return inputValue
        case .password :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.empty.rawValue + fieldName)
            }else{
                do {
                    if try NSRegularExpression(pattern: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@]{8,}$",  options: .caseInsensitive).firstMatch(in: inputValue, options: [], range: NSRange(location: 0, length: inputValue.count)) == nil {
                        throw ValidationError(AlertMessages.inValidPSW.rawValue)
                       }
                } catch {
                    throw ValidationError(AlertMessages.inValidPSW.rawValue)
                }
            }
            return inputValue
        case .mobileNumber :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.empty.rawValue + fieldName)
            }else if inputValue.isNumeric{
                if inputValue.isPhoneNumber {
                    return inputValue
                }else{
                    throw ValidationError(AlertMessages.inValidPhone.rawValue)
                }
            }else{
                do {
                    let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
                    let matches = detector.matches(in: inputValue, options: [], range: NSMakeRange(0, inputValue.count))
                    if let res = matches.first {
                        if res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == inputValue.count && inputValue.count == 10{
                            return inputValue
                        }
                    } else {
                        throw ValidationError(AlertMessages.inValidPhone.rawValue)
                    }
                } catch {
                    throw ValidationError(AlertMessages.inValidPhone.rawValue)
                }
                return inputValue
            }
        case .mobileCountryValid :
            if inputValue.isEmpty{
                throw ValidationError(AlertMessages.empty.rawValue + fieldName)
            }else {
                do {
                    let phone = try phoneNumberKit.parse(inputValue)
                    if !phone.numberString.isEmpty{
                        return inputValue
                    }else{
                        throw ValidationError(AlertMessages.invalidMobile.rawValue + fieldName)
                    }
                } catch {
                    throw ValidationError(AlertMessages.invalidMobile.rawValue + fieldName)
                }
            }
        case .userName :
            guard inputValue.count >= 3 else {
                throw ValidationError(AlertMessages.userNameMin.rawValue )
            }
            guard inputValue.count < 18 else {
                throw ValidationError(AlertMessages.userNameMax.rawValue)
            }
            
            do {
                if try NSRegularExpression(pattern: "^[a-z]{1,18}$",  options: .caseInsensitive).firstMatch(in: inputValue, options: [], range: NSRange(location: 0, length: inputValue.count)) == nil {
                    throw ValidationError(AlertMessages.invalidUserName.rawValue)
                }
            } catch {
                throw ValidationError(AlertMessages.invalidUserName.rawValue)
            }
            return inputValue
            
        default:
            return String()
        }
    }
    func compareValidate( inputValue1: String,inputValue2:String)throws -> String{
        guard inputValue1 == inputValue2 else {throw ValidationError(AlertMessages.passwordNotMatch.rawValue)}
        return inputValue1
    }
}

//MARK: ********************************************************************









