//
//  SignUpView.swift
//  Hykerr
//
//  Created by Corey Edh on 7/4/22.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordCheck: String = ""
    @State private var phoneNumber: String = ""
    @State private var contactNumber: String = ""
    
    @State private var isShowingImagePhotoPicker = false
    @State private var profileImage = UIImage(systemName: "person.circle")!
    
    @State var userHint = ""
    @State private var showUserHint = false
    
    @EnvironmentObject var authenticViewModel : AuthenticViewModel
    
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
                HStack{
              
                    TextField("First Name", text: $firstName)
                        .disableAutocorrection(true)
                        .minimumScaleFactor(0.5)
                    
                    Divider()
                    
                    TextField("Last Name", text:$lastName)
                        .disableAutocorrection(true)
                        .minimumScaleFactor(0.5)
                }
            
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
                
           
                
                
            }.frame(
                width: 350, height: 350, alignment: .center).cornerRadius(40)
            .background()
            
            if showUserHint == true{
                Text(userHint).padding()
            }
            Button("Sign Up"){
                if (password == passwordCheck){
                    authenticViewModel.createUserAccount(email: email, password: password)
                    authenticViewModel.uploadUserProfilePicture(with: profileImage)
                    authenticViewModel.userInfo(name: firstName)
                    //Take user to the next screen
                    
                }else{
                    showUserHint = true
                    userHint = "Passwords do not match"
                }
                
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
