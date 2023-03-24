//
//  AccountView.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/1/22.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    
    var body: some View {
        VStack {
            Spacer()
            AsyncImage(url: URL(string: userAuth.profilePicUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 7)
            Text(userAuth.firstName + " " + userAuth.lastName)
                .font(.title)
            Spacer()
            Button {
                userAuth.signOut()
            } label: {
                Text("Logout")
                    .font(.system(size: 20))
                    .bold()
                    .background(Color(.black))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(RoundButton())
            .padding(.bottom)
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(UserAuthModel())
    }
}


