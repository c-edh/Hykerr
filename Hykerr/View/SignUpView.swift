//
//  SignUpView.swift
//  Hykerr
//
//  Created by Corey Edh on 7/4/22.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordCheck: String = ""
    @State private var phoneNumber: String = ""
    @State private var contactNumber: String = ""
    
    @State private var isShowingImagePhotoPicker = false
    @State private var profileImage = UIImage(systemName: "person.circle")!
    
    @EnvironmentObject var signUpViewModel : SignUpViewModel
    
    var body: some View {
        
        VStack{
            Text("Hykerr").font(.largeTitle).fontWeight(.heavy).padding( 30)
            
            Button(action:{isShowingImagePhotoPicker = true},
                   label: {
                Image(uiImage: profileImage)
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center).cornerRadius(100).shadow(color: .black, radius: 2, y:3)
                //Keep shadow???, adjust x value?
            })
            Text("Choose Image")

            
            Form{
              
            
                
                TextField("Enter Email",
                          text: $email).disableAutocorrection(true).textInputAutocapitalization(.never)
                
                SecureField("Enter Password",
                            text: $password).disableAutocorrection(true).textInputAutocapitalization(.never)
                
                SecureField("Re-Enter Password",
                            text: $passwordCheck).disableAutocorrection(true).textInputAutocapitalization(.never)
                
                TextField("Enter Phone Number",
                          text: $phoneNumber ).keyboardType(.phonePad)
                
                TextField("Enter Emergency Contact Number",
                          text: $contactNumber).keyboardType(.phonePad)
                
    //            TextField("Enter PhoneNumber",
    //                      value: $phoneNumber, formatter: .phone)
//
            }.frame(
                width: 350, height: 350, alignment: .center).cornerRadius(40)
            .background()
            Button("Sign Up"){
                
            }.frame(width: 200, height: 50, alignment: .center).foregroundColor(K.color.button.buttonTextColor).background(K.color.button.buttonColor).cornerRadius(20).padding(.top, 20).padding(.bottom,15)
            
            
        }.sheet(isPresented: $isShowingImagePhotoPicker, content: {
            PhotoPicker(profileImage: $profileImage)
        })
        
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
