//
//  TaxData.swift
//  Customer BBC
//
//  Created by Newforce MAC on 08/12/22.
//

import Foundation

struct TaxData:Codable{
    var taxName:String?
    var taxPercentage:String?
    var taxPrice:String?
    var taxType: String?
    
    private enum CodingKeys: String, CodingKey {
        case taxName = "taxName"
        case taxPercentage = "taxPercentage"
        case taxPrice = "taxPrice"
        case taxType = "taxType"
      }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        taxName = try values.decodeIfPresent(String.self, forKey: .taxName)
        do {
            let taxPriceInt = try values.decodeIfPresent(Int.self, forKey: .taxPrice) ?? 0
            taxPrice = String(taxPriceInt )
        } catch DecodingError.typeMismatch {
            taxPrice = try values.decodeIfPresent(String.self, forKey: .taxPrice) ?? ""
        }
        do {
            let taxPercentageInt = try values.decodeIfPresent(Int.self, forKey: .taxPercentage) ?? 0
            taxPercentage = String(taxPercentageInt )
        } catch DecodingError.typeMismatch {
            taxPercentage = try values.decodeIfPresent(String.self, forKey: .taxPercentage) ?? ""
        }
        taxType = try values.decodeIfPresent(String.self, forKey: .taxType)
    }
}

