//
//  Result.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on April 12, 2022
//
import Foundation

struct Result: Codable {
    
    let cartSize: String?
    let id :String?
    let order_Id :String?
    let userId : String?
    let userinfo: Userinfo?
    let storeInfo: StoreInfo?
    let cartinfo: Cartinfo?
    let productlist: [Productlist]?
    let orderList: [OrderList]?
    let totalpage: Int?
    let totalPageCount: Int?
    let totalItemCount: Int?
    let orderInfo: OrderInfo?
    let storeList: [StoreList]?
    let commonFilter: [CommonFilter]?
    let orderBatchInfo : OrderBatchInfo?
    let SlotTime : SlotTimeData?
    let slot_id : String?
    let totalCount : Int?
    let TRCList : [TRCListData]?
    let stripeKeyInfo : StripeKeyInfo?
    let addressList : [AddressListData]?
    let productDetail : ProductDetail?
    
    private enum CodingKeys: String, CodingKey {

        case storeInfo = "storeInfo"
        case cartinfo = "cartinfo"
        case id = "id"
        case cartSize = "cartSize"
        case userId = "user_id"
        case userinfo = "userinfo"
        case productlist = "productlist"
        case orderList = "orderList"
        case totalpage = "totalpage"
        case totalPageCount = "totalPageCount"
        case totalItemCount = "totalItemCount"
        case orderInfo = "orderInfo"
        case order_Id = "order_Id"
        case storeList = "storeList"
        case commonFilter = "commonFilter"
        case orderBatchInfo = "orderBatchInfo"
        case SlotTime = "SlotTime"
        case slot_id = "slot_id"
        case totalCount = "totalCount"
        case TRCList = "TRCList"
        case stripeKeyInfo = "stripeKeyInfo"
        case addressList = "addressList"
        case productDetail = "productDetail"
        
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userinfo = try values.decodeIfPresent(Userinfo.self, forKey: .userinfo)
        cartSize = try values.decodeIfPresent(String.self, forKey: .cartSize)
       do {
            let idInt = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
            id = String(idInt )
        } catch DecodingError.typeMismatch {
            id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        }
        storeInfo = try values.decodeIfPresent(StoreInfo.self, forKey: .storeInfo)
        cartinfo = try values.decodeIfPresent(Cartinfo.self, forKey: .cartinfo)
        do {
             let idInt = try values.decodeIfPresent(Int.self, forKey: .userId) ?? 0
            userId = String(idInt )
         } catch DecodingError.typeMismatch {
             userId = try values.decodeIfPresent(String.self, forKey: .userId) ?? ""
         }
//      mobileCode = try values.decodeIfPresent([MobileCode].self, forKey: .mobileCode)
        totalpage = try values.decodeIfPresent(Int.self, forKey: .totalpage) ?? 0
        totalPageCount = try values.decodeIfPresent(Int.self, forKey: .totalPageCount) ?? 0
        totalItemCount = try values.decodeIfPresent(Int.self, forKey: .totalItemCount) ?? 0
//      orderList = try values.decodeIfPresent([OrderList].self, forKey: .orderList)
        productlist = try values.decodeIfPresent([Productlist].self, forKey: .productlist)
        orderList = try values.decodeIfPresent([OrderList].self, forKey: .orderList)
//      dropdowns = try values.decodeIfPresent(Dropdowns.self, forKey: .dropdowns)
        orderInfo = try values.decodeIfPresent(OrderInfo.self, forKey: .orderInfo)
        do {
             let orderID = try values.decodeIfPresent(Int.self, forKey: .order_Id) ?? 0
            order_Id = String(orderID )
         } catch DecodingError.typeMismatch {
             order_Id = try values.decodeIfPresent(String.self, forKey: .order_Id) ?? ""
         }
        storeList = try values.decodeIfPresent([StoreList].self, forKey: .storeList)
        commonFilter = try values.decodeIfPresent([CommonFilter].self, forKey: .commonFilter)
        
        orderBatchInfo = try values.decodeIfPresent(OrderBatchInfo.self, forKey: .orderBatchInfo)
        SlotTime = try values.decodeIfPresent(SlotTimeData.self, forKey: .SlotTime)
        slot_id = try values.decodeIfPresent(String.self, forKey: .slot_id) ?? ""
        totalCount = try values.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        TRCList = try values.decodeIfPresent([TRCListData].self, forKey: .TRCList)
        stripeKeyInfo = try values.decodeIfPresent(StripeKeyInfo.self, forKey: .stripeKeyInfo)
        addressList = try values.decodeIfPresent([AddressListData].self, forKey: .addressList)
        
        productDetail = try values.decodeIfPresent(ProductDetail.self, forKey: .productDetail)
      }
     }
