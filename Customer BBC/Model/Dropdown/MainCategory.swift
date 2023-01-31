//
//  MainCategory.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 20, 2022
//
import Foundation

class MainCategory : DropDownModel {

       required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
                let values = try decoder.container(keyedBy: CodingKeys.self)
           mainId = try values.decodeIfPresent(String.self, forKey: .mainId)
           name = try values.decodeIfPresent(String.self, forKey: .name)
           dbname = try values.decodeIfPresent(String.self, forKey: .dbname)
        }

}
