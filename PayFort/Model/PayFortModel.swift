//
//  PayFortModel.swift
//  PayFort
//
//  Created by Kerolos Fahem on 7/5/19.
//  Copyright © 2019 devloop. All rights reserved.
//

import UIKit
import Alamofire

enum PayFortMode {
    case test
    case live
}

class PayFortModel: NSObject {
    
    //MARK: - Properties
    private let testUrl = "https://sbpaymentservices.payfort.com/FortAPI/paymentApi"
    private let liveUrl = "https://paymentservices.payfort.com/FortAPI/paymentApi"
    
    // Don't forget to change these values
    private let accessCode = ""
    private let merchant_reference = ""
    private let RequestPhrase = ""
    
    var language = "en"
    var payFortMode: PayFortMode = .test
    
    // body
    func getBodyParameters() -> [String: Any] {
        let payloadDict = NSMutableDictionary()
        
        payloadDict.setValue(language, forKey: "language")
        payloadDict.setValue(merchant_reference, forKey: "merchant_identifier")
        payloadDict.setValue(accessCode, forKey: "access_code")
        payloadDict.setValue("SDK_TOKEN", forKey: "service_command")
        
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        payloadDict.setValue(deviceID, forKey: "device_id")
        
        let paymentString = RequestPhrase + "access_code=" + accessCode + "device_id=\(deviceID)language=\(language)merchant_identifier=" + merchant_reference + "service_command=SDK_TOKEN" + RequestPhrase
        
        let base64Str = paymentString.sha256()
        payloadDict.setValue(base64Str, forKey:"signature")
        
        return payloadDict as! [String : Any]
    }
    
    //MARK: - API
    func request(body: Data?, method: String!) -> URLRequest {
        
        var requestUrlStr: String = ""
        
        if payFortMode == .live {
            requestUrlStr = liveUrl
            
        }else {
            requestUrlStr = testUrl
        }
        
        print("requested url: \(requestUrlStr)")
        
        let apiUrl = URL(string: requestUrlStr)
        var request = URLRequest(url: apiUrl!)
        
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if (body != nil) {
            request.httpBody = body
        }
        
        return request
    }
    
}
