//
//  Helpers.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/20/22.
//

import SwiftUI

struct Helpers: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct Helpers_Previews: PreviewProvider {
    static var previews: some View {
        Helpers()
    }
}

struct RoundButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(.black))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct UnselectedRoundButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.black)
            .overlay(
                RoundedRectangle(cornerRadius: 46)
                    .strokeBorder(.black, lineWidth: 2)
            )
    }
}

struct textFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color(.white))
            .cornerRadius(20)
            .frame(width: 300, height: 50)
            .shadow(radius: 5)
    }
}

func imageIsNotNull(image : UIImage) -> Bool
{

   let size = CGSize(width: 0, height: 0)
   if (image.size.width == size.width)
    {
        return false
    }
    else
    {
        return true
    }
}

extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
}

extension String {
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
