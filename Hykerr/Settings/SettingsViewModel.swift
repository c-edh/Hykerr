//
//  SettingsViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 8/7/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit

struct UserModel{
    var profileImage: UIImage? = nil
    let userName: String
    let lastName: String
    let personalNumber: String
    let emergencyNumber: String
    var userEmail: String? = nil
    
    
    init(userData: [String: Any]) {
        let names = userData["Name"] as! [String: Any]
        self.userName = names["first"] as! String
        self.lastName = names["last"] as! String
        
        let phoneNumbers = userData["PhoneNumber"] as! [String: Any]
        self.personalNumber = phoneNumbers["personal"] as! String
        self.emergencyNumber = phoneNumbers["emergency"] as! String

    //   let userEmail =
    }
    
    mutating func addImage(image: UIImage){
            self.profileImage = image
    }
}

class SettingsViewModel: ObservableObject{
    
    @Published var profileImage: UIImage?
    @Published var userName: String = ""
    @Published var lastName: String = ""
    @Published var personalNumber: String = ""
    @Published var emergencyNumber: String = ""
    @Published var userEmail: String = ""
//
    private var userInfo: UserModel?
        
    private var db = Firestore.firestore()
    
    private var firebaseManager = FirebaseManager.shared

    func getUserPicture(){
            //Only works after the user sign up they exit the app and reopen it
            guard let user = Auth.auth().currentUser else {
                print("getUserPicture didn't get firebase user info right")
                return
            }
        //ID
        firebaseManager.getFirebaseImage(reference: .user(userID: user.uid)) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.userInfo?.addImage(image: image)
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func getUserInformation(){
        
        guard let user = Auth.auth().currentUser else{ return }
        
        let userData = self.db.collection("Users").document(user.uid)
        
        firebaseManager.getFirebaseDocumentData(for: userData) { result in
            switch result {
            case .success(let userData):
                self.userInfo = UserModel(userData:userData)
                self.getUserPicture()
                
            case .failure(let failure):
                print(failure)
            }
        }
        
    }
    private func updateViewText(){
        
        guard let userInfo else { return }
        
        // self.userEmail =
        self.profileImage = userInfo.profileImage ?? UIImage(systemName: "person.circle")!
        self.userName = userInfo.userName
        self.lastName = userInfo.lastName
        self.personalNumber = userInfo.personalNumber
        self.emergencyNumber = userInfo.emergencyNumber
    }
    
    func updateUserInformation(){
     
        guard let user = Auth.auth().currentUser, let userInfo = userInfo else{
                print("no user is found")
                return

            }
        
//Make  Reusable
        if userName != userInfo.userEmail{ updateUserFirstName(user.uid) }
        if lastName != userInfo.lastName{ updateUserFirstName(user.uid) }
        if personalNumber != userInfo.personalNumber{ updateUserPersonalNumber(user.uid) }
        if emergencyNumber != userInfo.emergencyNumber{ updateUserEmergencyNumber(user.uid) }
        
        getUserInformation()
    }
    
    private func updateUserFirstName(_ user: String){
        let documentRefence = self.db.collection("Users").document(user)
        let data: [String:Any] = ["Name.first":userName]
        firebaseManager.updateDataInFirebase(at: documentRefence, data: data)
    }
    
    private func updateUserLastName(_ user: String, dataLocation: [String: Any]){
        let documentRefence = self.db.collection("Users").document(user)
        let data: [String:Any] = ["Name.last":lastName]
        firebaseManager.updateDataInFirebase(at: documentRefence, data: data)
    }
    
    private func updateUserPersonalNumber(_ user: String){
        let documentRefence = self.db.collection("Users").document(user)
        let data: [String:Any] = ["PhoneNumber.personal":personalNumber]
        firebaseManager.updateDataInFirebase(at: documentRefence, data: data)
    }
    
    private func updateUserEmergencyNumber(_ user: String){
        let documentRefence = self.db.collection("Users").document(user)
        let data: [String:Any] = ["PhoneNumber.emergency":emergencyNumber]
        firebaseManager.updateDataInFirebase(at: documentRefence, data: data)
    }
}
