//
//  Productlist.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on May 06, 2022
//
import Foundation

struct Productlist: Codable {

	let ProductId: String?
    let driverName : String?
    let from_address : String?
    let to_address : String?
    let taxiNumber : String?
    let slotDate : String?
    let slotTime : String?
    let taxiId : String?
    let taxi_id : String?
    let driver_id : String?
	let ProductName: String?
	let MainCategory: String?
	let MAINCATEGORYID: String?
	let CHILDCATEGORYNAME: String?
	let CHILDCATEGORYID: String?
	let ProductImage: String?
	let ProductOfferPrice: String?
	let ProductPrice: String?
	let CostPrice: String?
	let ProductQuantity: String?
	let SKU: String?
	let ProductSHORTDESCRIPTION: String?
	let ProductDETAIL: String?
	let StoreName: String?
	let RetailerId: String?
	let StoreId: String?
	let storeType: String?
	let ProductMediumImage: String?
	let ProductIconImage: String?
    
    let cartId: String?
    let CurrencyType: String?
    let ProductTotalQuantity: String?
    let TotalPrice: String?
    let cartMainId: String?
    var itemUnits: String?
    var productType : String?
    
    let Package: String?
    let packageType : String?
    let HalfPrice: String?
    let FullPrice: String?
    let doctor_id : String?
    let room_id :  String?
    let doctorId : String?
    let roomId : String?
    let appointmentDate : String?
    let appointmentTime : String?
    let slot_id : String?
    let doctorName : String?
    let roomNumber : String?
    
    
    let package_price : String?
    let package_status : String?
    let package_quantity : String?
    let product_unit : String?
    
	private enum CodingKeys: String, CodingKey {
		case ProductId = "Product_id"
        case driverName = "driverName"
        case from_address = "from_address"
        case to_address = "to_address"
        case taxiNumber = "taxiNumber"
        case slotDate = "slotDate"
        case slotTime = "slotTime"
        case taxiId = "taxiId"
        case taxi_id = "taxi_id"
        case driver_id = "driver_id"
		case ProductName = "Product_Name"
		case MainCategory = "Main_Category"
		case MAINCATEGORYID = "MAIN_CATEGORY_ID"
		case CHILDCATEGORYNAME = "CHILD_CATEGORY_NAME"
		case CHILDCATEGORYID = "CHILD_CATEGORY_ID"
		case ProductImage = "Product_Image"
		case ProductOfferPrice = "Product_Offer_Price"
		case ProductPrice = "Product_Price"
		case CostPrice = "Cost_Price"
		case ProductQuantity = "Product_Quantity"
		case SKU = "SKU"
		case ProductSHORTDESCRIPTION = "Product_SHORT_DESCRIPTION"
		case ProductDETAIL = "Product_DETAIL"
		case StoreName = "Store_Name"
		case RetailerId = "Retailer_Id"
		case StoreId = "Store_Id"
		case storeType = "store_type"
		case ProductMediumImage = "Product_Medium_Image"
		case ProductIconImage = "Product_Icon_Image"
        
       
        case cartId = "cart_id"
        case TotalPrice = "Total_Price"
        case CurrencyType = "Currency_Type"
        case cartMainId = "cart_Main_id"
        case ProductTotalQuantity = "Product_Total_Quantity"
        case productType = "product_type"
        
      
        case Package = "package_type"
        case packageType = "packageType"
        case HalfPrice = "Half_Price"
        case FullPrice = "Full_Price"
          case doctor_id = "doctor_id"
       case room_id = "room_id"
        case doctorId = "doctorId"
        case roomId = "roomId"
        case appointmentDate = "appointmentDate"
        case appointmentTime = "appointmentTime"
       case slot_id = "slot_id"
        case doctorName = "doctorName"
        case roomNumber = "roomNumber"
        
        case package_status = "package_status"
        case package_price = "package_price"
        case package_quantity = "package_quantity"
        case product_unit = "product_unit"
        
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		ProductId = try values.decodeIfPresent(String.self, forKey: .ProductId)
        driverName = try values.decodeIfPresent(String.self, forKey: .driverName)
        from_address = try values.decodeIfPresent(String.self, forKey: .from_address)
        to_address = try values.decodeIfPresent(String.self, forKey: .to_address)
        taxiNumber = try values.decodeIfPresent(String.self, forKey: .taxiNumber)
        slotTime = try values.decodeIfPresent(String.self, forKey: .slotTime)
        slotDate = try values.decodeIfPresent(String.self, forKey: .slotDate)
        taxi_id = try values.decodeIfPresent(String.self, forKey: .taxi_id)
        taxiId = try values.decodeIfPresent(String.self, forKey: .taxiId)
        driver_id = try values.decodeIfPresent(String.self, forKey: .driver_id)
		ProductName = try values.decodeIfPresent(String.self, forKey: .ProductName)
		MainCategory = try values.decodeIfPresent(String.self, forKey: .MainCategory)
		MAINCATEGORYID = try values.decodeIfPresent(String.self, forKey: .MAINCATEGORYID)
		CHILDCATEGORYNAME = try values.decodeIfPresent(String.self, forKey: .CHILDCATEGORYNAME)
		CHILDCATEGORYID = try values.decodeIfPresent(String.self, forKey: .CHILDCATEGORYID)
		ProductImage = try values.decodeIfPresent(String.self, forKey: .ProductImage)
		ProductOfferPrice = try values.decodeIfPresent(String.self, forKey: .ProductOfferPrice)
		ProductPrice = try values.decodeIfPresent(String.self, forKey: .ProductPrice)
		CostPrice = try values.decodeIfPresent(String.self, forKey: .CostPrice)
		ProductQuantity = try values.decodeIfPresent(String.self, forKey: .ProductQuantity)
		SKU = try values.decodeIfPresent(String.self, forKey: .SKU)
		ProductSHORTDESCRIPTION = try values.decodeIfPresent(String.self, forKey: .ProductSHORTDESCRIPTION)
		ProductDETAIL = try values.decodeIfPresent(String.self, forKey: .ProductDETAIL)
		StoreName = try values.decodeIfPresent(String.self, forKey: .StoreName)
		RetailerId = try values.decodeIfPresent(String.self, forKey: .RetailerId)
		StoreId = try values.decodeIfPresent(String.self, forKey: .StoreId)
		storeType = try values.decodeIfPresent(String.self, forKey: .storeType)
		ProductMediumImage = try values.decodeIfPresent(String.self, forKey: .ProductMediumImage)
		ProductIconImage = try values.decodeIfPresent(String.self, forKey: .ProductIconImage)
        
        cartId  = try values.decodeIfPresent(String.self, forKey: .cartId)
        CurrencyType = try values.decodeIfPresent(String.self, forKey: .CurrencyType)
        ProductTotalQuantity = try values.decodeIfPresent(String.self, forKey: .ProductTotalQuantity)
        do {
             let totalPriceInt = try values.decodeIfPresent(Int.self, forKey: .TotalPrice) ?? 0
            TotalPrice = String(totalPriceInt )
         } catch DecodingError.typeMismatch {
             TotalPrice = try values.decodeIfPresent(String.self, forKey: .TotalPrice) ?? ""
         }
        cartMainId = try values.decodeIfPresent(String.self, forKey: .cartMainId)
        if cartId != nil{
        itemUnits = ProductQuantity
        }
        productType = try values.decodeIfPresent(String.self, forKey: .productType)
        
        Package = try values.decodeIfPresent(String.self, forKey: .Package)
        packageType = try values.decodeIfPresent(String.self, forKey: .packageType)
        HalfPrice = try values.decodeIfPresent(String.self, forKey: .HalfPrice)
        FullPrice = try values.decodeIfPresent(String.self, forKey: .FullPrice)
        doctor_id = try values.decodeIfPresent(String.self, forKey: .doctor_id)
        room_id = try values.decodeIfPresent(String.self, forKey: .room_id)
        doctorId = try values.decodeIfPresent(String.self, forKey: .doctorId)
        roomId = try values.decodeIfPresent(String.self, forKey: .roomId)
        appointmentDate = try values.decodeIfPresent(String.self, forKey: .appointmentDate)
        appointmentTime = try values.decodeIfPresent(String.self, forKey: .appointmentTime)
        slot_id = try values.decodeIfPresent(String.self, forKey: .slot_id)
        doctorName = try values.decodeIfPresent(String.self, forKey: .doctorName)
        roomNumber = try values.decodeIfPresent(String.self, forKey: .roomNumber)
        
        package_status = try values.decodeIfPresent(String.self, forKey: .package_status)
        package_price = try values.decodeIfPresent(String.self, forKey: .package_price)
        package_quantity = try values.decodeIfPresent(String.self, forKey: .package_quantity)
        product_unit = try values.decodeIfPresent(String.self, forKey: .product_unit)
	}
}
