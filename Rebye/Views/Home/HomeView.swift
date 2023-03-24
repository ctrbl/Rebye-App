//
//  HomeView.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/16/22.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    @State var productModels: [ProductModel] = []
    @State var isModified: Bool = false
    @State var getCategory: String = ""
    @State var getGender: String = "All"
    @State var isFavorite: Bool = false
    @State var searchTerm: String = ""
    var columns = [GridItem(.adaptive(minimum: 140))]
    
    @State private var genders: [String: Bool] = ["All": true, "Women": false, "Men": false, "Unisex": false]
    let genders_keys: [String] = ["All", "Women", "Men", "Unisex"]
    func genderSetFalse(key: String) {
        for i in (0..<genders_keys.count) {
            if genders_keys[i] != key {
                genders[genders_keys[i]] = false
            }
        }
    }
    func genderBinding(for key: String) -> Binding<Bool> {
        return Binding(get: {
            return self.genders[key] ?? false
        }, set: {
            self.genders[key] = $0
            if $0 == true {
                getGender = key
                genderSetFalse(key: key)
            }
        })
    }
    
    @State private var categories: [String: Bool] = ["Tops": false, "Bottoms": false, "Accessories": false, "Shoes": false, "Bags": false]
    func categorySetFalse(key: String) {
        for c in ProductModel.Category.allCases {
            if c.rawValue != key {
                categories[c.rawValue] = false
            }
        }
    }
    func categoryBinding(for key: String) -> Binding<Bool> {
        return Binding(get: {
            return self.categories[key] ?? false
        }, set: {
            self.categories[key] = $0
            if $0 == true {
                getCategory = key
                categorySetFalse(key: key)
            } else {
                getCategory = ""
            }
        })
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack (spacing: 5) {
                    ForEach (self.genders_keys, id: \.self) { key in
                        FilterButton(isSelected: genderBinding(for: key), text: key)
                    }
                }.padding(.top, 7)
//                    Text("Category")
//                        .padding(.top, 7)
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach (ProductModel.Category.allCases, id: \.self) { key in
                            CategoryButton(isSelected: categoryBinding(for: key.rawValue), text: key.rawValue)
                        }
                        .onChange(of: self.genders) { product in
                            self.productModels = DB_Manager().getProducts(categoryValue: self.getCategory, genderValue: self.getGender)
                        }
                        .onChange(of: self.categories) {product in
                            self.productModels = DB_Manager().getProducts(categoryValue: self.getCategory, genderValue: self.getGender)
                        }
                    }
                    .padding([.leading, .trailing], 20)
                }
                .padding([.top, .bottom], 7)
                ScrollView (.vertical) {
                    LazyVGrid(columns: columns) {
                        ForEach(self.productModels) { product in
                            NavigationLink {
                                ProductDisplay(productModel: product, isModified: $isModified)
                            } label: {
                                ProductItem(productModel: product, state: $isFavorite, text: "plus")
//                                    .environmentObject(cart_Manager)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .padding([.bottom, .leading, .trailing])
                }
                .padding(.bottom)
            }
            .navigationTitle("Hello \(userAuth.firstName)!")
            .onAppear(perform: {
                self.productModels = DB_Manager().getProducts(categoryValue: self.getCategory, genderValue: self.getGender)
            })
            }
        }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserAuthModel())
    }
}
