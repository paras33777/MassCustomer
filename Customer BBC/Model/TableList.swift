//
//  TableList.swift
//  Customer BBC
//
//  Created by Lakshay on 03/11/22.
//

import Foundation


struct TRCListData: Codable {

    let id: String?
    let title: String?
    let location: String?
    let barcode: String?
    let floor : String?
    let number : String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case location = "location"
        case barcode = "barcode"
        case floor = "floor"
        case number = "number"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        location = try values.decodeIfPresent(String.self, forKey: .location)
        barcode = try values.decodeIfPresent(String.self, forKey: .barcode)
        floor = try values.decodeIfPresent(String.self, forKey: .floor)
        number = try values.decodeIfPresent(String.self, forKey: .number)
    }

   

}


