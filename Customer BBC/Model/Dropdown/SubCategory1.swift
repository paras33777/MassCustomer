//
//  SubCategory1.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 20, 2022
//
import Foundation

class SubCategory1 : DropDownModel {

       required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
                let values = try decoder.container(keyedBy: CodingKeys.self)
           FKMAINCATEGORYID = try values.decodeIfPresent(String.self, forKey: .FKMAINCATEGORYID)
           FKCHILDCATEGORYID = try values.decodeIfPresent(String.self, forKey: .FKCHILDCATEGORYID)
           name = try values.decodeIfPresent(String.self, forKey: .name)
           value = try values.decodeIfPresent(String.self, forKey: .value)
        }

}
