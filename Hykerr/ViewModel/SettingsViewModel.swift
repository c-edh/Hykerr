//
//  SettingsViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 8/7/22.
//

import Foundation
import Firebase
import UIKit

class SettingsViewModel: ObservableObject{
    
    @Published var profileImage = UIImage(systemName: "person.circle")!
    @Published var userName: String = ""
    @Published var lastName: String = ""
    @Published var personalNumber: String = ""
    @Published var emergencyNumber: String = ""
    @Published var userEmail: String = ""
    
    private var userInformation: [String:String] = [:]
    
    private var db = Firestore.firestore()
    

    
    
    
    func getUserPicture(){
            //Only works after the user sign up they exit the app and reopen it
            
            guard let user = Auth.auth().currentUser else {
                print("getUserPicture didn't get firebase user info right")
                return
            }
            
        

            let userStoredImageRef =  Storage.storage().reference().child("user/\(user.uid)")
            
            userStoredImageRef.getData(maxSize: 1*1024*1024) { data, error in
                if let error = error{
                    print(error.localizedDescription, "Error has occured, default image is displayed")
                }else{
                    let userStoredImage = UIImage(data: data!)
                    self.profileImage = userStoredImage!

                }
            }

    }
    
    func getUserInformation(){
        
        guard let user = Auth.auth().currentUser else{
            return
            
        }
        
        let userData = self.db.collection("Users").document(user.uid)
        
        userData.getDocument { (document, error) in
            if let document = document, document.exists{
                guard let name = document.get("Name") as? [String: Any] else{
                    print("This failed")
                    return
                }
                
                guard let phoneNumbers = document.get("PhoneNumber") as? [String: Any] else{
                    print("retriving phonenumbers failed")
                    return
                }
                
                guard let personalNumber = phoneNumbers["personal"] as? String else{
                    return
                }
                
                guard let emergencyNumber = phoneNumbers["emergency"] as? String else{
                    return
                }
                
                guard let firstName = name["first"] as? String else{
                    return
                }
                
                guard let lastName = name["last"] as? String else{
                    return
                }
                
                print(firstName)
                print(personalNumber)
                print(emergencyNumber)
                self.userEmail = user.email!
                self.userName = firstName
                self.lastName = lastName
                self.personalNumber = personalNumber
                self.emergencyNumber = emergencyNumber
                
                self.userInformation["email"] = user.email!
                self.userInformation["firstName"] = firstName
                self.userInformation["lastName"] = lastName
                self.userInformation["personalNumber"] = personalNumber
                self.userInformation["emergencyNumber"] = emergencyNumber
                
                
            }
        }
        
    }
    
    func updateUserInformation(){
     
        guard let user = Auth.auth().currentUser else{
                print("no user is found")
                return

            }
        
        if userName != userInformation["firstName"]{
            updateUserFirstName(user.uid)
            userInformation["firstName"] = userName
        }
        
        if lastName != userInformation["lastName"]{
            updateUserFirstName(user.uid)
            userInformation["lastName"] = lastName
        }
        
        if personalNumber != userInformation["personalNumber"]{
            updateUserPersonalNumber(user.uid)
            userInformation["personalNumber"] = personalNumber
        }
        
        if emergencyNumber != userInformation["emergencyNumber"]{
            updateUserEmergencyNumber(user.uid)
            userInformation["emergencyNumber"] = emergencyNumber
        }
            
    }
    
    private func updateUserFirstName(_ user: String){
        self.db.collection("Users").document(user).updateData(["Name.first":userName])
    }
    
    private func updateUserLastName(_ user: String){
        self.db.collection("Users").document(user).updateData(["Name.last":lastName])
    }
    
    private func updateUserPersonalNumber(_ user: String){
        self.db.collection("Users").document(user).updateData(["PhoneNumber.personal":personalNumber])
    }
    
    private func updateUserEmergencyNumber(_ user: String){
        self.db.collection("Users").document(user).updateData(["PhoneNumber.emergency":emergencyNumber])
    }
    

    
    
    
}
