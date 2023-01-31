//
//  APIManger.swift
//  BBC Retail
//
//  Created by Prashant Kumar on 12/04/22.
//

import UIKit
import Alamofire
import FirebaseMessaging
import FTIndicator
import Ipify


final class WebServiceManager {
    static let sharedInstance = WebServiceManager()
    let userDefault = UserDefaults.standard
    let keyChainAccess = KeychainAccess()
    var userInfo : Userinfo!
    
    //MARK: ****************** Product Detail ******************
    //MARK: ******************GET PRODUCT DETAILS BY ID ******************
    func getProductDetailsById(product_id:String,completionHandler closure: @escaping(ProductDetail?,String?,String?) -> Void) {
        let params = [
            "product_id": product_id
        ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getProductDetailById, parameters: params, headers: getHeaders(),encoding: URLEncoding.httpBody)  { data,error  in
            guard let data:Base = data else{
                return}
            closure(data.result?.productDetail,data.msg!,data.status)
        }
    }
    
    //MARK: ****************** GET STORE INFO ******************
    func getStripeKeysAPI(completionHandler closure: @escaping(StripeKeyInfo?,String?,String?) -> Void) {
        let params = [
                 "type":EndPoint.mode
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getStripeKeyApi, parameters: params, headers: getHeaders(),encoding: URLEncoding.httpBody) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.stripeKeyInfo,data.msg!,data.status)
         }
       }

    func getPublicIP(closure:@escaping(String) -> Void)  {
        if !NetworkState.isConnected(){
            SKActivityIndicator.dismiss()
            FTIndicator.showToastMessage("Please Check Internet Connectivity.")
            return
        }
        Ipify.getPublicIPAddress { result in
            switch result {
            case .success(let ip):
                print(ip) // "210.11.178.112"
                closure(ip)
            case .failure(let error):
                print(error.localizedDescription)
                closure("103.149.154.7")
            }
        }
    }
    
    func getIPAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {return nil}
        guard let firstAddr = ifaddr else {return nil}
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" || name == "pdp_ip0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
                }
             }
          }
        freeifaddrs(ifaddr)
        return address
    }
    //MARK: ******************LOGIN******************
    func loginAPI(countryCode:String,mobileNumber:String,completionHandler closure: @escaping(String?,String?) -> Void) {
        let messaging = Messaging.messaging()
        let token = messaging.fcmToken
            let params = [
                "country_code": countryCode,
                "mobile_number":mobileNumber,
                
            ] as [String : Any]
            let header : HTTPHeaders = ["outhKey":"$^%$^*(^&%","fcm_token":token!]
            WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.loginURL, parameters: params, headers: header) { data,error  in
                guard let data = data else{
                    return}
                //            Singleton.sharedInstance.userInfo = Userinfo(userId: data.result?.userId ?? "")
                //            self.userDefault.save(customObject: Singleton.sharedInstance.userInfo,inKey:"CustomerData")
                //            if let savedPerson = self.userDefault.object(forKey: "CustomerData") as? Data {
                //                let decoder = JSONDecoder()
                //                if let loadedPerson = try? decoder.decode(String.self, from: savedPerson){
                //               print(loadedPerson)
                //            }
                //            }
                closure(data.msg,data.status)
            }
       }

    //MARK: ******************UPDATE USER INFO******************
    func updateUserInfoAPI(email:String,firstname:String,lastname:String,userID:String,completionHandler closure: @escaping(Userinfo?,String?,String?) -> Void) {
        let params = [
            "user_id":userID,
            "email":email,
            "firstname":firstname,
            "lastname":lastname
           ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.updateUserInfoURL, parameters: params, headers: getHeaders()) { data,error  in
            guard let data:Base = data else{
                return}
            if data.status == "1"{
               // let mobile = Singleton.sharedInstance.userInfo.mobile
            Singleton.sharedInstance.userInfo = data.result?.userinfo
             //   Singleton.sharedInstance.userInfo.mobile = mobile
            self.userDefault.save(customObject: Singleton.sharedInstance.userInfo,inKey:"CustomerData")
            if let savedPerson = self.userDefault.object(forKey: "CustomerData") as? Data {
                let decoder = JSONDecoder()
                if let loadedPerson = try? decoder.decode(String.self, from: savedPerson){
                    print(loadedPerson)
                }
             }
            }
          closure(data.result?.userinfo,data.msg,data.status)
         }
         }
    //MARK: ****************** VERIFY OTP ******************
    func verifyOTPAPI(countryCode:String,mobileNumber:String,otp:String,completionHandler closure: @escaping(Userinfo?,String?,String?) -> Void) {
        let messaging = Messaging.messaging()
        let token = messaging.fcmToken
        let ipAddress = getIPAddress()
        let udid = keyChainAccess.checkUniqueID()
        getPublicIP { ip in
            let params = [
                "country_code": countryCode,
                "mobile_number": mobileNumber,
                "OTP":otp,
                "device_token":udid,
                "add_from":"ios",
                "device":UIDevice.modelName,
                "fcm_token":token ?? "",
                "ip_address": ip
            ] as [String : Any]
            let header : HTTPHeaders = ["outhKey":"$^%$^*(^&%","fcm_token":token!]
            WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.checkUserOTPURL, parameters: params, headers: header) { data,error  in
                guard let data:Base = data else{
                    return}
                if data.status == "1"{
                    guard let userInfo = data.result?.userinfo else{return}
                    //                if userInfo.firstname ?? "" != "" || userInfo.lastname ?? "" != "" || userInfo.email ?? "" != ""{
                    Singleton.sharedInstance.userInfo = userInfo
                    //  Singleton.sharedInstance.userInfo.mobile = mobileNumber
                    self.userDefault.save(customObject: Singleton.sharedInstance.userInfo,inKey:"CustomerData")
                    if let savedPerson = self.userDefault.object(forKey: "CustomerData") as? Data {
                        let decoder = JSONDecoder()
                        if let loadedPerson = try? decoder.decode(String.self, from: savedPerson){
                            print(loadedPerson)
                        }
                 
                    }
                  
                }
                closure(data.result?.userinfo,data.msg,data.status)
            }
        }
      }
//    //MARK: - ******************GET COUNTRY CODE******************
//    func getCountryCodeAPI(completionHandler closure: @escaping([DropDownModel]?,String?,String?) -> Void) {
//        WebServiceManager.sharedInstance.AFGetRequest(url: EndPoint.countryCodesURL){ data,error  in
//            guard let data:Base = data else{
//                return}
//          
//            closure(data.result?.mobileCode,data.msg,data.status)
//        }
//       }

    //MARK: -******************GET PRODUCT LIST BY STORE ID******************
    func getProductListByStore(storeID:String,vertical:String,commonFilter:String,page:String,completionHandler closure: @escaping([Productlist]?,Int?,Int?,String?,String?) -> Void) {
        let params = [
            "page":page,
            "store_id": storeID,
            "commonFilter" : commonFilter,
            "vertical":vertical
          //  "RETAILER_ID":Singleton.sharedInstance.retailerData.store_id!
        ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getRetailerProductstURL, parameters: params, headers: getHeaders()) { data,error  in
            guard let data:Base = data else{
                return}
            closure(data.result?.productlist,data.result?.totalpage!,data.result?.totalItemCount!,data.msg!,data.status)
         }
       }
    //MARK: ****************** GET COMMON FILTER  ******************
    func getCommonFilterAPI(type:String,store_id:String,mainCat:String,completionHandler closure: @escaping([CommonFilter]?,String?,String?) -> Void) {
        let params = [
            "filter_type":type, //ProductList OrderList
            "store_id" :store_id,
            "mainCategory" : mainCat
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getCommonFilterURL, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.commonFilter,data.msg!,data.status)
         }
       }
    //MARK: ****************** GET AVAILABILTY TIME******************
    func getAvailabilityTimeAPI(date:String,store_id:String,doctor_Id:String,user_id:String,service_Id:String,day:String,vertical:String,completionHandler closure: @escaping(SlotTimeData?,String?,String?) -> Void) {
        let params = [
            "date":date, //ProductList OrderList
            "store_Id" :store_id,
            "doctor_Id" : doctor_Id,
            "user_id": user_id,
            "service_Id": service_Id,
            "vertical" : vertical,
            "day" : day
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getDocAvailSlotsByDocId, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.SlotTime,data.msg ?? "",data.status)
         }
       }
    //MARK: ****************** RESCHEDULE APPOINMENT ******************
    func RescheduleAppoinmentAPI(store_id:String,room_id:String,slot_start_time:String,previous_date:String,slot_date:String,user_name:String,vertical:String,slot_end_time:String,doctor_id:String,user_id:String,slot_id:String,service_id:String,doctor_name:String,order_id:String,payment_method:String,status:String,completionHandler closure: @escaping(String?,String?) -> Void) {
        let params = [
            "store_id":store_id, //ProductList OrderList
            "room_id" :room_id,
            "slot_start_time" : slot_start_time,
            "previous_date": previous_date,
            "slot_date": slot_date,
            "user_name" : user_name,
            "vertical" : vertical,
            "slot_end_time" : slot_end_time,
            "doctor_id" : doctor_id,
            "user_id": user_id,
            "slot_id": slot_id,
            "service_id": service_id,
            "doctor_name": doctor_name,
            "order_id": order_id,
            "payment_method": payment_method,
            "status" : status
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.rescheduleAPI, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.msg ?? "",data.status)
         }
       }

    //MARK: ****************** BOOK APPOINMENT ******************
    func BookAppoinmentAPI(slot_date:String,store_id:String,doctor_Id:String,user_id:String,service_Id:String,slot_start_time:String,slot_end_time:String,room_id:String,vertical:String,completionHandler closure: @escaping(String?,String?,String?) -> Void) {
        let params = [
            "slot_date":slot_date, //ProductList OrderList
            "store_id" :store_id,
            "doctor_id" : doctor_Id,
            "user_id": user_id,
            "service_id": service_Id,
            "vertical" : vertical,
            "slot_end_time" : slot_end_time,
            "slot_start_time" : slot_start_time,
            "room_id" : room_id
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.bookAppoinment, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.slot_id,data.msg ?? "",data.status)
         }
       }
    
    //MARK: ****************** BOOK CAB ******************
    func bookCabSlotAPI(slot_start_time:String,store_id:String,driver_id:String,slot_date:String,vertical:String,to_address:String,from_latitude:String,to_longitude:String,user_id:String,from_longitude:String,service_id:String,taxi_id:String,to_latitude:String,from_address:String,completionHandler closure: @escaping(String?,String?,String?) -> Void) {
        let params = [
            "slot_start_time":slot_start_time, //ProductList OrderList
            "store_id":store_id,
            "driver_id":driver_id,
            "slot_date":slot_date,
            "vertical": vertical,
            "to_address":to_address,
            "from_latitude":from_latitude,
            "to_longitude":to_longitude,
            "user_id":user_id,
            "from_longitude":from_longitude,
            "service_id":service_id,
            "taxi_id":taxi_id,
            "to_latitude":to_latitude,
            "from_address":from_address
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.bookCabSlot, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.slot_id,data.msg ?? "",data.status)
         }
       }
    

    //MARK: ****************** ADD TO CART APPOINMENT ******************
    func AddToCartAppoinment(store_id:String,product_offer_price:String,user_id:String,product_id:String,qty:String,action:String,vertical:String,store_type:String,inventory:String,package_type:String,payment_method:String,completionHandler closure: @escaping(String?,String?,String?) -> Void) {
        let params = [
            "store_id": store_id,
            "product_offer_price" : product_offer_price,
            "user_id": user_id,
            "product_id": product_id,
            "qty": qty,
            "action": action,
            "vertical":vertical,
            "store_type": store_type,
            "inventory": inventory,
            "package_type": package_type,
            "payment_method": payment_method
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.addToCartAppoinment, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.slot_id,data.msg ?? "",data.status)
         }
       }
    //MARK: ****************** TABLELIST API ******************
    func getAllTableList(store_id:String,page:String,completionHandler closure: @escaping([TRCListData]?,String?,String?) -> Void) {
        let params = [
            "store_id": store_id,
            "page" : page,
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getAllTableList, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
            closure(data.result?.TRCList,data.msg ?? "",data.status)
         }
       }
 
    
    //MARK: ****************** Get Product by SKU ******************
    func getProductBySkuAPI(sku:String,completionHandler closure: @escaping(Productlist?,String?,String?) -> Void) {
        let params = [
            "sku":sku
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getRetailerProductBySku, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.productlist![0],data.msg!,data.status)
         }
       }
    //MARK: -******************GET CART ******************
    func getCartAPI(store_id:String,completionHandler closure: @escaping(Cartinfo?,[Productlist]?,String?,String?) -> Void) {
        let params = [
            "store_id":store_id,
            "user_id": Singleton.sharedInstance.userInfo.userId ?? "",
            "vertical": Singleton.sharedInstance.storeInfo.category ?? ""
           // "RETAILER_ID":Singleton.sharedInstance.retailerData.store_id!
        ] as [String : Any]
       WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getCartDetailsByCustomer, parameters: params, headers: getHeaders()) { data,error in
        guard let data:Base = data else{
                return}
        closure(data.result?.cartinfo,data.result?.productlist,data.msg!,data.status)
        }
       }
    //MARK: ******************GET SALES ORDER LIST******************
    func getStoreOrderList(page:String,commonFilter:String,completionHandler closure: @escaping([OrderList]?,Int?,Int?,String?,String?) -> Void) {
        let params = [
            "commonFilter":commonFilter,
            "page":page,
            "user_id": Singleton.sharedInstance.userInfo.userId!
            ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getCustomerOrderList, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.orderList,data.result?.totalpage,data.result?.totalItemCount,data.msg!,data.status)
         }
       }

    //MARK: ****************** GET ORDER DETAILS ******************
    func getOrderDetails(vertical:String,orderID:String,user_id:String,paymentMethod:String,product_type:String,completionHandler closure: @escaping(OrderInfo?,String?,String?) -> Void) {
        let params = [
            "order_id":orderID,
            "user_id" :user_id,
            "payment_method" : paymentMethod,
            "vertical":vertical,
            "product_type" : product_type
        ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getCustomerOrderDetailById, parameters: params, headers: getHeaders()) { data,error  in
            guard let data:Base = data else{
                return}
        closure(data.result?.orderInfo,data.msg!,data.status)
         }
       }
    //MARK: ****************** GET ORDER DETAILS BY BATCH ID ******************
    func getOrderDetailsByBatchID(vertical:String,orderID:String,order_batch_id:String,paymentMethod:String,product_type:String,completionHandler closure: @escaping(OrderBatchInfo?,String?,String?) -> Void) {
        let params = [
            "order_id":orderID,
            "order_batch_id" :order_batch_id,
            "payment_method" : paymentMethod,
            "vertical":vertical,
            "product_type" : product_type
        ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getCustomerOrderDetailByBatchID, parameters: params, headers: getHeaders()) { data,error  in
            guard let data:Base = data else{
                return}
        closure(data.result?.orderBatchInfo,data.msg!,data.status)
         }
       }
    func getApiDeleteOrderItem(cart_id:String,user_id:String,product_id:String,vertical:String,inventory:String,order_id:String,status:String,paymentMethod:String,completionHandler closure: @escaping(String?,Int?) -> Void) {
        let params = [
            "cart_id":cart_id,
            "user_id" :user_id,
            "product_id":product_id,
            "inventory":inventory,
            "order_id":order_id,
            "status":status,
            "payment_method" : paymentMethod,
            "vertical":vertical
        ] as [String : Any]
        print("Auth Header =",getHeadersOuthKey())
        WebServiceManager.sharedInstance.AFDeleteRequest(url: EndPoint.deleteORderItem, parameters: params, headers: getHeadersOuthKey()) { data,error  in
            guard let data:Base = data else{
                return}
            closure(data.msg!,Int(data.status ?? ""))
         }
       }
    
    //MARK: ****************** GET STORE INFO ******************
    func getStoreInfoAPI(storeID:String,type:String,completionHandler closure: @escaping(StoreInfo?,String?,String?) -> Void) {
        let params = [
            "store_id":storeID ,
            "type":type
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getStoreInfo, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.storeInfo,data.msg!,data.status)
         }
       }
    //MARK: ****************** GET USER HISTORY ******************
    func getUserHistoryAPI(completionHandler closure: @escaping([StoreList]?,String?,String?) -> Void) {
        let params = [
            "user_id": Singleton.sharedInstance.userInfo.userId!,
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getDailyActivityList, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.storeList,data.msg!,data.status)
         }
       }
    //MARK: ****************** GET TRC INFO ******************
    func getTRCStoreId(barcodeId:String,completionHandler closure: @escaping(StoreInfo?,String?,String?) -> Void) {
        let params = [
            "barcodeId":barcodeId ,
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getTRCStoreId, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.storeInfo,data.msg!,data.status)
         }
       }
    //MARK: ****************** CANCEL ORDER API ******************
    func CancelOrderDetailAPI(store_id:String,room_id:String,slot_date:String,user_id:String,slot_id:String,user_name:String,service_id:String,vertical:String,doctor_name:String,order_id:String,status:String,completionHandler closure: @escaping(String?,String?) -> Void) {
        let params = [
            "store_id":store_id,
            "room_id" :room_id,
            "slot_date" : slot_date,
            "user_id":user_id,
            "slot_id": slot_id,
            "user_name":user_name,
            "service_id":service_id,
            "vertical": vertical,
            "doctor_name": doctor_name,
            "order_id": order_id,
            "status": status
        ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.cancelOrder, parameters: params, headers: getHeaders()) { data,error  in
            guard let data:Base = data else{
                return}
        closure(data.msg!,data.status)
         }
       }
  
//    func CancelOrderDetailAPI(user_id:String,order_id:String,completionHandler closure: @escaping(String?,String?) -> Void) {
//        let params = [
////            "store_id":store_id,
////            "room_id" :room_id,
////            "slot_date" : slot_date,
//            "user_id":user_id,
////            "slot_id": slot_id,
////            "user_name":user_name,
////            "service_id":service_id,
////            "vertical": vertical,
////            "doctor_name": doctor_name,
//            "order_id": order_id,
////            "status": status
//        ] as [String : Any]
//        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.cancelOrder, parameters: params, headers: getHeaders()) { data,error  in
//            guard let data:Base = data else{
//                return}
//        closure(data.msg!,data.status)
//         }
//       }
    
    //MARK: ****************** ADD USER HISTORY ******************
    func addUserHistoryAPI(store_id:String,status_comment:String,completionHandler closure: @escaping(String?,String?) -> Void) {
        let params = [
            "user_id":Singleton.sharedInstance.userInfo.userId!,
            "store_id":store_id,
            "status_comment":status_comment
//            status:
//            Item Added to Cart
//            ORder Placed
//            Visit
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.addCustomerActivity, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.msg!,data.status)
         }
       }
    //MARK: ****************** ADD TO CART ******************
    func addToCartAPI(store_id:String,productID:String,qty:String,action:String,offerPrice:String,payment_method:String,vertical:String,store_type:String,inventory:String,package_type:String,completionHandler closure: @escaping(String?,String?) -> Void) {
        let params = [
            "product_offer_price":offerPrice,
            "store_id":store_id,
            "user_id":Singleton.sharedInstance.userInfo.userId ?? "",
            "product_id":productID,
            "qty":qty,
            "action":action,
            "payment_method":payment_method ,
            "vertical": vertical,
            "store_type": store_type,
            "inventory": inventory,
            "package_type":package_type
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.addToCart, parameters: params, headers: getHeaders()) { data,error  in
            guard let data:Base = data else{
                return}
        closure(data.msg!,data.status)
         }
       }
    //MARK: ****************** UPDATE CART ******************
    func updateCartAPI(cart_id:String,qty:String,cart_main_id:String,completionHandler closure: @escaping(Cartinfo?,[Productlist]?,String?,String?) -> Void) {
        let params = [
            "user_id":Singleton.sharedInstance.userInfo.userId ?? "",
            "cart_main_id":cart_main_id,
            "cart_id":cart_id,
            "qty":qty
            ] as [String : Any]
        WebServiceManager.sharedInstance.AFPutRequest(url: EndPoint.updateCartQty, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.cartinfo,data.result?.productlist,data.msg!,data.status)
         }
       }
    //MARK: ****************** DELETE CART ******************
    func deleteCartAPI(cart_id:String,cart_main_id:String,completionHandler closure: @escaping(Cartinfo?,String?,String?) -> Void) {
        let params = [
            "user_id":Singleton.sharedInstance.userInfo.userId ?? "",
            "cart_main_id":cart_main_id,
            "cart_id":cart_id
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPutRequest(url: EndPoint.deleteCartitem, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
            closure(data.result?.cartinfo,data.msg!,data.status)
         }
       }
    
    //MARK: ****************** DELETE USER ******************
    func deleteUserAPI(completionHandler closure: @escaping(String?,String?) -> Void) {
        let params = [
            "userId":Singleton.sharedInstance.userInfo.userId ?? "",
            "currentStatus":"delete"
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPutRequest(url: EndPoint.deleteAccount, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
            closure(data.msg!,data.status)
         }
       }
    //MARK: ****************** GENERATE ORDER ID ******************
    func generateOrderIDAPI(storeID:String,cartMainID:String,paymentMethod:String,vertical:String,storeType:String,inventory:String,order_type:String,room_id:String,slot_id:String,slot_date:String,slot_time:String,doctor_id:String,table_id:String,table_number:String,taxi_id:String,driver_id:String,completionHandler closure: @escaping(String?,String?,String?) -> Void) {
        let params = [
            "store_id" : storeID,
            "user_id":Singleton.sharedInstance.userInfo.userId ?? "",
            "cart_main_id": cartMainID,
            "payment_method": paymentMethod,
            "inventory": inventory,
            "vertical":vertical ,
            "store_type":storeType,
            "order_type":order_type,
            "room_id" : room_id,
            "slot_id" : slot_id,
            "slot_date" : slot_date,
            "slot_time": slot_time,
            "doctor_id" : doctor_id,
            "table_id": table_id,
            "table_number": table_number,
            "taxi_id":taxi_id,
            "driver_id":driver_id
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.generateOrderID, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.order_Id,data.msg!,data.status)
         }
       }
    //MARK: GENERATE ORDER ID (Changed)
    func generateOrderIDAPI(storeID:String,cartMainID:String,paymentMethod:String,vertical:String,storeType:String,inventory:String,order_type:String,room_id:String,slot_id:String,slot_date:String,slot_time:String,doctor_id:String,table_id:String,table_number:String,taxi_id:String,driver_id:String,product_type:String = "",completionHandler closure: @escaping(String?,String?,String?) -> Void) {
            let params = [
                "store_id" : storeID,
                "user_id":Singleton.sharedInstance.userInfo.userId ?? "",
                "cart_main_id": cartMainID,
                "payment_method": paymentMethod,
                "inventory": inventory,
                "vertical":vertical ,
                "store_type":storeType,
                "order_type":order_type,
                "room_id" : room_id,
                "slot_id" : slot_id,
                "slot_date" : slot_date,
                "slot_time": slot_time,
                "doctor_id" : doctor_id,
                "table_id": table_id,
                "table_number": table_number,
                "taxi_id":taxi_id,
                "driver_id":driver_id,
                "product_type":product_type
                    ] as [String : Any]
            WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.generateOrderID, parameters: params, headers: getHeaders()) { data,error  in
            guard let data:Base = data else{
               return}
            closure(data.result?.order_Id,data.msg!,data.status)
             }
           }
    

    //MARK: ******************  ORDER SUCCESS ******************
    func orderSuccessAPI(storeID:String,order_id:String,transaction_id:String,cart_main_id:String,payment_method:String,inventory:String,vertical:String,store_type:String,method_type:String,response_type:String,reason:String,room_id:String,doctor_id:String,taxi_id:String,transfer_group:String = "",completionHandler closure: @escaping(String?,String?,String?) -> Void) {
        let params = [
            "taxi_id" : taxi_id,
            "store_id" : storeID,
            "user_id":Singleton.sharedInstance.userInfo.userId ?? "",
            "order_id":order_id ,
            "transaction_id": transaction_id,
            "cart_main_id": cart_main_id,
            "payment_method": payment_method,
            "inventory": inventory,
            "vertical":vertical ,
            "store_type":store_type,
            "method_type":method_type,
            "response_type":response_type ,
            "reason":reason,
            "room_id": room_id,
            "doctor_id": doctor_id,
            "transfer_group" : transfer_group
          //  "payment_method":paymentMethod, //after/before
          //  "vertical":vertical//product/restaurant/salon
//             "Cash";
//              "Online";
//               "PhonePe";
//                "Gpay";
//               "Paytm";
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.OrderSuccess, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
        closure(data.result?.order_Id,data.msg!,data.status)
         }
       }
    //MARK: ******************* **************** ****************  *************************************************************************************************
    func downloadFile(url: String, completionHandler:@escaping(URL?,Double,String, Bool)->()){
        let downloadUrl: String = url
        let destination: DownloadRequest.Destination = { _, _ in
            let url = URL(string: downloadUrl)
            _ = url?.pathExtension // pdf
            let fileName = url?.lastPathComponent
            let directoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let folderPath: URL = directoryURL.appendingPathComponent("NFDownloads", isDirectory: true)
            let fileURL: URL = folderPath.appendingPathComponent(fileName!)
            // let urlEx = fileURL.appendingPathExtension(fileExtension!)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        // print(downloadUrl)
        let manager = AF
        manager.session.configuration.timeoutIntervalForRequest = 20
        manager.download(downloadUrl, to: destination)
            .downloadProgress { progress in
                print(progress.fractionCompleted)
                completionHandler(nil, progress.fractionCompleted,"",false)
                // print("\(Int(progress.fileCompletedCount!))")
            }
            .responseData { response in
                print("response: \(response)")
                switch response.result{
                case .success( _):
                    let fileURL = response.fileURL
                    //  print(fileURL?.absoluteString)
                    // print(response.result)
                    completionHandler(fileURL, 1,"Success",true)
                    break
                case .failure(let error):
                    print(error)
                    completionHandler(nil, 0, "Error",false)
                    break
                }
               }
             }
    
    
    //    MARK: *********************************ADD ADDRESS API ******************************
        func addAddress(user_id:String,deliveryName: String,deliveryCountryCode: String,deliveryPhoneNumber: String,deliveryPincode: String,deliveryHouseNo: String,deliveryArea: String,deliveryCity: String,deliveryState: String,deliveryCountry:String,defaultAddress:String,lat:String, longitude:String,completionHandler closure: @escaping(String?,String?) -> Void) {
            let params = [
                "user_id":user_id ,
                "deliveryName": deliveryName,
                "deliveryCountryCode": deliveryCountryCode,
                "deliveryPhoneNumber": deliveryPhoneNumber,
                "deliveryPincode": deliveryPincode,
                "deliveryHouseNo": deliveryHouseNo,
                "deliveryArea": deliveryArea,
                "deliveryCity": deliveryCity,
                "deliveryState": deliveryState,
                "deliveryCountry": deliveryCountry,
                "defaultAddress": defaultAddress,
                "lat": lat,
                "longitude": longitude
                
                    ] as [String : Any]
            WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.addDeliveryAddress, parameters: params, headers: getHeaders()){ data,error  in
            guard let data:Base = data else{
          
               return}
                closure(data.msg!,data.status)
             }
           }
    
    //    MARK: *********************************UPDATE ADDRESS API ******************************
        func updateAddress(user_id:String,id:String,deliveryName: String,deliveryCountryCode: String,deliveryPhoneNumber: String,deliveryPincode: String,deliveryHouseNo: String,deliveryArea: String,deliveryCity: String,deliveryState: String,deliveryCountry:String,lat:String, longitude:String,completionHandler closure: @escaping([AddressListData]?,String?,String?) -> Void) {
            let params = [
                "user_id":user_id ,
                "id": id,
                "deliveryName": deliveryName,
                "deliveryCountryCode": deliveryCountryCode,
                "deliveryPhoneNumber": deliveryPhoneNumber,
                "deliveryPincode": deliveryPincode,
                "deliveryHouseNo": deliveryHouseNo,
                "deliveryArea": deliveryArea,
                "deliveryCity": deliveryCity,
                "deliveryState": deliveryState,
                "deliveryCountry": deliveryCountry,
                "lat": lat,
                "longitude": longitude
                
                    ] as [String : Any]
            WebServiceManager.sharedInstance.AFPutRequest(url: EndPoint.updateDeliveryAddress, parameters: params, headers: getHeaders()){ data,error  in
            guard let data:Base = data else{
          
               return}
                closure(data.result?.addressList, data.msg!,data.status)
             }
           }

        
  //    MARK: *********************************UPDATE DEFAULT ADDRESS LIST******************************
        func updateDefaiultAddress(addressId: String,user_id:String,defaultAddress: String,completionHandler closure: @escaping(String?,String?) -> Void) {
            let params = [
                "user_id":user_id ,
                "addressId": addressId,
                "defaultAddress": defaultAddress
                    ] as [String : Any]
            WebServiceManager.sharedInstance.AFPutRequest(url: EndPoint.updateDefaultAddress, parameters: params, headers: getHeaders()) { data,error  in
            guard let data:Base = data else{
          
               return}
                closure(data.msg!,data.status)
             }
           }

//    MARK: *********************************GET ADDRESS LIST******************************
    func getAddressList(user_id:String,completionHandler closure: @escaping([AddressListData]?,String?,String?) -> Void) {
        let params = [
            "user_id":user_id
                ] as [String : Any]
        WebServiceManager.sharedInstance.AFPostRequest(url: EndPoint.getDeliveryAddressList, parameters: params, headers: getHeaders()) { data,error  in
        guard let data:Base = data else{
           return}
            closure(data.result?.addressList,data.msg!,data.status)
         }
       }
    
    //    MARK: *********************************REMOVE ADDRESS LIST******************************
        func removeAddressFromList(user_id:String,addressId: String,completionHandler closure: @escaping(String?,String?) -> Void) {
            let params = [
                "user_id":user_id ,
                "addressId": addressId
                    ] as [String : Any]
            WebServiceManager.sharedInstance.AFPutRequest(url: EndPoint.removeDeliveryAddress, parameters: params, headers: getHeaders()) { data,error  in
            guard let data:Base = data else{
          
               return}
                closure(data.msg!,data.status)
             }
           }
    
    //MARK: ****************ALAMOFIRE GET REQUEST********************
    func AFGetRequest(url:String,headers:HTTPHeaders,completionHandler closure: @escaping(Base?,String) -> Void) {//Session Expired
        if !NetworkState.isConnected(){
            SKActivityIndicator.dismiss()
            //  print("Internet is'Nt available.")
            FTIndicator.showToastMessage("Please Check Internet Connectivity.")
         //   self.alertPopup(title: "Oops!", message:"Please Check Internet Connectivity.", image: Gif)
            // ...
        }
        print(url)
//
//                AF.request(url,method: .post,parameters:parameters as? Parameters,encoding: URLEncoding.httpBody,headers:headers).responseString { response in
//
//                 print(response.result)
//                }
        let manager = AF
        manager.session.configuration.timeoutIntervalForRequest = 20
        manager.request(url,method: .get,headers:headers).response{ response in//
          //  print(response.result)
            guard let data = response.data else { return }
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(Base.self, from: data)
                
                closure(data,"")
            } catch let error {
                SKActivityIndicator.dismiss()
                FTIndicator.showToastMessage("Server Error! Please try again later.")
            //    self.alertPopup(title: "Oops!", message: "Server Error! Please try again later.", image: self.Gif)
                print(error)
                let errorCode = response.response?.statusCode
                print(errorCode!)
                closure(nil,"")
            }
          }
       }
    
    //MARK: **************** ALAMOFIRE POST REQUEST ********************
    func AFPostRequest(url:String,parameters:Parameters,headers:HTTPHeaders,encoding:URLEncoding  = URLEncoding.httpBody,completionHandler closure: @escaping(Base?,String) -> Void) {//Session Expired
        if !NetworkState.isConnected(){
            SKActivityIndicator.dismiss()
            FTIndicator.showToastMessage("Please Check Internet Connectivity.")
            //  print("Internet is'Nt available.")
         //   self.alertPopup(title: "Oops!", message:"Please Check Internet Connectivity.", image: Gif)
            // ...
        }
        print(url,parameters,headers)
//
//                AF.request(url,method: .post,parameters:parameters as? Parameters,encoding: URLEncoding.httpBody,headers:headers).responseString { response in
//
//                    print(response.result)
//                }
        let manager = AF
        manager.session.configuration.timeoutIntervalForRequest = 20
        manager.request(url,method: .post,parameters:parameters,encoding: encoding,headers:headers).responseString{ response in//
            print(response.result)
            switch (response.result) {
                       case .success: // succes path
                guard let data = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(Base.self, from: data)
                    
                    closure(data,"")
                } catch let error {
                    SKActivityIndicator.dismiss()
                //    self.alertPopup(title: "Oops!",message: "Server Error! Please try again later.", image: self.Gif)
                    FTIndicator.showToastMessage("Server Error! Please try again later.")
                    print(error)
                    let errorCode = response.response?.statusCode
                    print(errorCode!)
                    closure(nil,"0")
                   }
                case .failure(let error):
                SKActivityIndicator.dismiss()
                    if error._code == NSURLErrorTimedOut {
                        FTIndicator.showToastMessage("Request timeout!")
                           print("ERRROR:  Request timeout!")
                        closure(nil,"Request Timeout")
                           }
                if error._code == NSURLErrorNetworkConnectionLost {
                           print("ERRROR:  Connection Lost!")
                    FTIndicator.showToastMessage("Connection Lost!")
                       }
                if error._code == NSURLErrorNotConnectedToInternet {
                           print("ERRROR:  Internet not avialable")
                    FTIndicator.showToastMessage("Internet not avialable")
                       }
                if error._code == NSURLErrorCannotConnectToHost {
                           print("ERRROR:  Could not connect to the server")
                    FTIndicator.showToastMessage("Could not connect to the server")
                       }
                       }
          
        }
    }
    //MARK: **************** ALAMOFIRE DELETE REQUEST ********************
    func AFDeleteRequest(url:String,parameters:Parameters,headers:HTTPHeaders,completionHandler closure: @escaping(Base?,String) -> Void) {//Session Expired
        if !NetworkState.isConnected(){
            SKActivityIndicator.dismiss()
            FTIndicator.showToastMessage("Please Check Internet Connectivity.")
            //  print("Internet is'Nt available.")
         //   self.alertPopup(title: "Oops!", message:"Please Check Internet Connectivity.", image: Gif)
            // ...
        }
        print(url,parameters)
//
//                AF.request(url,method: .post,parameters:parameters as? Parameters,encoding: URLEncoding.httpBody,headers:headers).responseString {                response in
//
//                    print(response.result)
//                }
        let manager = AF
        manager.session.configuration.timeoutIntervalForRequest = 20
        manager.request(url,method: .delete,parameters:parameters,encoding: URLEncoding.httpBody,headers:headers).response{ response in//
            print(response.result)
            switch (response.result) {
                       case .success: // succes path
                guard let data = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(Base.self, from: data)
                    
                    closure(data,"")
                } catch let error {
                    SKActivityIndicator.dismiss()
                //    self.alertPopup(title: "Oops!",message: "Server Error! Please try again later.", image: self.Gif)
                    FTIndicator.showToastMessage("Server Error! Please try again later.")
                    print(error)
                    let errorCode = response.response?.statusCode
                    print(errorCode!)
                    closure(nil,"0")
                   }
                case .failure(let error):
                SKActivityIndicator.dismiss()
                    if error._code == NSURLErrorTimedOut {
                        FTIndicator.showToastMessage("Request timeout!")
                           print("ERRROR:  Request timeout!")
                        closure(nil,"Request Timeout")
                           }
                if error._code == NSURLErrorNetworkConnectionLost {
                           print("ERRROR:  Connection Lost!")
                    FTIndicator.showToastMessage("Connection Lost!")
                       }
                if error._code == NSURLErrorNotConnectedToInternet {
                           print("ERRROR:  Internet not avialable")
                    FTIndicator.showToastMessage("Internet not avialable")
                       }
                if error._code == NSURLErrorCannotConnectToHost {
                           print("ERRROR:  Could not connect to the server")
                    FTIndicator.showToastMessage("Could not connect to the server")
                       }
                       }
          
        }
    }
    //MARK: **************** ALAMOFIRE PUT REQUEST ********************
    func AFPutRequest(url:String,parameters:Parameters,headers:HTTPHeaders,completionHandler closure: @escaping(Base?,String) -> Void) {//Session Expired
        if !NetworkState.isConnected(){
            SKActivityIndicator.dismiss()
            FTIndicator.showToastMessage("Please Check Internet Connectivity.")
            //  print("Internet is'Nt available.")
         //   self.alertPopup(title: "Oops!", message:"Please Check Internet Connectivity.", image: Gif)
            // ...
        }
        print(url,parameters)
//
//                AF.request(url,method: .post,parameters:parameters as? Parameters,encoding: URLEncoding.httpBody,headers:headers).responseString {                response in
//
//                    print(response.result)
//                }
        let manager = AF
        manager.session.configuration.timeoutIntervalForRequest = 20
        manager.request(url,method: .put,parameters:parameters,encoding: URLEncoding.httpBody,headers:headers).response{ response in//
            print(response.result)
            switch (response.result) {
                       case .success: // succes path
                guard let data = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(Base.self, from: data)
                    
                    closure(data,"")
                } catch let error {
                    SKActivityIndicator.dismiss()
                //    self.alertPopup(title: "Oops!",message: "Server Error! Please try again later.", image: self.Gif)
                    FTIndicator.showToastMessage("Server Error! Please try again later.")
                    print(error)
                    let errorCode = response.response?.statusCode
                    print(errorCode!)
                    closure(nil,"0")
                   }
                case .failure(let error):
                SKActivityIndicator.dismiss()
                    if error._code == NSURLErrorTimedOut {
                        FTIndicator.showToastMessage("Request timeout!")
                           print("ERRROR:  Request timeout!")
                        closure(nil,"Request Timeout")
                           }
                if error._code == NSURLErrorNetworkConnectionLost {
                           print("ERRROR:  Connection Lost!")
                    FTIndicator.showToastMessage("Connection Lost!")
                       }
                if error._code == NSURLErrorNotConnectedToInternet {
                           print("ERRROR:  Internet not avialable")
                    FTIndicator.showToastMessage("Internet not avialable")
                       }
                if error._code == NSURLErrorCannotConnectToHost {
                           print("ERRROR:  Could not connect to the server")
                    FTIndicator.showToastMessage("Could not connect to the server")
                       }
                       }
          
        }
    }
    //MARK: - ALAMOFIRE POST NO SERVER ERROR
    func AFPostNoServerErrorRequest(url:String,parameters:Parameters,headers:HTTPHeaders,completionHandler closure: @escaping(Base?) -> Void) {//Session Expired
        if !NetworkState.isConnected(){
            SKActivityIndicator.dismiss()
            FTIndicator.showToastMessage("Please Check Internet Connectivity.")
            //  print("Internet is'Nt available.")
          //  self.alertPopup(title: "Oops!", message:"Please Check Internet Connectivity.", image: Gif)
            // ...
        }
        print(url,parameters,headers)
//
//       AF.request(url,method: .post,parameters:parameters as? Parameters,encoding: URLEncoding.httpBody,headers:headers).responseString { response in
//
//                    print(response.result)
//                }
        let manager = AF
        manager.session.configuration.timeoutIntervalForRequest = 20
        manager.request(url,method: .post,parameters:parameters,encoding: URLEncoding.httpBody,headers:headers).response{ response in//
           // print(response.result)
            guard let data = response.data else { return }
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(Base.self, from: data)
                
                closure(data)
            } catch let error {
                SKActivityIndicator.dismiss()
               // self.alertPopup(title: "Oops!", message: "Server Error! Please try again later.", image: self.Gif)
                print(error)
                let errorCode = response.response?.statusCode
                print(errorCode!)
               }
              }
     }
    //MARK: -Almofire Image Upload Multipart request
    func alamofireImageUPLOAD(url:String,image:UIImage?,fileParameter:String,parameter : NSDictionary ,headers:HTTPHeaders, completionHandler: @escaping (Base?,Int) -> ()) {
        let manager = AF
        manager.session.configuration.timeoutIntervalForRequest = 20
        let api = manager.upload(multipartFormData: { (multipartFormData) in
          print(url,parameter)
            for (key, value) in parameter
            {
                if key as! String == fileParameter {
                    guard let img =  image else{return}
                    if let imageData = img.jpegData(compressionQuality: 0.6) {
                        multipartFormData.append(imageData, withName: fileParameter, fileName: "file.jpg", mimeType: "image/jpg")
                    }
                }else{
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as! String)
                }
            }
        }, to:url,method: .post,headers: headers)
        api.uploadProgress { (Progress) in
            print("Upload Progress: \(Progress.fractionCompleted)")
        }
        api.response
        {
            response -> Void in
            print(response.result)
            guard let data = response.data else { return }
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(Base.self, from: data)
                
                completionHandler(data,response.response?.statusCode ?? 00)
            } catch let error {
                SKActivityIndicator.dismiss()
                FTIndicator.showToastMessage("Server Error! Please try again later")
                print(error)
                let errorCode = response.response?.statusCode
                print(errorCode!)
               }
           }
        }
    //MARK: -Almofire Doc Upload Multipart  request
    func    alamofireUPLOAD(url:String,fileURL:URL,headers:HTTPHeaders,fileParameter:String,parameter : NSDictionary , urlString : String, completionHandler: @escaping (Data?,Int) -> ()) {
        let manager = AF
        manager.session.configuration.timeoutIntervalForRequest = 20
        let api = manager.upload(multipartFormData:{ (multipartFormData) in
            
        for (key, value) in parameter
            {
                if key as! String == fileParameter {
                    //            let pdfData = try! Data(contentsOf: fileURL)
                    //            var data : Data = pdfData
                multipartFormData.append(fileURL, withName: fileParameter) // "application/pdf"
                }else{
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as! String)
                }
            }
        }, to: url,method: .post,headers: headers)
        api.uploadProgress { (Progress) in
            print("Upload Progress: \(Progress.fractionCompleted)")
        }
        api.response
        {
            response -> Void in
           // print(response.result)
            completionHandler(response.data!,response.response?.statusCode ?? 00)
        }
        }

//    //MARK: ****************ALAMOFIRE POST REQUEST********************
//    func getServiceData <T: Codable> (url: String, method: HTTPMethod, parameters: [String:Any], encodingType: ParameterEncoding, headers:HTTPHeaders, completion: @escaping (T?, String?) ->()) {
//
//        if NetworkState.isConnected() {
//               //print("Network is Reachable")
//            let manager = AF
//            manager.session.configuration.timeoutIntervalForRequest = 20
//            manager.request(url, method: method, parameters: parameters, encoding: encodingType, headers: headers).response { response in
//
//                if response.error != nil {
//                           //debugPrint(response.error?.localizedDescription ?? "")
//                           completion(nil, response.error?.localizedDescription)
//                       }
//                do {
//                    guard let responsedata = response.data else {return completion(nil, response.error?.localizedDescription)}
//                    let decoder = JSONDecoder()
//                  //  let data = try decoder.decode(Base.self, from: responsedata)
//
//                    do{
//                       let returnedResponse = try decoder.decode(T.self, from: responsedata)
//                        completion(returnedResponse, nil)
//                    }catch{
//                        //debugPrint(error)
//                        completion(nil, error.localizedDescription)
//                    }
//                   }
//
//               }
//
//           }else {
//               //print("Network Not Reachable")
//               completion(nil, "Network Not Reachable")
//           }
//
//       }
//
//
//    //MARK: -Almofire Image Upload Multipart request
//    func multipartServiceData <T: Codable> (url: String, method: HTTPMethod,file:UIImage?,fileParameter:String, parameters: [String:Any], encodingType: ParameterEncoding, headers:HTTPHeaders, completion: @escaping (T?, String?) ->()) {
//        if NetworkState.isConnected() {
//        let manager = AF
//        manager.session.configuration.timeoutIntervalForRequest = 20
//        let api = manager.upload(multipartFormData: { (multipartFormData) in
//         // print(urlString,parameter)
//            for (key, value) in parameters
//            {
//                if key == fileParameter  && file != nil{
//                    if let imageData = file!.jpegData(compressionQuality: 0.6) {
//                       // let base64 = image.conte
////                        let data: Data? = image.jpegData(compressionQuality: 0.4)
////                        let imageStr = data?.base64EncodedString()
////                        print(imageStr)
//                        multipartFormData.append(imageData, withName: fileParameter, fileName: "file.jpg", mimeType: "image/jpg")
//                    }
//                }else{
//                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key )
//                }
//            }
//        }, to:url,method: .post,headers: headers)
//        api.uploadProgress { (Progress) in
//            print("Upload Progress: \(Progress.fractionCompleted)")
//        }
//        api.response { response -> Void in
//           // print(response.result)
//            if response.error != nil {
//                       //debugPrint(response.error?.localizedDescription ?? "")
//                       completion(nil, response.error?.localizedDescription)
//                   }
//            do {
//                guard let responsedata = response.data else {return completion(nil, response.error?.localizedDescription)}
//                let decoder = JSONDecoder()
//              //  let data = try decoder.decode(Base.self, from: responsedata)
//
//                do{
//                    let returnedResponse = try decoder.decode(T.self, from: responsedata)
//                    completion(returnedResponse, nil)
//                }catch{
//                    //debugPrint(error)
//                    completion(nil, error.localizedDescription)
//                }
//            }
//            }
//        }else {
//        //print("Network Not Reachable")
//        completion(nil, "Network Not Reachable")
//         }
//        }
//
  }
class NetworkState {
    class func isConnected() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
