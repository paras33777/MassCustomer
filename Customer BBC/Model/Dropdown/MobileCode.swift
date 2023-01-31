//
//  MobileCode.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on August 2, 2019

import Foundation

class MobileCode : DropDownModel {

       required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
                let values = try decoder.container(keyedBy: CodingKeys.self)
                name = try values.decodeIfPresent(String.self, forKey: .name)
        }

}
