//
//  LoginViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 7/7/22.
//

import Firebase
import FirebaseFirestore


class AuthenticationViewModel: ObservableObject{
    
    @Published var signedIn = false
    @Published var loginUserErrorFeedback = ""
    
    private var db = Firestore.firestore()
    private let firebaseManager = FirebaseManager.shared
    
  //MARK: - Login to Account
    
    // Login User
    func loginUser(email: String, password: String){
        firebaseManager.firebaseCredential(email: email, password: password) { login in
            switch login{
            case .success(let successful):
                DispatchQueue.main.async { self.signedIn = successful }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Send reset request
    func resetUserPassword(_ email: String){
        //TODO set up reset password func
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let e = error{ print(e.localizedDescription) }
            else{ print("success") }
        }
    }
    
//MARK: - Create Account
    
    func createUserAccount(email: String, password: String){
        firebaseManager.createAccount(email: email, password: password) { result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.signedIn = success
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    
    func userInfo(name: String){
        
        guard let user = Auth.auth().currentUser else{ return }
        
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
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            
            guard let user = user else{ print("Still no user is found"); return }
            guard let reference = self?.db.collection("Users").document(user.uid) else{
                return
            }
            let data = [
                "Name" : ["first": firstName, "last":lastName],
                "PhoneNumber":["personal":phoneNumber,"emergency":userEmergencyContact]
            ]
            
            self?.firebaseManager.addToFirebase(with: reference, data: data, completion: { result in
                switch result {
                case .success(_):
                    print("Successful")
                case .failure(let failure):
                    print(failure)
                }
            })
        }
        
    }
        
    func uploadUserProfilePicture(with image: UIImage ){
        print("UPLOAD USER PROFILE PICTURE HAS STARTED")
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let user else{ print("Still no user is found"); return }
            
            self?.firebaseManager.addImageToFireBase(storeAt: .user(userID: user.uid), image: image)
        }
    }
    
    
//MARK: - LogOut
    
    func logOut(){
        self.signedIn = firebaseManager.logOutFromFirebase()
    }
}
