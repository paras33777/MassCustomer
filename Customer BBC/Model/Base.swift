//
//  RootClass.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 12, 2022
//
import Foundation

struct Base: Codable {

	let status: String?
	let msg: String?
	let result: Result?

	private enum CodingKeys: String, CodingKey {
		case status = "status"
		case msg = "msg"
		case result = "Result"
	   }

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		status = try values.decodeIfPresent(String.self, forKey: .status)
		msg = try values.decodeIfPresent(String.self, forKey: .msg)
		result = try values.decodeIfPresent(Result.self, forKey: .result)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(status, forKey: .status)
		try container.encode(msg, forKey: .msg)
		try container.encode(result, forKey: .result)
	}

}
