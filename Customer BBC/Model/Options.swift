//
//  Options.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on May 30, 2022
//
import Foundation

struct Options: Codable {

	let name: String?
	let type: String?
	let searchType: String?
	let dataType: String?
	let defaultField: String?
	let value: String?
    var selected:Bool?

	private enum CodingKeys: String, CodingKey {
		case name = "name"
		case type = "type"
		case searchType = "searchType"
		case dataType = "dataType"
		case defaultField = "default"
		case value = "value"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		type = try values.decodeIfPresent(String.self, forKey: .type)
		searchType = try values.decodeIfPresent(String.self, forKey: .searchType)
		dataType = try values.decodeIfPresent(String.self, forKey: .dataType)
		defaultField = try values.decodeIfPresent(String.self, forKey: .defaultField)
		value = try values.decodeIfPresent(String.self, forKey: .value)
        selected =  false
	}

}
