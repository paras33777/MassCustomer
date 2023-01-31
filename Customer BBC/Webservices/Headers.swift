//
//  Headers.swift
//  BBC Retail
//
//  Created by Prashant Kumar on 27/06/22.
//

import Foundation
import Alamofire
import FirebaseMessaging


    func getHeaders() -> HTTPHeaders{
        var accessKey : String!
        var authToken : String!
        if  Singleton.sharedInstance.userInfo != nil{
            accessKey = Singleton.sharedInstance.userInfo.accessKey ?? ""
            authToken = Singleton.sharedInstance.userInfo.authToken ?? ""
        }else{
            accessKey = ""
            authToken = ""
        }
        let messaging = Messaging.messaging()
        let token  = messaging.fcmToken
        let header : HTTPHeaders = ["outhKey":"$^%$^*(^&%","access_key":accessKey,"auth_token":authToken,"fcm_token":token!]
       return header
    }

func getHeadersOuthKey() -> HTTPHeaders{
    var accessKey : String!
    var authToken : String!
    if  Singleton.sharedInstance.userInfo != nil{
        accessKey = Singleton.sharedInstance.userInfo.accessKey ?? ""
        authToken = Singleton.sharedInstance.userInfo.authToken ?? ""
    }else{
        accessKey = ""
        authToken = ""
    }
    let messaging = Messaging.messaging()
    let token  = messaging.fcmToken
    let header : HTTPHeaders = ["outhKey":"$^%$^*(^&%","access_key":accessKey,"auth_token":authToken,"fcm_token":token!]
   return header
}

