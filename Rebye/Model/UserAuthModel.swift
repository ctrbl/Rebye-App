//
//  UserAuthModel.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/15/22.
//

import SwiftUI
import Firebase
import GoogleSignIn
import Stripe
import FirebaseFunctions
import FirebaseDatabase
import FirebaseFirestore

class UserAuthModel: ObservableObject {
    static let shared = UserAuthModel()
    
    @Published var accID: String = ""
    @Published var customerID: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var profilePicUrl: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    init() {
        check()
    }
            
    func checkStatus() {
        if (GIDSignIn.sharedInstance.currentUser != nil) {
            let user = GIDSignIn.sharedInstance.currentUser
            guard let user = user else { return }
            let firstName = user.profile?.givenName
            let lastName = user.profile?.familyName
            let email = user.profile?.email
            let profilePicUrl = user.profile!.imageURL(withDimension: 100)!.absoluteString
            self.firstName = firstName ?? ""
            self.lastName = lastName ?? ""
            self.email = email ?? ""
            self.profilePicUrl = profilePicUrl
            self.isLoggedIn = true
        } else {
            self.isLoggedIn = false
        }
    }
    
    func check() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
            self.checkStatus()
        }
    }
    
    func signIn() {
        // Google Sign In
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
        
        self.isLoading = true
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: presentingViewController) {[self] user, err in
            
            if let error = err {
                self.isLoading = false
                print (error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                self.isLoading = false
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            // Firebase Auth
            Auth.auth().signIn(with: credential) { result, err in
                self.isLoading = false
                if let error = err {
                    print(error.localizedDescription)
                    return
                }
                
                guard let user = result?.user else {
                    return
                }
                
                self.accID = user.uid
                
                print(user.displayName ?? "Success")
                
                // Updating user as logged in
                withAnimation {
                    self.check()
                }
                
                DB_Manager().registerUser(accIDValue: self.accID, firstNameValue: self.firstName, lastNameValue: self.lastName, emailValue: self.email, profilePicUrlValue: self.profilePicUrl)
                print("CURRENT USER ID:", self.accID)
                
                Firestore.firestore().collection("stripe_customers").document(self.accID).getDocument { (document, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }

                    if let document = document, document.exists {
                        let data = document.data()
                        if let data = data {
                            print("data", data)
                            self.customerID = data["customerID"] as? String ?? ""
                            print(self.customerID)
                        }
                    }
                }
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.checkStatus()
    }
    
    
}

