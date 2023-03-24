//
//  CartItem.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/18/22.
//

import Foundation

class CartItem: Identifiable {
    public var cart_accID: String = ""
    public var products: [ProductModel] = []
    public var cartDict: [Int64 : Int] = [:]
    public var total: Double = 0.0
}
