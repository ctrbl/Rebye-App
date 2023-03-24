//
//  ProductItem.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/1/22.
//

import SwiftUI

struct ProductItem: View {
    @EnvironmentObject var userAuth: UserAuthModel
    @State var showAlert1: Bool = false
    @State var showAlert2: Bool = false
    @State var productModel: ProductModel

    @Binding var state: Bool
    // xmark for delete button, heart for favorite button
    @State var text: String
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                Image(uiImage: productModel.image)
                    .resizable()
                    .cornerRadius(20)
                    .frame(width: 185)
                    .scaledToFit()
                VStack(alignment: .leading) {
                    Text(productModel.name)
                        .font(.headline)
                    Text("$ \(productModel.price, specifier: "%.2f")")
                        .font(.caption)
                }
                .padding()
                .frame(width: 185, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
            }
            .frame(width: 185, height: 250)
            .shadow(radius: 3)
            Button(action: {
//                self.state.toggle()
                if (text == "xmark") {
//                    let dbManager: DB_Manager = DB_Manager()
//                    dbManager.deleteProduct(pidValue: productModel.pid)
                    showAlert2.toggle()
                }
                if (text == "plus") {
                    if productModel.sellerID != userAuth.accID {
                        DB_Manager().addToCart(accIDValue: userAuth.accID, pidValue: productModel.pid, priceValue: productModel.price, quantityValue: 1)
                    } else {
                        showAlert1.toggle()
                    }
                }
            }, label: {
                Image(systemName: self.state && text == "cart" ? text + ".fill" : text)
                    .padding(7)
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(40)
                    .padding([.trailing, .top], 10)
            })
        }
        .alert("Cannot add your product to cart", isPresented: $showAlert1) {
            Button(role: .cancel) {
                showAlert1.toggle()
            } label: {
                Text("Dismiss")
            }
        }
        .alert("Delete this product?", isPresented: $showAlert2) {
            Button(role: .cancel) {
                showAlert2.toggle()
            } label: {
                Text("No")
            }
            Button {
                let dbManager: DB_Manager = DB_Manager()
                dbManager.deleteProduct(pidValue: productModel.pid)
                state = true
            } label: {
                Text("Yes")
            }
        }
    }
}

struct ProductItem_Previews: PreviewProvider {
    var productModel: ProductModel = ProductModel()
    @State static var status = false
    static var previews: some View {
        ProductItem(productModel: ProductModel(), state: $status, text: "heart")
            .environmentObject(UserAuthModel())
//            .environmentObject(Cart_Manager())
    }
}
