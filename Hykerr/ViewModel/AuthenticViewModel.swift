//
//  LoginViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 7/7/22.
//

import Firebase

class AuthenticViewModel: ObservableObject{
    
    @Published var signedIn = false
    @Published var loginUserErrorFeedback = ""
    
   private enum loginError{
        
    }
    
    // Login User
    func loginUser(email: String, password: String){
        
            Auth.auth().signIn(withEmail: email, password: password){[weak self]authResult, error in
                if let e = error{
                    print(e)
                } else{
                    DispatchQueue.main.async {
                        self?.signedIn = true
                    }
                }
            }
    }
    
    func createUserAccount(email: String, password: String){
        
            Auth.auth().createUser(withEmail: email, password: password) {[weak self] authResult, error in
                if let e = error{
                    print(e.localizedDescription)
                }
                else{
                    print("account has been created")
                    DispatchQueue.main.async {
                        self?.signedIn = true
                    }
                }
            }
    }
    
    
    //Send reset request
    func resetUserPassword(_ email: String){
        //TODO set up reset password func
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let e = error{
                print(e.localizedDescription)
                
            }else{
                print("success")
            }
            
        }
    }
    
    func logOut(){
        let firebaseAuth = Auth.auth()
          do{
            try firebaseAuth.signOut()
          }catch let signOutError as NSError {
              return
            print("Error signing out: %@", signOutError)
          }
        self.signedIn = false
    }
    
    
}
