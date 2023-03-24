//
//  ContentView.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/1/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn

struct ContentView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    @State private var selection: Tab = .home
    enum Tab {
        case home
        case sell
        case search
        case favorite
        case cart
    }
    
    var body: some View {
        if userAuth.isLoggedIn {
            TabView(selection: $selection) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                    }
                    .tag(Tab.home)
                SellProductView()
                    .tabItem {
                        Image(systemName: "hands.sparkles.fill")
                    }
                    .tag(Tab.sell)
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                    }
                    .tag(Tab.search)
                CartView()
                    .tabItem {
                        Image(systemName: "cart")
                    }
                    .tag(Tab.cart)
                AccountView()
                    .tabItem {
                        Image(systemName: "person")
                    }
            }
            .accentColor(.black)
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserAuthModel())
    }
}
