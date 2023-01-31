//
//  Dropdowns.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 20, 2022
//
import Foundation

struct Dropdowns: Codable {

	let mainCategory: [MainCategory]?
	let subCategory1: [SubCategory1]?
	let subCategory2: [SubCategory2]?

	private enum CodingKeys: String, CodingKey {
		case mainCategory = "mainCategory"
		case subCategory1 = "subCategory1"
		case subCategory2 = "subCategory2"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		mainCategory = try values.decodeIfPresent([MainCategory].self, forKey: .mainCategory)
		subCategory1 = try values.decodeIfPresent([SubCategory1].self, forKey: .subCategory1)
		subCategory2 = try values.decodeIfPresent([SubCategory2].self, forKey: .subCategory2)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(mainCategory, forKey: .mainCategory)
		try container.encode(subCategory1, forKey: .subCategory1)
		try container.encode(subCategory2, forKey: .subCategory2)
	}

}
