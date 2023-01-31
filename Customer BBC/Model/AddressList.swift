//
//  AddressList.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 14/11/22.
//

import Foundation

struct AddressListData: Codable {

    let Id: String?
    let deliveryName: String?
    let deliveryCountryCode: String?
    let deliveryPhoneNumber: String?
    let deliveryPincode : String?
    let deliveryHouseNo : String?
    let deliveryLandmark : String?
    let deliveryCity: String?
    let deliveryState: String?
    let deliveryCountry: String?
    let defaultAddress: String?
    let longitude: String?
    let deliveryArea:String?
    let lat: String?
    
    private enum CodingKeys: String, CodingKey {
        case Id = "Id"
        case deliveryName = "deliveryName"
        case deliveryCountryCode = "deliveryCountryCode"
        case deliveryPhoneNumber = "deliveryPhoneNumber"
        case deliveryPincode = "deliveryPincode"
        case deliveryHouseNo = "deliveryHouseNo"
        case deliveryLandmark = "deliveryLandmark"
        case deliveryCity = "deliveryCity"
        case deliveryState = "deliveryState"
        case deliveryCountry = "deliveryCountry"
        case defaultAddress = "defaultAddress"
        case longitude = "longitude"
        case lat = "lat"
        case deliveryArea = "deliveryArea"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        Id = try values.decodeIfPresent(String.self, forKey: .Id)
        deliveryName = try values.decodeIfPresent(String.self, forKey: .deliveryName)
        deliveryCountryCode = try values.decodeIfPresent(String.self, forKey: .deliveryCountryCode)
        deliveryPhoneNumber = try values.decodeIfPresent(String.self, forKey: .deliveryPhoneNumber)
        deliveryPincode = try values.decodeIfPresent(String.self, forKey: .deliveryPincode)
        deliveryHouseNo = try values.decodeIfPresent(String.self, forKey: .deliveryHouseNo)
        deliveryLandmark = try values.decodeIfPresent(String.self, forKey: .deliveryLandmark)
        deliveryCity = try values.decodeIfPresent(String.self, forKey: .deliveryCity)
        deliveryState = try values.decodeIfPresent(String.self, forKey: .deliveryState)
        deliveryCountry = try values.decodeIfPresent(String.self, forKey: .deliveryCountry)
        defaultAddress = try values.decodeIfPresent(String.self, forKey: .defaultAddress)
        longitude = try values.decodeIfPresent(String.self, forKey: .longitude)
        lat = try values.decodeIfPresent(String.self, forKey: .lat)
        deliveryArea = try values.decodeIfPresent(String.self, forKey: .deliveryArea)
    }

   

}


