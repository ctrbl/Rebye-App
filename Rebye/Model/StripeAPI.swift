//
//  StripeAPI.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/21/22.
//

import Foundation
import Stripe
import FirebaseFunctions
import FirebaseFirestore
import SwiftUI

let StripeAPI = _StripeAPI()

class _StripeAPI: NSObject, STPCustomerEphemeralKeyProvider {
    
    let userAuth = UserAuthModel.shared
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        let data = [
            "stripe_version": apiVersion,
            "customerID": userAuth.customerID
        ]
        
        Functions.functions().httpsCallable("createEphemeralKey").call(data) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
             }
            guard let key = result?.data as? [String: Any] else {
                completion(nil,nil)
                return
            }
            completion(key,nil)
        }
    }
}
