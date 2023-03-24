//
//  CartModel.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/18/22.
//

import Foundation
import SwiftUI

class CartModel: Identifiable {
    public var cart_accID: String = ""
    public var cart_pid: Int64 = 0
    public var cart_quantity: Int = 0
    public var cart_total: Double = 0.0
    
    public var product: ProductModel = ProductModel()
}
