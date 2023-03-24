//
//  FilterButton.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/16/22.
//

import SwiftUI

struct FilterButton: View {
    @Binding var isSelected: Bool
    @State var text: String
    var body: some View {
        if isSelected {
            Button {
            } label: {
                Text(text)
                    .frame(width: 60, height: 2)
            }
            .buttonStyle(RoundButton())
            .allowsHitTesting(true)
        } else {
            Button {
                isSelected = true 
            } label: {
                Text(text)
                    .frame(width: 60, height: 2)
            }
            .buttonStyle(UnselectedRoundButton())
            .allowsHitTesting(true)
        }
    }
}

struct FilterButton_Previews: PreviewProvider {
    @State static var status: Bool = false
    static var previews: some View {
        FilterButton(isSelected: $status, text: "All")
    }
}
