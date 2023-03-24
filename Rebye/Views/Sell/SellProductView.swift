//
//  SellProductView.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/1/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct SellProductView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    
    // array of product models
    @State var productModels: [ProductModel] = []
    @State var isDeleted: Bool = false
    
    var columns = [GridItem(.adaptive(minimum: 140))]
    
    var body: some View {
        NavigationView {
            ZStack {
                // create list view to show all user's products on sale
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(self.productModels) { product in
                            NavigationLink {
                                EditProductView(productModel: product)
                            } label: {
                                ProductItem(productModel: product, state: $isDeleted, text: "xmark")
                            }
                        }
                        .onChange(of: isDeleted) { product in
                            self.productModels = DB_Manager().getYourProducts(accIDValue: userAuth.accID)
                            isDeleted = false
                        }
                        .padding(.bottom, 10)
                    }
                    .padding()
                }
                VStack {
                    Spacer()
                    NavigationLink(destination: AddProductView()) {
                        Text("Sell a new product")
                            .font(.system(size: 20))
                            .bold()
                            .padding()
                            .background(Color(.black))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Your Products")
            // load data from db to product models array
            .onAppear(perform: {
//                DB_Manager().deleteDatabase()
                self.productModels = DB_Manager().getYourProducts(accIDValue: userAuth.accID)
            })
        }
        .accentColor(.black)
    }
}

struct SellProductView_Previews: PreviewProvider {
    static var previews: some View {
        SellProductView()
            .environmentObject(UserAuthModel())
    }
}

struct HiddenNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

extension View {
    func hiddenNavigationBarStyle() -> some View {
        modifier( HiddenNavigationBar() )
    }
}
