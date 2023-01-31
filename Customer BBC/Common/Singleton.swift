//
//  Singleton.swift
//  BBC Retail
//
//  Created by Prashant Kumar on 14/04/22.
//

import UIKit

var Shared : Singleton = Singleton()
class Singleton: NSObject {
    
    var userInfo :Userinfo!
    var storeInfo :StoreInfo!
    var cartInfo = (cartDetail:Cartinfo(totalQty: "") , cartList:[Productlist]())
    var slotTime = ""
    var slotID = ""
    var roomId = ""
    var slotDate = ""
    var isFromSlotBooking : Bool = false
    var stripeKeyInfo :StripeKeyInfo!
    class var sharedInstance : Singleton {
        return Shared
    }
}

