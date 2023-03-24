//
//  AddProductView.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/1/22.
//

import SwiftUI

struct AddProductView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    
    // create variables to store user input
    @State var name: String = ""
    @State var category: String = "Tops"
    @State var gender: String = "Women"
    @State var description: String = ""
    @State var inventory: String = ""
    @State var price: String = ""
    
    // to go back to homescreen when product is added
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State var showAlert: Bool = false
    
    @State private var isShowPhotoLibrary = false
    @State private var image = UIImage()
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 6) {
                Group {
                    Text("Name").font(.system(size: 18)).bold()
                        .padding(.top)
                    TextField("Enter product name", text: $name)
                        .textInputAutocapitalization(.words)
                        .textFieldStyle(Rebye.textFieldStyle())
                        .disableAutocorrection(true)
                }
                Group {
                    Text("Clothing Type").font(.system(size: 18)).bold()
                        .padding(.top)
                    Picker("Clothing Type", selection: $gender) {
                        ForEach(ProductModel.Gender.allCases, id: \.self) { g in
                            Text(g.rawValue).tag(g.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                }
                Group {
                    HStack {
                        Text("Category").font(.system(size: 18)).bold()
                            .padding(.top, 20)
                        Spacer()
                        Button{}
                        label: {
                            Picker("Category", selection: $category) {
                                ForEach(ProductModel.Category.allCases, id: \.self) { c in
                                    Text(c.rawValue).tag(c.rawValue)
                                }
                            }
                            .accentColor(.white)
                            .frame(width: 100, height: 15)
                        }
                        .padding(.top, 20)
                        .buttonStyle(RoundButton())
                    }
                    .frame(width: 300, height: 50)
                }
                Group {
                    Text("Image")
                        .font(.system(size: 18)).bold()
                        .padding(.top)
                    if imageIsNotNull(image: self.image) {
                        HStack(alignment: .center, spacing: 15) {
                            Image(uiImage: self.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120)
                                .cornerRadius(10)
                            Button(action: {
                                self.isShowPhotoLibrary = true
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 20))
                 
                                    Text("Photo library")
                                        .font(.headline)
                                }
                            }
                            .buttonStyle(RoundButton())
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.isShowPhotoLibrary = true
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 20))
                 
                                    Text("Photo library")
                                        .font(.headline)
                                }
                                .frame(width: 150)
                            }
                            .buttonStyle(RoundButton())
                            Spacer()
                        }
                        .frame(width: 300)
                    }
                }
                Group {
                    Text("Description")
                        .font(.system(size: 18)).bold()
                        .padding(.top)
                    TextField("Enter product description", text: $description)
                        .textFieldStyle(Rebye.textFieldStyle())
                        .disableAutocorrection(true)
                }
                Group {
                    Text("Inventory")
                        .font(.system(size: 18)).bold()
                        .padding(.top)
                    TextField("Amount of products available", text: $inventory)
                        .keyboardType(.numberPad)
                        .textFieldStyle(Rebye.textFieldStyle())
                }
                Group {
                    Text("Price")
                        .font(.system(size: 18)).bold()
                        .padding(.top)
                    TextField("Price of product", text: $price)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(Rebye.textFieldStyle())
                }
            }
            // button to add product for sale
            Button (action: {
                if self.name == "" || self.description == "" || Int(self.inventory) == 0 || Double(self.price) == 0.0 { showAlert.toggle() }
                else {
                    let base64 = self.image.base64!
                    // call function to add entry in sqlite db
                    DB_Manager().addProduct(sellerIDValue: userAuth.accID, nameValue: self.name, categoryValue: self.category, genderValue: self.gender, descriptionValue: self.description, inventoryValue: Int(self.inventory) ?? 0, priceValue: Double(self.price) ?? 0.0, imageValue: base64)
                    print("CURRENT USER ID: ", userAuth.accID)
                    self.mode.wrappedValue.dismiss()
                }
            }, label: {
                Text("Sell Product")
                    .foregroundColor(.white)
                    .font(.system(size: 18)).bold()
                    .frame(width: 150)
//                    .font(.system(size: 20))
//                    .bold()
            })
            .frame(maxWidth: .infinity)
            .buttonStyle(RoundButton())
            .padding(.top, 20)
            Spacer()
        }
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
        .alert("Please complete all fields", isPresented: $showAlert) {
            Button (role: .cancel) {
                showAlert.toggle()
            } label: {
                Text("Dismiss")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductView()
            .environmentObject(UserAuthModel())
    }
}

