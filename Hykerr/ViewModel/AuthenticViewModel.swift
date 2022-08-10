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
    
    private var db = Firestore.firestore()
    
   private enum loginError{
        
    }
    
  //MARK: - Login to Account
    
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
    
//MARK: - Create Account
    
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
    
    
    func userInfo(name: String){
        
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        
        changeRequest.commitChanges { error in
            if error == nil{
                print("changes have been made")
            }
        
        
        
        }
        
    }
    
    //MARK: - Uploading User Data
    
    func uploadUserPersonalInfo(firstName: String, lastName: String, phoneNumber: String, userEmergencyContact: String){
        Auth.auth().addStateDidChangeListener { auth, user in
          // ...
            guard let user = user else{
                print("Still no user is found")
                return

            }
            self.db.collection("Users").document(user.uid).setData([
                "Name" : ["first": firstName, "last":lastName],
                "PhoneNumber":["personal":phoneNumber,"emergency":userEmergencyContact]
            ])
            
            
            
        }
        
    }
        
    func uploadUserProfilePicture(with image: UIImage ){
        print("UPLOAD USER PROFILE PICTURE HAS STARTED")
        
        
        Auth.auth().addStateDidChangeListener { auth, user in
          // ...
            guard let user = user else{
                print("Still no user is found")
                return
            }
        
        //Where in firebase it will be stored
        let storageRef = Storage.storage().reference().child("user/\(user.uid)")
        
        //Image -> Data
        guard let compressedImage = image.jpegData(compressionQuality: 0.75) else{
            
            print("FAILED TO COMPRESS")
            return
        }
        
        //Type of Data being stored
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        //Stores the data (the image) as a image/jpeg in the firebase storage
        storageRef.putData(compressedImage, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil{
                
                print("Image stored sucessfully")
                
                storageRef.downloadURL{ url, error in
                  //  completion(url)
                    
                    let changeRequest = user.createProfileChangeRequest()
                   // changeRequest.displayName = self.userNameTextField.text ?? "User"
                    changeRequest.photoURL = url
                    
                    changeRequest.commitChanges { error in
                        if error == nil{
                            print("changes have been made")
                        }
                    }
                }
            }else{
                print(error?.localizedDescription)
                print("Upload fail")
            }
        }}
        
        
        
    }
    
    
//MARK: - LogOut
    
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
