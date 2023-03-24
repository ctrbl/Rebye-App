//
//  CartView.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/1/22.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    @State var cartModels: [CartModel] = []
    @State var isDeleted: Bool = false
    @State var isModified: Bool = false
    @State var showScreen: Bool = false
    @State var isPayed: Bool = false
    
    func cartTotal(cartModels: [CartModel]) -> Double {
        var total: Double = 0.0
        for cartModel in cartModels {
            total += cartModel.cart_total
        }
        return total
    }
    
    var body: some View {
        NavigationView {
            if cartModels.count > 0 {
//                Button {
//                    DB_Manager().emptyCart(accIDValue: userAuth.accID)
//                } label: {
//                    Image(systemName: "trash")
//                }
                VStack {
                    ScrollView {
                        ForEach (self.cartModels) { cartModel in
                            NavigationLink {
                                ProductDisplay(productModel: cartModel.product, isModified: $isModified)
                            } label: {
                                ProductRow(cart_item: cartModel, isDeleted: $isDeleted, isModified: $isModified)
                            }
                        }
                        .onChange(of: isDeleted) { cartModel in
                            self.cartModels = DB_Manager().getYourCart(accIDValue: userAuth.accID)
                            isDeleted = false
                        }
                    }
                    VStack (spacing: 10) {
                        HStack {
                            Text("Total:")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("$\(cartTotal(cartModels: cartModels), specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding([.leading, .trailing], 40)
                        Button(action: {
                            showScreen.toggle()
                        }, label: {
                            Text("Checkout")
                                .font(.system(size: 20))
                                .bold()
                                .padding()
                                .background(Color(.black))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        })
                        .sheet(isPresented: $showScreen, content: {
                            CheckoutViewController()
                        })
                    }
                    .padding(.bottom, 10)
                }
                .padding(.top)
                .navigationTitle("Your Cart")
            } else {
                Text("Your cart is empty")
                    .navigationTitle("Your Cart")
            }
        }
        .onAppear() {
            self.cartModels = DB_Manager().getYourCart(accIDValue: userAuth.accID)
        }
        .onChange(of: isModified) {_ in
            self.cartModels = DB_Manager().getYourCart(accIDValue: userAuth.accID)
            isModified = false
        }
//        .onChange(of: isPayed) {_ in
//            DB_Manager().processPayment(cartModels: cartModels)
//            self.cartModels = []
//            isPayed = false
//        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(UserAuthModel())
    }
}
