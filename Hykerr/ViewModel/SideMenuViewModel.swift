//
//  SideMenuViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 7/24/22.
//

import Foundation
import Firebase


class SideMenuViewModel: ObservableObject{
    @Published var profileImage = UIImage(systemName: "person.circle")!
    @Published var userName = "User"
    
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
        
        getUserName()
    }
    
    
    func getUserName(){
        
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
                
                guard let firstName = name["first"] as? String else{
                    return
                }
                self.userName = firstName
                
                
            }
        }

        
        
        
        
        
    }
}
