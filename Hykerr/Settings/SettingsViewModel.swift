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



class SettingsViewModel: ObservableObject{
    
    @Published var profileImage: UIImage?
    @Published var userName: String = ""
    @Published var lastName: String = ""
    @Published var personalNumber: String = ""
    @Published var emergencyNumber: String = ""
    @Published var userEmail: String = ""
    //
    private var userInfo: UserModel?
    private var firebaseManager = FirebaseManager.shared
    
    func getUserPicture(){
        //Only works after the user sign up they exit the app and reopen it
        guard let user = Auth.auth().currentUser else {
            print("getUserPicture didn't get firebase user info right")
            return
        }
        firebaseManager.getFirebaseImage(reference: .user(userID: user.uid)) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.userInfo?.addImage(image: image)
                    self?.updateViewText()
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func getUserInformation(){
        
        guard let user = Auth.auth().currentUser else{ return }
        
        let userData = FirebaseCollection.Users(user: user).documentReference
        
        firebaseManager.getFirebaseDocumentData(for: userData) { result in
            switch result {
            case .success(let userData):
                self.userInfo = UserModel(userData:userData)
                self.getUserPicture()
                DispatchQueue.main.async {
                    self.updateViewText()
                }
                
            case .failure(let failure):
                print(failure)
            }
        }
    }

    func updateUserInformation(){
        guard let user = Auth.auth().currentUser, let userInfo = userInfo else{ print("no user is found"); return }

        var updateData: [String:Any] = [:]
        //Name
        if userName != userInfo.userEmail{ updateData["Name.first"] = userName  }
        if lastName != userInfo.lastName{ updateData["Name.last"] = lastName }
        
        //Phonenumber
        if personalNumber != userInfo.personalNumber{ updateData["PhoneNumber.personal"] = personalNumber }
        if emergencyNumber != userInfo.emergencyNumber{ updateData["PhoneNumber.emergency"] = emergencyNumber }
       
        let documentRefence = FirebaseCollection.Users(user: user).documentReference
        firebaseManager.updateDataInFirebase(at: documentRefence, data: updateData)
        
        getUserInformation()
    }
    
    private func updateViewText(){
        guard let userInfo else { return }
        self.profileImage = userInfo.profileImage ?? UIImage(systemName: "person.circle")!
        self.userName = userInfo.userName
        self.lastName = userInfo.lastName
        self.personalNumber = userInfo.personalNumber
        self.emergencyNumber = userInfo.emergencyNumber
    }
}
