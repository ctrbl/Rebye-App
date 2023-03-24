//
//  ProductDisplay.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/17/22.
//

import SwiftUI

struct ProductDisplay: View {
    @EnvironmentObject var userAuth: UserAuthModel
    @State var productModel: ProductModel
    @Binding var isModified: Bool
    
    @State var quantity: Int = 1
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack (alignment: .leading, spacing: 0) {
                    Image(uiImage: productModel.image)
                        .resizable()
                        .cornerRadius(25, corners: .bottomLeft)
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 380)
                    ScrollView {
                        VStack (alignment: .leading, spacing: 0) {
                            Text(productModel.name)
                                .font(.largeTitle.weight(.medium))
                                .padding(.top, 12)
                            HStack {
                                Text("$ \(productModel.price, specifier: "%.2f")")
                                    .font(.title.weight(.medium))
                                Spacer()
                                Button {
                                    if quantity < productModel.inventory {
                                        quantity += 1
                                    }
                                } label: {
                                    Image(systemName: quantity < productModel.inventory ? "plus.circle.fill" : "plus.circle")
                                }
                                TextField("",
                                          value: $quantity,
                                          formatter: NumberFormatter(),
                                          onEditingChanged: {_ in
                                            if quantity > productModel.inventory {
                                                quantity = productModel.inventory
                                            }
                                            if quantity <= 1 {
                                                quantity = 1
                                            }
                                          },
                                          onCommit: {
                                            if quantity > productModel.inventory {
                                                quantity = productModel.inventory
                                            }
                                            if quantity <= 1 {
                                                quantity = 1
                                            }
                                          })
                                    .font(.title2.weight(.medium))
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
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                } label : {
                                    Image(systemName: quantity > 1 ? "minus.circle.fill" : "minus.circle")
                                }
                            }
                            .padding(.top, 3)
                            .padding(.trailing, 60)
                        Text(productModel.description)
                            .font(.title3.weight(.light))
                            .padding(.top, 9)
                            .padding(.trailing, 60)
                        }
                    }
                    Spacer()
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .offset(x: 40)
                VStack (alignment: .leading){
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            if productModel.sellerID != userAuth.accID {
                                DB_Manager().addToCart(accIDValue: userAuth.accID, pidValue: productModel.pid, priceValue: productModel.price, quantityValue: self.quantity)
                                isModified = true
                            } else {
                                showAlert.toggle()
                            }
                        } label: {
                            Text("Add to cart")
                                .font(.system(size: 20))
                                .bold()
                                .padding()
                                .background(Color(.black))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    .padding(.bottom)
                }
                .frame(maxHeight: .infinity)
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                ZStack {
                                   Capsule()
                                   .foregroundColor(.black)
                                   .frame(width: 43, height: 43)
                                   Button {
                                       self.mode.wrappedValue.dismiss()
                                   } label: {
                                       Image(systemName: "arrow.left")
                                           .foregroundColor(.white)
                                           .padding(.leading, 7)
                                           .frame(width: 38, height: 38)
                                   }
                                }
                                )
        .alert("Cannot add your product to cart", isPresented: $showAlert) {
            Button (role: .cancel) {
                showAlert.toggle()
            } label: {
                Text("Dismiss")
            }
        }
    }
}

struct ProductDisplay_Previews: PreviewProvider {
    @State static var isModified: Bool = false
    static var previews: some View {
        ProductDisplay(productModel: ProductModel(), isModified: $isModified)
            .environmentObject(UserAuthModel())
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

