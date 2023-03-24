//
//  CategoryButton.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/16/22.
//

import SwiftUI

struct CategoryButton: View {
    @Binding var isSelected: Bool
    @State var text: String
    var body: some View {
        if isSelected {
            Button {
                isSelected = false
            } label: {
                VStack {
                    Image(text + "_sel")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .scaledToFit()
                    Text(text)
                }
            }.buttonStyle(UnselectedRoundButton())
        } else {
            Button {
                isSelected = true
            } label: {
                VStack {
                    Image(text)
                        .resizable()
                        .frame(width: 35, height: 35)
                        .scaledToFit()
                    Text(text)
                }
            }.buttonStyle(UnselectedRoundButton())
        }
    }
}

struct CategoryButton_Previews: PreviewProvider {
    @State static var status: Bool = false
    static var previews: some View {
        CategoryButton(isSelected: $status, text: "Tops")
    }
}
