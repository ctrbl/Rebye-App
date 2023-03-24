//
//  ProductRow.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/18/22.
//

import SwiftUI

struct ProductRow: View {
    @EnvironmentObject var userAuth: UserAuthModel
//    var product: ProductModel
    var cart_item: CartModel
    @State var amount: Int = 0
    @Binding var isDeleted: Bool
    @Binding var isModified: Bool
    @State var showAlert: Bool = false
    
    var body: some View {
        HStack (spacing: 20) {
            Image(uiImage: cart_item.product.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .cornerRadius(10)

            VStack (alignment: .leading, spacing: 7) {
                Text(cart_item.product.name)
                    .font(.title3).bold()
                    .padding(.top, 10)
                Text("$ \(cart_item.product.price, specifier: "%.2f")")
                    .font(.title3)
                Spacer()
                HStack {
                    Button {
                        if amount < cart_item.product.inventory {
                            DB_Manager().updateCart(accIDValue: userAuth.accID, pidValue: cart_item.product.pid, priceValue: cart_item.product.price, amountValue: 1)
                            amount += 1
                            isModified = true
                        }
                    } label: {
                        Image(systemName: amount < cart_item.product.inventory ? "plus.circle.fill" : "plus.circle")
                    }
                    TextField("",
                              value: $amount,
                              formatter: NumberFormatter(),
                              onCommit: {
                                if amount > cart_item.product.inventory {
                                    amount = cart_item.product.inventory
                                }
                                if amount <= 0 {
                                    amount = 1
                                }
                                DB_Manager().updateCart(accIDValue: userAuth.accID, pidValue: cart_item.product.pid, priceValue: cart_item.product.price, amountValue: amount - cart_item.cart_quantity)
                                isModified = true
                              })
                        .font(.title3.weight(.medium))
                        .multilineTextAlignment(.center)
                        .frame(width: 50, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(
                                    color: Color.black.opacity(0.30),
                                    radius: 10, x: 0, y: 0)
                        )
                    Button {
                        if amount > 1 {
                            DB_Manager().updateCart(accIDValue: userAuth.accID, pidValue: cart_item.product.pid, priceValue: cart_item.product.price, amountValue: -1)
                            amount -= 1
                            isModified = true
                        }
                    } label : {
                        Image(systemName: amount > 1 ? "minus.circle.fill" : "minus.circle")
                    }
                }
                .padding(.bottom, 10)
            }

            Spacer()

            Button(action: {
                showAlert.toggle()
            }, label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15))
                    .padding(7)
                    .overlay (
                        Circle()
                            .strokeBorder(.black, lineWidth: 2)
                    )
            })
        }
        .padding(.horizontal).padding(.bottom, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear(perform: {
            self.amount = cart_item.cart_quantity
        })
        .alert("Delete from cart?", isPresented: $showAlert) {
            Button (role: .cancel) {
                showAlert.toggle()
            } label: {
                Text("No")
            }
            Button {
                isDeleted = true
                DB_Manager().removeFromCart(accIDValue: userAuth.accID, pidValue: cart_item.product.pid)
            } label: {
                Text("Yes")
            }
        }
    }
}

struct ProductRow_Previews: PreviewProvider {
    @State static var isDeleted = false
    @State static var isModified = false
    static var previews: some View {
        ProductRow(cart_item: CartModel(), isDeleted: $isDeleted, isModified: $isModified)
            .environmentObject(UserAuthModel())
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
