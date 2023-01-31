//
//  StoreList.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on May 20, 2022
//
import Foundation

struct StoreList: Codable {

	let storeId: String?
	let storeName: String?
	let storeImageSmal: String?
	let location: String?
	let timeStamp: String?
	let storeType: String?
	let category: String?
	let paymentMethod: String?
	let statusComment: String?

	private enum CodingKeys: String, CodingKey {
		case storeId = "storeId"
		case storeName = "storeName"
		case storeImageSmal = "storeImageSmal"
		case location = "location"
		case timeStamp = "timeStamp"
		case storeType = "storeType"
		case category = "category"
		case paymentMethod = "paymentMethod"
		case statusComment = "statusComment"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		storeId = try values.decodeIfPresent(String.self, forKey: .storeId)
		let name = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
        storeName =  try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""//extarctCurrency(str: name, type: "name")
		storeImageSmal = try values.decodeIfPresent(String.self, forKey: .storeImageSmal)
		location = try values.decodeIfPresent(String.self, forKey: .location)
		timeStamp = try values.decodeIfPresent(String.self, forKey: .timeStamp)
		storeType = try values.decodeIfPresent(String.self, forKey: .storeType)
		category = try values.decodeIfPresent(String.self, forKey: .category)
		paymentMethod = try values.decodeIfPresent(String.self, forKey: .paymentMethod)
		statusComment = try values.decodeIfPresent(String.self, forKey: .statusComment)
        
        func getSymbol(forCurrencyCode code: String) -> String? {
            let locale = NSLocale(localeIdentifier: code)
            if locale.displayName(forKey: .currencySymbol, value: code) == code {
                let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
                return newlocale.displayName(forKey: .currencySymbol, value: code)
            }
            return locale.displayName(forKey: .currencySymbol, value: code)
        }
        
        func extarctCurrency(str :String ,type:String) -> String{
            var string = str.components(separatedBy: " ")
            if type == "currency"{
                let currency = string.last
                return currency ?? ""
            }else{
                let name = string.removeLast()
                return string.joined()
            }
        }
	}

	
}
