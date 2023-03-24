//
//  Product.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/1/22.
//

import Foundation
import SwiftUI

class ProductModel: Identifiable {
//    @Published var productModels: [ProductModel] = DB_Manager().getProducts()
    
    public var pid: Int64 = 0
    public var sellerID: String = ""
    public var name: String = ""
    public var description: String = ""
    public var inventory: Int = 0
    public var price: Double = 0.0
    public var image = UIImage()
    
    public var category: Category?
    enum Category: String, CaseIterable, Codable {
        case tops = "Tops"
        case bottoms = "Bottoms"
        case sets = "Sets"
        case accessories = "Accessories"
        case shoes = "Shoes"
        case bags = "Bags"
    }
    
    public var gender: Gender?
    enum Gender: String, CaseIterable, Codable {
        case women = "Women"
        case men = "Men"
        case unisex = "Unisex"
    }
}

