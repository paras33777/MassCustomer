//
//  StripeKeyInfo.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 05/12/22.
//

import Foundation
struct StripeKeyInfo : Codable {

    let pUBLISHKEYBELGIUM : String?
        let pUBLISHKEYUK : String?
        let sECRETKEYBELGIUM : String?
        let sECRETKEYUK : String?


        enum CodingKeys: String, CodingKey {
            case pUBLISHKEYBELGIUM = "PUBLISH_KEY_BELGIUM"
            case pUBLISHKEYUK = "PUBLISH_KEY_UK"
            case sECRETKEYBELGIUM = "SECRET_KEY_BELGIUM"
            case sECRETKEYUK = "SECRET_KEY_UK"
        }
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            pUBLISHKEYBELGIUM = try values.decodeIfPresent(String.self, forKey: .pUBLISHKEYBELGIUM)
            pUBLISHKEYUK = try values.decodeIfPresent(String.self, forKey: .pUBLISHKEYUK)
            sECRETKEYBELGIUM = try values.decodeIfPresent(String.self, forKey: .sECRETKEYBELGIUM)
            sECRETKEYUK = try values.decodeIfPresent(String.self, forKey: .sECRETKEYUK)
        }


    }
