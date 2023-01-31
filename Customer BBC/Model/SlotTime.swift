//
//  SlotTime.swift
//  Customer BBC
//
//  Created by Lakshay on 28/10/22.
//

import Foundation

struct SlotTimeData: Codable {

    
    let DocAvailSlot: [DocAvailSlotData]?
    let BookedSlot : [BookedSlotData]?
    let MyBookedSlot : [MyBookedSlotData]?

    private enum CodingKeys: String, CodingKey {
      
        case DocAvailSlot = "DocAvailSlot"
        case BookedSlot = "BookedSlot"
        case MyBookedSlot = "MyBookedSlot"
      
      }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        DocAvailSlot = try values.decodeIfPresent([DocAvailSlotData].self, forKey: .DocAvailSlot)
        BookedSlot = try values.decodeIfPresent([BookedSlotData].self, forKey: .BookedSlot)
        MyBookedSlot = try values.decodeIfPresent([MyBookedSlotData].self, forKey: .MyBookedSlot)
    }
}
struct DocAvailSlotData: Codable {

    
    let startTime: String?
    let endTime : String?
    let from_Date : String?
    let days : String?
    let slot_Type : String?
    private enum CodingKeys: String, CodingKey {
      
        case startTime = "srarTime"
      case endTime = "endTime"
        case from_Date = "from_Date"
        case days = "days"
        case slot_Type = "slot_Type"
      }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try values.decodeIfPresent(String.self, forKey: .startTime)
        endTime = try values.decodeIfPresent(String.self, forKey: .endTime)
        from_Date = try values.decodeIfPresent(String.self, forKey: .from_Date)
        days = try values.decodeIfPresent(String.self, forKey: .days)
        slot_Type = try values.decodeIfPresent(String.self, forKey: .slot_Type)
    }
}

struct BookedSlotData: Codable {

    
    let serviceName: String?
    let startTime : String?
    let endTime : String?
    let status : String?
    
    private enum CodingKeys: String, CodingKey {
      
        case serviceName = "serviceName"
        case startTime = "srarTime"
        case endTime = "endTime"
        case status = "status"
      
      }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        serviceName = try values.decodeIfPresent(String.self, forKey: .serviceName)
        startTime = try values.decodeIfPresent(String.self, forKey: .startTime)
        endTime = try values.decodeIfPresent(String.self, forKey: .endTime)
        status = try values.decodeIfPresent(String.self, forKey: .status)
       
    }
}


struct MyBookedSlotData: Codable {

    
    let serviceName: String?
    let startTime : String?
    let endTime : String?
    let status : String?
    private enum CodingKeys: String, CodingKey {
        case serviceName = "serviceName"
        case startTime = "srarTime"
        case endTime = "endTime"
        case status = "status"
      }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        serviceName = try values.decodeIfPresent(String.self, forKey: .serviceName)
        startTime = try values.decodeIfPresent(String.self, forKey: .startTime)
        endTime = try values.decodeIfPresent(String.self, forKey: .endTime)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }
}
