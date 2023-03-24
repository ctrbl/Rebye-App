//
//  DB_Manager.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/1/22.
//

import Foundation
import SwiftUI
import SQLite
import AVFoundation

class DB_Manager {
    // sqlite instance
    private var db: Connection!
    // table instance
    private var accounts: Table!
    private var products: Table!
    private var carts: Table!
    
    // attributes for accounts
    private var accID: Expression<String>!
    private var customerID: Expression<String>!
    private var firstName: Expression<String>!
    private var lastName: Expression<String>!
    private var email: Expression<String>!
    private var profilePicUrl: Expression<String>!
    
    // attributes for products
    private var pid: Expression<Int64>!
    private var sellerID: Expression<String>!
    private var name: Expression<String>!
    private var category: Expression<String>!
    private var gender: Expression<String>!
    private var description: Expression<String>!
    private var inventory: Expression<Int>!
    private var price: Expression<Double>!
    private var imageName: Expression<String>!
    
    // attributes for cart items
    private var cart_accID: Expression<String>!
    private var cart_pid: Expression<Int64>!
    private var cart_quantity: Expression<Int>!
    private var cart_total: Expression<Double>!
    
    init () {
        // exception handling
        do {
            // path of document directory
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            print(path)
            // creating database connection
            db = try Connection("\(path)/products.sqlite3")
            
            // creating table for Accounts
            accounts = Table("Accounts");
            
            // creating table for Products
            products = Table("Products")
            
            // creating table for Cart
            carts = Table("Carts")
            
            // create instances of each attribute for Accounts
            accID = Expression<String>("accID")
            customerID = Expression<String>("customerID")
            firstName = Expression<String>("firstName")
            lastName = Expression<String>("lastName")
            email = Expression<String>("email")
            profilePicUrl = Expression<String>("profilePicUrl")
            
            // create instances of each attribute for Products
            pid = Expression<Int64>("pid")
            sellerID = Expression<String>("sellerID")
            name = Expression<String>("name")
            category = Expression<String>("category")
            gender = Expression<String>("gender")
            description = Expression<String>("description")
            inventory = Expression<Int>("inventory")
            price = Expression<Double>("price")
            imageName = Expression<String>("imageName")
            
            // create instance of attributes for Cart
            cart_accID = Expression<String>("cart_accID")
            cart_pid = Expression<Int64>("cart_pid")
            cart_quantity = Expression<Int>("cart_quantity")
            cart_total = Expression<Double>("cart_total")
            
            // check if the Accounts table is already created
            try db.run(accounts.create(ifNotExists: true) { (t) in
                t.column(accID, primaryKey: true)
                t.column(customerID)
                t.column(firstName)
                t.column(lastName)
                t.column(email)
                t.column(profilePicUrl)
            })
            
            try db.run(products.create(ifNotExists: true) { (t) in
                t.column(pid, primaryKey: true)
                t.column(sellerID)
                t.column(name)
                t.column(category)
                t.column(gender)
                t.column(description)
                t.column(inventory)
                t.column(price)
                t.column(imageName)
            })
            
            try db.run(carts.create(ifNotExists: true) { (t) in
                t.column(cart_accID)
                t.column(cart_pid)
                t.column(cart_quantity)
                t.column(cart_total)
            })
            
        } catch {
            // show error message if any
            print(error.localizedDescription)
        }
    }
    
    public func registerUser(accIDValue: String, firstNameValue: String, lastNameValue: String, emailValue: String, profilePicUrlValue: String) {
        do {
            try db.run(accounts.insert(accID <- accIDValue, firstName <- firstNameValue, lastName <- lastNameValue, email <- emailValue, profilePicUrl <- profilePicUrlValue))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func addProduct(sellerIDValue: String, nameValue: String, categoryValue: String, genderValue: String, descriptionValue: String, inventoryValue: Int, priceValue: Double, imageValue: String) {
        do {
            try db.run(products.insert(sellerID <- sellerIDValue, name <- nameValue, category <- categoryValue, gender <- genderValue, description <- descriptionValue, inventory <- inventoryValue, price <- priceValue, imageName <- imageValue))
        } catch {
            print(error)
        }
    }
    
    public func getYourProducts(accIDValue: String) -> [ProductModel] {
        // create empty array
        var productModels: [ProductModel] = []
        
        // get all products in descending order
        var yourProducts = products.order(pid.desc)
        yourProducts = yourProducts.filter(sellerID == accIDValue)
        
        // exception handling
        do {
            // loop through all products
            for product in try db.prepare(yourProducts) {
                // create new model in each loop iteration
                let productModel: ProductModel = ProductModel()
                let decodedImage = product[imageName].imageFromBase64!
                
                var category2: ProductModel.Category? = .tops
                if product[category] == "Tops" {
                    category2 = .tops
                } else if product[category] == "Bottoms" {
                    category2 = .bottoms
                } else if product[category] == "Sets" {
                    category2 = .sets
                } else if product[category] == "Accessories" {
                    category2 = .accessories
                } else if product[category] == "Shoes" {
                    category2 = .shoes
                } else if product[category] == "Bags" {
                    category2 = .bags
                }
                var gender2: ProductModel.Gender? = .women
                if product[gender] == "Women" {
                    gender2 = .women
                } else if product[gender] == "Men" {
                    gender2 = .men
                } else if product[gender] == "Unisex" {
                    gender2 = .unisex
                }
                
                // set values in model from database
                productModel.pid = product[pid]
                productModel.sellerID = product[sellerID]
                productModel.name = product[name]
                productModel.category = category2
                productModel.gender = gender2
                productModel.description = product[description]
                productModel.inventory = product[inventory]
                productModel.price = product[price]
                productModel.image = decodedImage
                
                productModels.append(productModel)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // return product models array
        return productModels
    }
    
    public func getProducts(categoryValue: String, genderValue: String) -> [ProductModel] {
        // create empty array
        var productModels: [ProductModel] = []
        
        // get all products in descending order
        var results = products.order(pid.desc)
        if genderValue == "All" {
            if categoryValue != "" {
                results = results.filter(category == categoryValue)
            }
        } else {
            if categoryValue != "" {
                results = results.filter(gender == genderValue && category == categoryValue)
            } else {
                results = results.filter(gender == genderValue)
            }
        }
        
        // exception handling
        do {
            // loop through all products
            for product in try db.prepare(results) {
                // create new model in each loop iteration
                let productModel: ProductModel = ProductModel()
                let decodedImage = product[imageName].imageFromBase64!
                
                var category2: ProductModel.Category? = .tops
                if product[category] == "Tops" {
                    category2 = .tops
                } else if product[category] == "Bottoms" {
                    category2 = .bottoms
                } else if product[category] == "Sets" {
                    category2 = .sets
                } else if product[category] == "Accessories" {
                    category2 = .accessories
                } else if product[category] == "Shoes" {
                    category2 = .shoes
                } else if product[category] == "Bags" {
                    category2 = .bags
                }
                var gender2: ProductModel.Gender? = .women
                if product[gender] == "Women" {
                    gender2 = .women
                } else if product[gender] == "Men" {
                    gender2 = .men
                } else if product[gender] == "Unisex" {
                    gender2 = .unisex
                }
                
                // set values in model from database
                productModel.pid = product[pid]
                productModel.sellerID = product[sellerID]
                productModel.name = product[name]
                productModel.category = category2
                productModel.gender = gender2
                productModel.description = product[description]
                productModel.inventory = product[inventory]
                productModel.price = product[price]
                productModel.image = decodedImage
                
                productModels.append(productModel)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // return product models array
        return productModels
    }
    
    public func getProduct(pidValue: Int64) -> ProductModel {
        let productModel: ProductModel = ProductModel()
        let yourProduct : Table = products.filter(pid == pidValue)
        
        do {
            for product in try db.prepare(yourProduct) {
                let decodedImage = product[imageName].imageFromBase64!
                productModel.pid = product[pid]
                productModel.sellerID = product[sellerID]
                productModel.name = product[name]
                productModel.description = product[description]
                productModel.inventory = product[inventory]
                productModel.price = product[price]
                productModel.image = decodedImage
            }
        } catch {
            print(error.localizedDescription)
        }
        return productModel
    }
    
    public func updateProduct(pidValue: Int64, nameValue: String, categoryValue: String, genderValue: String, descriptionValue: String, inventoryValue: Int, priceValue: Double, imageValue: String) {
        do {
            let product: Table = products.filter(pid == pidValue)
            try db.run(product.update(name <- nameValue, category <- categoryValue, gender <- genderValue, description <- descriptionValue, inventory <- inventoryValue, price <- priceValue, imageName <- imageValue))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func addToCart(accIDValue: String, pidValue: Int64, priceValue: Double, quantityValue: Int) {
        do {
            let total = Double(quantityValue) * priceValue
            let item = carts.filter(cart_accID == accIDValue && cart_pid == pidValue)
            let count = try db.scalar(item.count)
            if count != 0 {
                updateCart(accIDValue: accIDValue, pidValue: pidValue, priceValue: priceValue, amountValue: quantityValue)
            } else {
                try db.run(carts.insert(cart_accID <- accIDValue, cart_pid <- pidValue, cart_quantity <- quantityValue, cart_total <- total))
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func updateCart(accIDValue: String, pidValue: Int64, priceValue: Double, amountValue: Int) {
        do {
            let product: ProductModel = getProduct(pidValue: pidValue)
            // there's only 1 row...
            let items: Table = carts.filter(cart_accID == accIDValue && cart_pid == pidValue)
            for item in try db.prepare(items) {
                if product.inventory >= item[cart_quantity] + amountValue {
                    let change = Double(amountValue) * priceValue
                    try db.run(items.update(cart_quantity <- cart_quantity + amountValue, cart_total <- cart_total + change))
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func removeFromCart(accIDValue: String, pidValue: Int64) {
        do {
            let product: Table = carts.filter(cart_accID == accIDValue && cart_pid == pidValue)
            try db.run(product.delete())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func getYourCart(accIDValue: String) -> [CartModel] {
        // create empty array
        var cartModels: [CartModel] = []
        let results: Table = carts.filter(cart_accID == accIDValue)
        
        do {
            for item in try db.prepare(results) {
                let cartModel: CartModel = CartModel()
                let productModel: ProductModel = getProduct(pidValue: item[cart_pid])

                cartModel.cart_accID = item[cart_accID]
                cartModel.cart_pid = item[cart_pid]
                cartModel.cart_quantity = item[cart_quantity]
                cartModel.cart_total = item[cart_total]
                cartModel.product = productModel
                cartModels.append(cartModel)
            }
        } catch {
            print(error.localizedDescription)
        }
        return cartModels
    }
    
    public func getCartTotal(accIDValue: String) -> Double {
        let results: Table = carts.filter(cart_accID == accIDValue)
        var total: Double = 0.0
        do {
            for item in try db.prepare(results) {
                total += item[cart_total]
            }
        } catch {
            print(error.localizedDescription)
        }
        return total
    }
    
    public func emptyCart(accIDValue: String) {
        do {
            let yourCart = carts.filter(cart_accID == accIDValue)
            try db.run(yourCart.delete())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func deleteDatabase()
    {
            let filemManager = FileManager.default
            do {
                let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
                let fileURL = NSURL(fileURLWithPath: "\(path)/products.sqlite3")
                try filemManager.removeItem(at: fileURL as URL)
                print("Database Deleted!")
            } catch {
                print("Error on Delete Database!!!")
            }
    }
    
    public func deleteProduct(pidValue: Int64) {
        do {
            // get product with pid
            let product: Table = products.filter(pid == pidValue)
            
            try db.run(product.delete())
            let item = carts.filter(cart_pid == pidValue)
            try db.run(item.delete())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func processPayment(cartModels: [CartModel]) {
        do {
            for cartModel in cartModels {
                let product: Table = products.filter(pid == cartModel.cart_pid)
                for item in try db.prepare(product) {
                    if item[inventory] == cartModel.cart_quantity {
                        deleteProduct(pidValue: cartModel.cart_pid)
                    } else {
                        let inventoryValue = item[inventory] - cartModel.cart_quantity
                        try db.run(product.update(inventory <- inventoryValue))
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
