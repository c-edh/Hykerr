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
                self.userName = firstName
                self.lastName = lastName
                self.personalNumber = personalNumber
                self.emergencyNumber = emergencyNumber
                
                
            }
        }
        
    }
    
    func updateUserInformation(){
     
        guard let user = Auth.auth().currentUser else{
                print("Still no user is found")
                return

            }
        
        print(emergencyNumber)
        
        self.db.collection("Users").document(user.uid).updateData([
                "Name" : ["first": userName, "last":lastName],
                "PhoneNumber":["personal":personalNumber,"emergency":emergencyNumber]
        ])
            
    }
    

    
    
    
}
