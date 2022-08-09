//
//  LoginView.swift
//  Hykerr
//
//  Created by Corey Edh on 7/4/22.
//

import SwiftUI
import FirebaseAuth


struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var forgotPassword = false
    
    @EnvironmentObject var authenticViewModel: AuthenticViewModel
    
    var body: some View {
            if !authenticViewModel.signedIn{
                VStack{
                    HStack {
                        Image("hykerrLogo").resizable().frame(width: 100, height: 100)
                        Text("Hykerr").font(.largeTitle).fontWeight(.heavy)
                    }.frame(width: 300, height: 100, alignment: .leading)
                    
                    Form{
                        TextField("Email",text: $email).disableAutocorrection(true).textInputAutocapitalization(.never)
                        
                        if !forgotPassword{
                            SecureField("Password",text: $password).disableAutocorrection(true).textInputAutocapitalization(.never)
                        }

                        
                    }.frame(width: 350, height: forgotPassword ? 115 : 160, alignment: .center).cornerRadius(35)
                    
                    
                        Button(forgotPassword ? "Reset Password" : "Login"){
                            guard !email.isEmpty else{
                                return
                            }
                            if forgotPassword{
                                //Send email to firebase
                                authenticViewModel.resetUserPassword(email)
                                
                                
                            }else{
                                //Login User with email and password
                                guard !password.isEmpty else{
                                    return
                                }
                                authenticViewModel.loginUser(email: email, password: password)
     
                                
                            }
                            
                        }.frame(width: 200, height: 50, alignment: .center)
                        .background(K.color.button.buttonColor)
                        .foregroundColor(K.color.button.buttonTextColor)
                        .cornerRadius(20).padding(20)
                    
                    Button(forgotPassword ? "Remembered Password?" : "Forgot Password?"){
                        withAnimation(.easeInOut) {forgotPassword.toggle()}}.foregroundColor(K.color.Text.textColor)
                    
                }
                
                
            }
//        else{
//                MainView().navigationBarBackButtonHidden(true)
//            }
        
        
    }
    
}




struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(AuthenticViewModel())
    }
}
