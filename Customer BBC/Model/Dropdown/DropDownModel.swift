//
//  DropDownModel.swift
//  BBC Retail
//
//  Created by Prashant Kumar on 14/04/22.
//

import Foundation
import UIKit
class DropDownModel: Codable,Equatable {
    static func == (lhs: DropDownModel, rhs: DropDownModel) -> Bool {
        return lhs.id == rhs.id
    }
    var id: String!
    var name: String!
    
    var mainId: String?
    var dbname: String?
    var FKMAINCATEGORYID: String?
    var FKCHILDCATEGORYID: String?
    var value: String?
    

     enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case mainId = "main_id"
        case dbname = "dbname"
        case FKMAINCATEGORYID = "FK_MAIN_CATEGORY_ID"
        case FKCHILDCATEGORYID = "FK_CHILD_CATEGORY_ID"
        case value = "value"
    }

    init(id: String,name: String) {
        self.id = id
        self.name = name
    }
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        name = try values.decodeIfPresent(String.self, forKey: .name)
//    }

//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(RetailerData, forKey: .RetailerData)
//    }

}
class ServiceGroup : DropDownModel {
     init(name: String) {
         super.init(id: "", name: name)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    static func getStaticServiceGroup() -> [DropDownModel] {
        
        let  serviceGroup = [
            ServiceGroup(name: "Product"),
            ServiceGroup(name: "Service")]
        return serviceGroup
      }
}
