//
//  SearchView.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/17/22.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    @State var productModels: [ProductModel] = [] 
    @State var searchTerm: String = ""
    @State var isFavorite: Bool = false
    var columns = [GridItem(.adaptive(minimum: 140))]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchBarView(searchTerm: $searchTerm)
                    LazyVGrid(columns: columns) {
                        ForEach(self.searchModels) { product in
                            ProductItem(productModel: product, state: $isFavorite, text: "heart")
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(.top, 10)
                    .padding([.bottom, .leading, .trailing])
                }
            }
            .navigationTitle("Search")
            .onAppear(perform: { // get ALL products
                self.productModels = DB_Manager().getProducts(categoryValue: "", genderValue: "All")
            })
        }
    }
    
    var searchModels: [ProductModel] {
        if searchTerm.isEmpty {
            return []
        } else {
            return productModels.filter {
                ($0.name.lowercased().contains(searchTerm.lowercased()) || $0.description.lowercased().contains(searchTerm.lowercased()) || ($0.category?.rawValue.lowercased().contains(searchTerm.lowercased()))! || ($0.gender?.rawValue.lowercased().contains(searchTerm.lowercased()))! )
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(UserAuthModel())
    }
}
