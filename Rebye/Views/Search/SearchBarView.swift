//
//  SearchBarView.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/17/22.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchTerm: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search for products by keyword", text: $searchTerm)
                .disableAutocorrection(true)
                .overlay(
                    Image(systemName: "xmark.circle")
                        .padding()
                        .offset(x: 10)
                        .foregroundColor(.black)
                        .opacity(searchTerm.isEmpty ? 0.0 : 1.0)
                        .onTapGesture { searchTerm = "" }
                    , alignment: .trailing
                )
        }
        .font(.system(size: 20))
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 10, x: 0, y: 0)
        )
        .padding([.leading, .trailing], 20)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    @State static var text: String = ""
    static var previews: some View {
        SearchBarView(searchTerm: $text)
    }
}
