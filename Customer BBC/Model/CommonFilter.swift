//
//  CommonFilter.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on May 30, 2022
//
import Foundation

struct CommonFilter: Codable {

	let name: String?
	let returnTypeParm: String?
	let filtertype: String?
	var returnValue: String?
    var returnValueArray: [String]?
	let Returntype: String?
    var filled : Bool!
	var options: [Options]?
   // selectedIds.map(String.init).joined(separator: ",")

	private enum CodingKeys: String, CodingKey {
		case name = "name"
		case returnTypeParm = "returnTypeParm"
		case filtertype = "filtertype"
		case returnValue = "returnValue"
		case Returntype = "Returntype"
		case options = "options"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		returnTypeParm = try values.decodeIfPresent(String.self, forKey: .returnTypeParm)
		filtertype = try values.decodeIfPresent(String.self, forKey: .filtertype)
		returnValue = try values.decodeIfPresent(String.self, forKey: .returnValue)
		Returntype = try values.decodeIfPresent(String.self, forKey: .Returntype)
		options = try values.decodeIfPresent([Options].self, forKey: .options)
        filled = false
        returnValueArray = [String]()
	}

	

}
