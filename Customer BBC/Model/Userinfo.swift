//
//  Userinfo.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on May 05, 2022
//
import Foundation

struct Userinfo: Codable {

	var userId: String?
    var firstname: String?
    var lastname: String?
    var city: String?
    var state: String?
    var country: String?
    var address: String?
    var zipcode: String?
    var email: String?
    var mobile  : String?
    var accessKey: String?
    var authToken: String?
    var slotTime : String?
    
    init(userId:String){
        self.userId = userId
    }
    
	private enum CodingKeys: String, CodingKey {
		case userId = "user_id"
		case firstname = "firstname"
		case lastname = "lastname"
		case city = "city"
		case state = "state"
		case country = "country"
		case address = "address"
		case zipcode = "zipcode"
		case email = "email"
        case mobile = "mobile"
        
        case accessKey = "access_key"
        case authToken = "auth_token"
        case slotTime = "slot_time"
        
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		userId = try values.decodeIfPresent(String.self, forKey: .userId)
		firstname = try values.decodeIfPresent(String.self, forKey: .firstname)
		lastname = try values.decodeIfPresent(String.self, forKey: .lastname)
		city = try values.decodeIfPresent(String.self, forKey: .city)
		state = try values.decodeIfPresent(String.self, forKey: .state)
		country = try values.decodeIfPresent(String.self, forKey: .country)
		address = try values.decodeIfPresent(String.self, forKey: .address)
		zipcode = try values.decodeIfPresent(String.self, forKey: .zipcode)
		email = try values.decodeIfPresent(String.self, forKey: .email)
        mobile = try values.decodeIfPresent(String.self, forKey: .mobile)
        
        accessKey = try values.decodeIfPresent(String.self, forKey: .accessKey)
        authToken = try values.decodeIfPresent(String.self, forKey: .authToken)
        slotTime = try values.decodeIfPresent(String.self, forKey: .slotTime)
	}

	
}
