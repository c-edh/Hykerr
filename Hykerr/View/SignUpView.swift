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
    
    var body: some View {
        
        VStack{
            Text("Hykerr").font(.largeTitle).fontWeight(.heavy).padding(.bottom, 30)
            
            Button(action:{
                print("hi")
            },label: {  Image(systemName: "person.circle")
                    .resizable().frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.blue)})
            Text("Choose Image")

            
            Form{
              
            
                
                TextField("Enter Email",
                          text: $email)
                
                SecureField("Enter Password",
                            text: $password)
                
                SecureField("Re-Enter Password",
                            text: $passwordCheck)
                
                TextField("Enter Phone Number",
                          text: $phoneNumber )
                
                TextField("Enter Emergency Contact Number",
                          text: $contactNumber)
                
    //            TextField("Enter PhoneNumber",
    //                      value: $phoneNumber, formatter: .phone)
//
            }.frame(
                width: 350, height: 350, alignment: .center).cornerRadius(40)
            .background()
            Button("Sign Up"){
                
            }.frame(width: 200, height: 50, alignment: .center).foregroundColor(.white).background(.blue).cornerRadius(20).padding(.top, 20).padding(.bottom,15)
            
            
        }
        
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
