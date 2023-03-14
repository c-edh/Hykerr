//
//  SideMenuViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 7/24/22.
//

import Foundation
import Firebase
import FirebaseFirestore


class SideMenuViewModel: ObservableObject{
    @Published var profileImage = UIImage(systemName: "person.circle")!
    @Published var userName = "User"
    
    private var db = Firestore.firestore()
    private let firebaseManager = FirebaseManager()
    
    func getUserPicture(){
        //Only works after the user sign up they exit the app and reopen it
        guard let user = Auth.auth().currentUser else { print("getUserPicture didn't get firebase user info right"); return }
        
        firebaseManager.getFirebaseImage(reference: .user(userID: user.uid)) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            case .failure(let failure):
                print(failure)
            }
        }
        getUserName()
    }
    
    
    func getUserName(){
        
        guard let user = Auth.auth().currentUser else{ return }
        let userData = self.db.collection("Users").document(user.uid)
        
        firebaseManager.getFirebaseDocumentData(for: userData) { result in
            switch result {
            case .success(let data):
                guard let name = data["Name"] as? [String: Any] else{ print("This failed"); return }
                
                guard let firstName = name["first"] as? String else{
                    return
                }
                DispatchQueue.main.async {
                    self.userName = firstName
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
}
