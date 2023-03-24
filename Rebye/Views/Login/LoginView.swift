//
//  LoginView.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/14/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct LoginView: View {
    // Loading Indicator
    @EnvironmentObject var userAuth: UserAuthModel
    
    var body: some View {
        VStack {
            Button {
//                DB_Manager().deleteDatabase()
                userAuth.signIn()
            } label: {
                HStack {
                    Image("google")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 15)
                    Text("Sign in with Google")
                        .font(.headline)
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                }
                .frame(width: 275)
                .padding(13)
                .background(
                    RoundedRectangle(cornerRadius: 45)
                        .strokeBorder(.black, lineWidth: 3)
                        .background(Color.white)
                )
            }
        }
        .overlay(
            ZStack {
                if userAuth.isLoading {
//                    Color.black
//                        .opacity(0.25)
//                        .ignoresSafeArea()
                    ProgressView()
                        .font(.title2)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(15)
                }
            }
        )
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserAuthModel())
    }
}

