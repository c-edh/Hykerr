//
//  SignUpViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 7/8/22.
//

import Firebase

class SignUpViewModel: ObservableObject{
    
    func createUserAccount(email: String, password: String){
        
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    
                    //TODO Alert User
                    
                    print(e.localizedDescription)
                }
                else{
                   // let loginViewModel = LoginViewModel()
                  //  loginViewModel.loginUser(email: email, password: password)
                }
            }
        
    }
    
    func uploadUserProfilePic(){
        
    }
    
    func storeUserName(){
        
    }
    
    func storeUserInfo(){
        
    }



}
