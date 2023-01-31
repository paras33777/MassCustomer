//
//  OrderList.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 20, 2022
//

import Foundation

struct OrderList: Codable {

    let orderId: String?
    let totalAmount: String?
    let paymentMethod: String?
    let transactionId: String?
    let orderdate: String?
    let orderTime: String?
    let unit: String?
    let storeType: String?
    let storePaymentType: String?
    let category: String?
    let Products: String?
    let storeName: String?
    let retailerName: String?
    let userName: String?
    let userMobile: String?
    let status: String?
    let timestamp: String?
    let storeId: String?
    let reason: String?
    let currency: String?
    let currencySymbol: String?
    let order_type: String?
    let order_batch_id : String
    let product_type : String
    private enum CodingKeys: String, CodingKey {
        case orderId = "orderId"
        case totalAmount = "totalAmount"
        case paymentMethod = "paymentMethod"
        case transactionId = "transaction_id"
        case orderdate = "orderdate"
        case orderTime = "orderTime"
        case unit = "unit"
        case storeType = "storeType"
        case storePaymentType = "storePaymentType"
        case category = "category"
        case Products = "Products"
        case storeName = "storeName"
        case retailerName = "retailerName"
        case userName = "userName"
        case userMobile = "userMobile"
        case status = "status"
        case timestamp = "timestamp"
        case storeId = "storeId"
        case reason = "reason"
        case order_type
        case order_batch_id = "order_batch_id"
        case product_type = "product_type"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        orderId = try values.decodeIfPresent(String.self, forKey: .orderId)
        totalAmount = try values.decodeIfPresent(String.self, forKey: .totalAmount)
        paymentMethod = try values.decodeIfPresent(String.self, forKey: .paymentMethod)
        transactionId = try values.decodeIfPresent(String.self, forKey: .transactionId)
        orderdate = try values.decodeIfPresent(String.self, forKey: .orderdate)
        orderTime = try values.decodeIfPresent(String.self, forKey: .orderTime)
        do {
            let unitInt = try values.decodeIfPresent(Int.self, forKey: .unit) ?? 0
            unit = String(unitInt )
        } catch DecodingError.typeMismatch {
            unit = try values.decodeIfPresent(String.self, forKey: .unit) ?? ""
        }
        storeType = try values.decodeIfPresent(String.self, forKey: .storeType)
        storePaymentType = try values.decodeIfPresent(String.self, forKey: .storePaymentType)
        category = try values.decodeIfPresent(String.self, forKey: .category)
        Products = try values.decodeIfPresent(String.self, forKey: .Products)
        let name =  try values.decodeIfPresent(String.self, forKey: .storeName)
        currency = extarctCurrency(str: name ?? "", type: "currency")
        currencySymbol = getSymbol(forCurrencyCode: currency ?? "INR")
        storeName = extarctCurrency(str: name ?? "", type: "name")
        retailerName = try values.decodeIfPresent(String.self, forKey: .retailerName)
        product_type = try values.decodeIfPresent(String.self, forKey: .product_type) ?? ""
        userName = try values.decodeIfPresent(String.self, forKey: .userName)
        userMobile = try values.decodeIfPresent(String.self, forKey: .userMobile)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        timestamp = try values.decodeIfPresent(String.self, forKey: .timestamp)
        reason = try values.decodeIfPresent(String.self, forKey: .reason)
        storeId = try values.decodeIfPresent(String.self, forKey: .storeId)
        order_type = try values.decodeIfPresent(String.self, forKey: .order_type)
        order_batch_id = try values.decodeIfPresent(String.self, forKey: .order_batch_id) ?? ""
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
                return string.joined(separator: " ")
            }
        }
    }

   

}
