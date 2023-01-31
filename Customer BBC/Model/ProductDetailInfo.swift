//
//  ProductDetailInfo.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 26/12/22.
//

import Foundation
struct ProductDetail:Codable{
    let taxList : [TaxList]?
    
    let productIconImage : String?
        let productMediumImage : String?
        let childCategoryName : String?
        let createTime : String?
        let currencyType : String?
        let fkChildCategoryId : String?
        let fkGrandChildCategoryId : String?
        let fkMainCategoryId : String?
        let grandChildCategoryName : String?
        let mainCategoryName : String?
        let packageFlag : String?
        let packageId : String?
        let packagePrice : String?
        let packageQuantity : String?
        let productCostPrice : String?
        let productDescription : String?
        let productId : String?
        let productImage : String?
        let productName : String?
        let productOfferPrice : String?
        let productQrCode : String?
        let productQuantity : String?
        let productStandardPrice : String?
        let productStatus : String?
        let productUnit : String?
        let retailerId : String?
        let serviceGroup : String?
        let storeName : String?
        let storeType : String?
      //  let taxList : [String]?
        let unitId : String?

    let unit_priority : String?
    let unit_class : String?
    
    
    
        enum CodingKeys: String, CodingKey {
            case productIconImage = "Product_Icon_Image"
            case productMediumImage = "Product_Medium_Image"
            case childCategoryName = "child_category_name"
            case createTime = "create_time"
            case currencyType = "currency_type"
            case fkChildCategoryId = "fk_child_category_id"
            case fkGrandChildCategoryId = "fk_grand_child_category_id"
            case fkMainCategoryId = "fk_main_category_id"
            case grandChildCategoryName = "grand_child_category_name"
            case mainCategoryName = "main_category_name"
            case packageFlag = "package_flag"
            case packageId = "package_id"
            case packagePrice = "package_price"
            case packageQuantity = "package_quantity"
            case productCostPrice = "product_cost_price"
            case productDescription = "product_description"
            case productId = "product_id"
            case productImage = "product_image"
            case productName = "product_name"
            case productOfferPrice = "product_offer_price"
            case productQrCode = "product_qr_code"
            case productQuantity = "product_quantity"
            case productStandardPrice = "product_standard_price"
            case productStatus = "product_status"
            case productUnit = "product_unit"
            case retailerId = "retailer_id"
            case serviceGroup = "service_group"
            case storeName = "store_name"
            case storeType = "store_type"
            case taxList = "taxList"
            case unitId = "unit_id"
            case unit_priority = "unit_priority"
            
            case unit_class = "unit_class"
            
        }
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            productIconImage = try values.decodeIfPresent(String.self, forKey: .productIconImage)
            productMediumImage = try values.decodeIfPresent(String.self, forKey: .productMediumImage)
            childCategoryName = try values.decodeIfPresent(String.self, forKey: .childCategoryName)
            createTime = try values.decodeIfPresent(String.self, forKey: .createTime)
            currencyType = try values.decodeIfPresent(String.self, forKey: .currencyType)
            fkChildCategoryId = try values.decodeIfPresent(String.self, forKey: .fkChildCategoryId)
            fkGrandChildCategoryId = try values.decodeIfPresent(String.self, forKey: .fkGrandChildCategoryId)
            fkMainCategoryId = try values.decodeIfPresent(String.self, forKey: .fkMainCategoryId)
            grandChildCategoryName = try values.decodeIfPresent(String.self, forKey: .grandChildCategoryName)
            mainCategoryName = try values.decodeIfPresent(String.self, forKey: .mainCategoryName)
            packageFlag = try values.decodeIfPresent(String.self, forKey: .packageFlag)
            packageId = try values.decodeIfPresent(String.self, forKey: .packageId)
            packagePrice = try values.decodeIfPresent(String.self, forKey: .packagePrice)
            packageQuantity = try values.decodeIfPresent(String.self, forKey: .packageQuantity)
            productCostPrice = try values.decodeIfPresent(String.self, forKey: .productCostPrice)
            productDescription = try values.decodeIfPresent(String.self, forKey: .productDescription)
            productId = try values.decodeIfPresent(String.self, forKey: .productId)
            productImage = try values.decodeIfPresent(String.self, forKey: .productImage)
            productName = try values.decodeIfPresent(String.self, forKey: .productName)
            productOfferPrice = try values.decodeIfPresent(String.self, forKey: .productOfferPrice)
            productQrCode = try values.decodeIfPresent(String.self, forKey: .productQrCode)
            productQuantity = try values.decodeIfPresent(String.self, forKey: .productQuantity)
            productStandardPrice = try values.decodeIfPresent(String.self, forKey: .productStandardPrice)
            productStatus = try values.decodeIfPresent(String.self, forKey: .productStatus)
            productUnit = try values.decodeIfPresent(String.self, forKey: .productUnit)
            retailerId = try values.decodeIfPresent(String.self, forKey: .retailerId)
            serviceGroup = try values.decodeIfPresent(String.self, forKey: .serviceGroup)
            storeName = try values.decodeIfPresent(String.self, forKey: .storeName)
            storeType = try values.decodeIfPresent(String.self, forKey: .storeType)
            taxList = try values.decodeIfPresent([TaxList].self, forKey: .taxList)
            unitId = try values.decodeIfPresent(String.self, forKey: .unitId)
            unit_priority = try values.decodeIfPresent(String.self, forKey: .unit_priority)
            
            unit_class = try values.decodeIfPresent(String.self, forKey: .unit_class)
        }

}
struct TaxList:Codable{
    var TAX_TYPE:String?
    var TAX_ID:String?
    var NAME:String?
    var PERCENTAGE:String?
    
    private enum CodingKeys: String, CodingKey {
        case TAX_TYPE = "TAX_TYPE"
        case TAX_ID = "TAX_ID"
        case NAME = "NAME"
        case PERCENTAGE = "PERCENTAGE"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        TAX_TYPE = try values.decodeIfPresent(String.self, forKey: .TAX_TYPE)
        TAX_ID = try values.decodeIfPresent(String.self, forKey: .TAX_ID)
        NAME = try values.decodeIfPresent(String.self, forKey: .NAME)
        PERCENTAGE = try values.decodeIfPresent(String.self, forKey: .PERCENTAGE)
      
    }
    
    
}
