//
//  Cartinfo.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on May 10, 2022
//
import Foundation

struct Cartinfo: Codable {

	var totalQty: String!
	var totalAmount: String!
    var totalTax:String!
    var GrandTotal:String!
    var cartSize : String!

	private enum CodingKeys: String, CodingKey {
		case totalQty = "totalQty"
		case totalAmount = "totalAmount"
        case totalTax = "totalTax"
        case GrandTotal = "GrandTotal"
        case cartSize = "cartSize"
	}
     init(totalQty:String) {
        self.totalQty = totalQty
        
    }
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
             let qtyInt = try values.decodeIfPresent(Int.self, forKey: .totalQty) ?? 0
            totalQty = String(qtyInt )
         } catch DecodingError.typeMismatch {
             totalQty = try values.decodeIfPresent(String.self, forKey: .totalQty) ?? ""
         }
        do {
             let amountInt = try values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0
            totalAmount = String(amountInt )
         } catch DecodingError.typeMismatch {
             totalAmount = try values.decodeIfPresent(String.self, forKey: .totalAmount) ?? ""
         }
        do {
             let taxInt = try values.decodeIfPresent(Int.self, forKey: .totalTax) ?? 0
            totalTax = String(taxInt )
         } catch DecodingError.typeMismatch {
             totalTax = try values.decodeIfPresent(String.self, forKey: .totalTax) ?? ""
         }
        do {
             let grandTotalInt = try values.decodeIfPresent(Int.self, forKey: .GrandTotal) ?? 0
            GrandTotal = String(grandTotalInt )
         } catch DecodingError.typeMismatch {
             GrandTotal = try values.decodeIfPresent(String.self, forKey: .GrandTotal) ?? ""
         }
        
        
        do {
             let cartSizeInt = try values.decodeIfPresent(Int.self, forKey: .cartSize) ?? 0
            cartSize = String(cartSizeInt )
         } catch DecodingError.typeMismatch {
             cartSize = try values.decodeIfPresent(String.self, forKey: .cartSize) ?? ""
         }
	}

}
