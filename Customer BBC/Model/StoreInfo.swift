//
//  StoreInfo.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on May 11, 2022
//
import Foundation

struct StoreInfo: Codable {

	let storeId: String?
	let retailerId: String?
    let currency: String?
    let currencySymbol: String?
	let storeName: String?
	let storeImageSmal: String?
	let storeQrCode: String?
	let location: String?
	let retailerName: String?
	let address: String?
	let GSTIN: String?
    let inventory : String?
	let contactNumber: String?
	let access: String?
	let paymentMethod: String?
	let category: String?
	let services: String?
	let storeType: String?
	let COD: String?
	let googlepay: String?
    let AppointmentConfirmation : String?
    
    let settings:String?
    let phonepay:String?
    let paytm :String?
    let trcNumbers : String?
    let trcId : String?
    let trcStatus: String?
    let stripeStatus: String?
    
    let taxStatus:String?
    let taxType: String?
    
    
    
	private enum CodingKeys: String, CodingKey {
		case storeId = "storeId"
		case retailerId = "retailerId"
		case storeName = "storeName"
		case storeImageSmal = "storeImageSmal"
		case storeQrCode = "storeQrCode"
		case location = "location"
		case retailerName = "retailerName"
		case address = "address"
		case GSTIN = "GSTIN"
        case inventory = "inventory"
		case contactNumber = "contactNumber"
		case access = "access"
		case paymentMethod = "paymentMethod"
		case category = "category"
		case services = "services"
		case storeType = "storeType"
		case COD = "COD"
		case googlepay = "googlepay"
        
        case settings = "settings"
        case phonepay = "phonepay"
        case paytm = "paytm"
        case trcNumbers = "trcNumbers"
        case trcId = "trcId"
        case trcStatus = "trcStatus"
        case stripeStatus = "stripe_status"
        case taxStatus = "taxStatus"
        case taxType = "taxType"
        case AppointmentConfirmation = "AppointmentConfirmation"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		storeId = try values.decodeIfPresent(String.self, forKey: .storeId)
		retailerId = try values.decodeIfPresent(String.self, forKey: .retailerId)
        storeName =  try values.decodeIfPresent(String.self, forKey: .storeName)
        currency = extarctCurrency(str: storeName ?? "", type: "currency")
        currencySymbol = getSymbol(forCurrencyCode: currency ?? "INR")
        //storeName = extarctCurrency(str: name ?? "", type: "name")
		storeImageSmal = try values.decodeIfPresent(String.self, forKey: .storeImageSmal)
		storeQrCode = try values.decodeIfPresent(String.self, forKey: .storeQrCode)
		location = try values.decodeIfPresent(String.self, forKey: .location)
		retailerName = try values.decodeIfPresent(String.self, forKey: .retailerName)
		address = try values.decodeIfPresent(String.self, forKey: .address)
		GSTIN = try values.decodeIfPresent(String.self, forKey: .GSTIN)
        inventory = try values.decodeIfPresent(String.self, forKey: .inventory)
		contactNumber = try values.decodeIfPresent(String.self, forKey: .contactNumber)
		access = try values.decodeIfPresent(String.self, forKey: .access)
		paymentMethod = try values.decodeIfPresent(String.self, forKey: .paymentMethod)
		category = try values.decodeIfPresent(String.self, forKey: .category)
		services = try values.decodeIfPresent(String.self, forKey: .services)
		storeType = try values.decodeIfPresent(String.self, forKey: .storeType)
		COD = try values.decodeIfPresent(String.self, forKey: .COD)
		googlepay = try values.decodeIfPresent(String.self, forKey: .googlepay)
        AppointmentConfirmation = try values.decodeIfPresent(String.self, forKey: .AppointmentConfirmation)
        
        settings = try values.decodeIfPresent(String.self, forKey: .settings)
        phonepay = try values.decodeIfPresent(String.self, forKey: .phonepay)
        paytm = try values.decodeIfPresent(String.self, forKey: .paytm)
        trcNumbers = try values.decodeIfPresent(String.self, forKey: .trcNumbers)
        trcId = try values.decodeIfPresent(String.self, forKey: .trcId)
        trcStatus = try values.decodeIfPresent(String.self, forKey: .trcStatus)
        stripeStatus = try values.decodeIfPresent(String.self, forKey: .stripeStatus)
        taxType = try values.decodeIfPresent(String.self, forKey: .taxType)
        taxStatus = try values.decodeIfPresent(String.self, forKey: .taxStatus)
        
        
        
        func extarctCurrency(str :String ,type:String) -> String{
            var string = str.components(separatedBy: " ")
            if type == "currency"{
                let currency = string.last
                return currency ?? ""
            }else{
                let name = string.removeLast()
                return string.joined(separator: " ")
            }
        }
        
        func getSymbol(forCurrencyCode code: String) -> String? {
            
            let locale = NSLocale(localeIdentifier: code)
            if locale.displayName(forKey: .currencySymbol, value: code) == code {
                let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
                return newlocale.displayName(forKey: .currencySymbol, value: code)
            }
            return locale.displayName(forKey: .currencySymbol, value: code)
        }
        
	}

   
}
