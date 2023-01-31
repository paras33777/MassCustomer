//
//  Constants.swift
//  BBC Retail
//
//  Created by Prashant Kumar on 12/04/22.
//

import Foundation

struct EndPoint{
 fileprivate static let version = "/v9/"
// fileprivate static let baseURL = "https://customermw.maaserp.com"             // live
//fileprivate static let baseURL = "https://bbcuat.newforceltd.com"             //  UAT
 fileprivate static let baseURL = "https://bbccustomermw.newforceltd.com"      // Staging

   // fileprivate static let baseURL = "http://192.168.1.73/BBC_Customer_MW" // Test
    
    
    static let mode = "test" //test/live  need to change it befor live app
    //QR CODE URL CHECK
    static let methodType = "Stripe"
   static let url = "bbc.newforceltd.com"  //Staging
    static let url2 = "bbcstaging.newforceltd.com"  //Staging
    //static let url = "192.168.1.73"  //Staging
   
   // static let url = "localhost"  //Local
    
    
//   static let url = "retail.maaserp.com"  //Live
    
    
//
    static let loginURL                      =   baseURL + version + "userSignUp"
    static let checkUserOTPURL               =   baseURL + version + "checkUserOTP"
    static let updateUserInfoURL             =   baseURL + version + "updateUserInfo"
    static let getRetailerProductstURL       =   baseURL + version + "getProductListing"
    static let addToCart                     =   baseURL + version + "addToCart"
    static let getCartDetailsByCustomer      =   baseURL + version + "getCartDetailsByCustomer"
    static let updateCartQty                 =   baseURL + version + "updateCartQty"
    static let deleteCartitem                =   baseURL + version + "deleteCartitem"
    static let addCustomerinfo               =   baseURL + version + "addCustomerinfo"
    static let getUserInfo                   =   baseURL + version + "getUserInfo"
    static let generateOrderID               =   baseURL + version + "generateOrderID"
    static let OrderSuccess                  =   baseURL + version + "OrderSuccess"
    static let getCustomerOrderList          =   baseURL + version + "getCustomerOrderList"
    static let getCustomerOrderDetailById    =   baseURL + version + "getCustomerOrderDetailById"
    static let getCustomerOrderDetailByBatchID = baseURL + version + "getCustomerOrderByBatchId"
    static let deleteORderItem              =   baseURL + version + "deleteOrderItem"
    static let getRetailerProductBySku       =   baseURL + version + "getRetailerProductBySku"
    static let addCustomerActivity           =   baseURL + version + "addCustomerActivity"
    static let getDailyActivityList          =   baseURL + version + "getDailyActivityList"
    static let getStoreInfo                  =   baseURL + version + "getStoreInfo"
    static let getRetailerServices           =   baseURL + version + "getRetailerServices"
    static let getCommonFilterURL            =   baseURL + version + "getCommonFilter"
    static let getDocAvailSlotsByDocId      =   baseURL + version + "getDocAvailSlotsByDocId"
    static let bookAppoinment               =   baseURL + version + "bookSlot"
    static let deleteAccount                =   baseURL + version + "userDeleteAccount"
    static let addToCartAppoinment          =   baseURL + version + "addToCart"
    static let rescheduleAPI                =   baseURL + version + "rescheduleSlot"
    static let cancelOrder                  =   baseURL + version + "cancelSlot"
    static let getAllTableList              =   baseURL + version + "trcList"
    static let getTRCStoreId                =   baseURL + version + "getTRCStoreId"
    static let bookCabSlot                  =   baseURL + version + "bookCabSlot"
    static let getStripeKeyApi              =   baseURL + version + "fetchApiKeys"

    static let getDeliveryAddressList       =   baseURL + version + "getDeliveryAddressList"
    static let removeDeliveryAddress        =   baseURL + version + "removeDeliveryAddress"
    static let addDeliveryAddress           =   baseURL + version + "addDeliveryAddress"
    static let updateDefaultAddress         =   baseURL + version + "updateDefaultAddress"
    static let updateDeliveryAddress        =   baseURL + version + "updateDeliveryAddress"
    static let getProductDetailById         =   baseURL + version + "getProductDetailById"
    
    
   }

struct RazorpayConstants{
    static let razorpayKey = "rzp_live_gi4vcoIaO17ryr" //Live
  // static let razorpayKey = "rzp_test_WFoCbUuM32ToLG" //Testing
   }

enum DataType{
    case serviceGroup
    case countryCode
    case mainCategory
    case subCategory
    case none
}

enum DropdownType{
    case defaultType
    case apiSuggesionSearch
    case apiGetSearch
}
//***************************************
enum DropdownAction{
    case YesNo
    case Okay
    case none
}

enum DropdownActionType{
    case logout
    case storeExit
    case multiplePackage
    case changeStore
    case openCart
    case storeInactive
    case none
    case deleteAccount
}
//***************************
struct StoreCateType{
    static let hostpital = "hospital"
    static let diagnostic = "diagnostic"
    static let cabService = "cab service"
    static let restaurant = "restaurant"
    static let fmcg = "FMCG"
}
