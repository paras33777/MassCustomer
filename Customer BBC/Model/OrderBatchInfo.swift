//
//  OrderBatchInfo.swift
//  Customer BBC
//
//  Created by tecHangouts M1 on 17/10/22.
//

import Foundation
struct OrderBatchInfo: Codable {

    let orderId: String?
    let totalAmount: String?
    let paymentMethod: String?
    let paymentId: String?
    let orderdate: String?
    let paymentStatus: String?
    let invoiceLink: String?
    let reason: String?
    let subStatus:String?
    let cartMainId : String?
//    let productList: [Productlist]?
    let orderData : [OrderData]?
    private enum CodingKeys: String, CodingKey {
        case orderId = "orderId"
        case totalAmount = "totalAmount"
        case paymentMethod = "paymentMethod"
        case paymentId = "payment_id"
        case orderdate = "orderdate"
        case paymentStatus = "payment_status"
        case invoiceLink = "invoice_link"
        case orderData = "orderData"
//        case productList = "productlist"
        case cartMainId = "cart_main_id"
        case reason = "reason"
        case subStatus = "sub_status"
      }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        orderId = try values.decodeIfPresent(String.self, forKey: .orderId)
        do {
            let idInt = try values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0
            totalAmount = String(idInt )
        } catch DecodingError.typeMismatch {
            totalAmount = try values.decodeIfPresent(String.self, forKey: .totalAmount) ?? ""
        }
        paymentMethod = try values.decodeIfPresent(String.self, forKey: .paymentMethod)
        paymentId = try values.decodeIfPresent(String.self, forKey: .paymentId)
        orderdate = try values.decodeIfPresent(String.self, forKey: .orderdate)
        paymentStatus = try values.decodeIfPresent(String.self, forKey: .paymentStatus)
        invoiceLink = try values.decodeIfPresent(String.self, forKey: .invoiceLink)
//        productList = try values.decodeIfPresent([Productlist].self, forKey: .productList)
        cartMainId = try values.decodeIfPresent(String.self, forKey: .cartMainId)
        reason = try values.decodeIfPresent(String.self, forKey: .reason)
        subStatus = try values.decodeIfPresent(String.self, forKey: .subStatus)
        orderData = try values.decodeIfPresent([OrderData].self, forKey: .orderData)
    }
}
struct OrderData: Codable {

    let orderId: String?
    let totalAmount: String?
    let paymentMethod: String?
    let paymentId: String?
    let orderdate: String?
    let paymentStatus: String?
    let invoiceLink: String?
    let reason: String?
    let subStatus:String?
    let cartMainId : String?
    let orderInfo: OrderInfo?

    private enum CodingKeys: String, CodingKey {
        case orderId = "orderId"
        case totalAmount = "totalAmount"
        case paymentMethod = "paymentMethod"
        case paymentId = "payment_id"
        case orderdate = "orderdate"
        case paymentStatus = "payment_status"
        case invoiceLink = "invoice_link"
        case orderInfo = "orderInfo"
        case cartMainId = "cart_main_id"
        case reason = "reason"
        case subStatus = "sub_status"
      }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        orderId = try values.decodeIfPresent(String.self, forKey: .orderId)
        do {
            let idInt = try values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0
            totalAmount = String(idInt )
        } catch DecodingError.typeMismatch {
            totalAmount = try values.decodeIfPresent(String.self, forKey: .totalAmount) ?? ""
        }
        paymentMethod = try values.decodeIfPresent(String.self, forKey: .paymentMethod)
        paymentId = try values.decodeIfPresent(String.self, forKey: .paymentId)
        orderdate = try values.decodeIfPresent(String.self, forKey: .orderdate)
        paymentStatus = try values.decodeIfPresent(String.self, forKey: .paymentStatus)
        invoiceLink = try values.decodeIfPresent(String.self, forKey: .invoiceLink)
        orderInfo = try values.decodeIfPresent(OrderInfo.self, forKey: .orderInfo)
        cartMainId = try values.decodeIfPresent(String.self, forKey: .cartMainId)
        reason = try values.decodeIfPresent(String.self, forKey: .reason)
        subStatus = try values.decodeIfPresent(String.self, forKey: .subStatus)
    }
}
