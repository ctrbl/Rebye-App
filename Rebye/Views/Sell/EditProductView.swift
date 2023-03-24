//
//  EditProductView.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/15/22.
//

// return productModel.image if self.image is nil
// update productModel.gender with self.gender (SAME FOR CATEGORY)

import SwiftUI

struct EditProductView: View {
    @State var productModel: ProductModel

    @State var gender: String = ""
    @State var category: String = ""
    @State private var isShowPhotoLibrary = false
    @State private var image = UIImage()
    
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 6) {
                Group {
                    Text("Name").font(.headline)
                        .padding(.top)
                    TextField("Enter product name", text: $productModel.name)
                        .textInputAutocapitalization(.words)
                        .textFieldStyle(Rebye.textFieldStyle())
                        .disableAutocorrection(true)
                }
                Group {
                    Text("Clothing Type").font(.headline)
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
                        Text("Category").font(.headline)
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
                        .font(.headline)
                        .padding(.top)
                    if !imageIsNotNull(image: self.image) {
                        HStack(alignment: .center, spacing: 15) {
                            Image(uiImage: productModel.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120)
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
                    }
                }
                Group {
                    Text("Description")
                        .font(.headline)
                        .padding(.top)
                    TextField("Enter product description", text: $productModel.description)
                        .textFieldStyle(Rebye.textFieldStyle())
                        .disableAutocorrection(true)
                }
                Group {
                    Text("Inventory")
                        .font(.headline)
                        .padding(.top)
                    TextField("Amount of products available", value: $productModel.inventory, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .textFieldStyle(Rebye.textFieldStyle())
                }
                Group {
                    Text("Price")
                        .font(.headline)
                        .padding(.top)
                    TextField("Price of product", value: $productModel.price, formatter: numberFormatter)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(Rebye.textFieldStyle())
                }
            }
            .sheet(isPresented: $isShowPhotoLibrary) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
            }
            .frame(maxWidth: .infinity)
            .onAppear(perform: {
                self.gender = productModel.gender?.rawValue ?? ""
                self.category = productModel.category?.rawValue ?? ""
            })
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                var base64 = productModel.image.base64!
                if imageIsNotNull(image: self.image) {
                    base64 = self.image.base64!
                }
                DB_Manager().updateProduct(pidValue: productModel.pid, nameValue: productModel.name, categoryValue: self.category, genderValue: self.gender, descriptionValue: productModel.description, inventoryValue: productModel.inventory, priceValue: productModel.price, imageValue: base64)
                self.mode.wrappedValue.dismiss()
            } label: {
                Text("Save").font(.headline)
            }
        }
    }
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView(productModel: DB_Manager().getYourProducts(accIDValue: UserAuthModel().accID)[0])
    }
}
