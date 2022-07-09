//
//  AccountManager.swift
//  Hyker
//
//  Created by Corey Edh on 4/15/22.
//

import Foundation
import Firebase

class AccountManager: ObservableObject{
    
    
    ///MARK: - create, login, reset
    
    func createUserAccount(email: String, password: String, name: String, personal personalNumber: String, emergency emergencyNumber: String?, userImage : UIImageView?, completion: @escaping((_ accountCreated: Bool, _ errorCode : String)->())){
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    print(e.localizedDescription)
                    completion(false, "Error, incorrect or empty fields")
                }
                else{
                    completion(true, "User's Account has been made")
                }
            }
        
 
        //Store user's name, contact information;
        
        
        
        
        //Store picture(to firebase and local device to save data)
        if let userImage = userImage {
            uploadUserProfileImage(userProfilePicture: userImage) { url in
             print("url")// What does URL DO? TODO CHECK function
            }
        }else{
            //Set user's image to default and upload it with uploadUserProfileImage
        }
        

    }
    
    //
    func usersPersonalDataToFireBase(){
        //Gets
    }
    
    
    
    func uploadUserProfileImage(userProfilePicture : UIImageView, completion: @escaping((_ url : URL?) -> ())){
        guard let userID = Auth.auth().currentUser?.uid else{
            return
        }
        
        let storageRef = Storage.storage().reference().child("user/\(userID)")
        
    
        guard let compressedImage = userProfilePicture.image!.jpegData(compressionQuality: 0.75) else{
            return
        }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(compressedImage, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil{
                print("Image stored sucessfully")
                storageRef.downloadURL{ url, error in
                    completion(url)
                }
            }else{
                completion(nil)
            }
        }
        
        
    }
    
    
  
    
    
    
    //When user forgets their password
    func resetUserPassword(_ email: String){
        //TODO set up reset password func
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let e = error{
                print(e.localizedDescription)
                
            }else{
                print("success")
                print(email)
            }
            
        }
    }
    
    ///MARK: - Update
    func updateUserInfo(){
        //Updates user info in the firebase data base
        
        //User DB stores: name, phonenumber, emergency contact
        
    }
    
    func updateUserPicture(_ user : String?, completion: @escaping((_ userStoredImage : UIImage?) -> ())){
        
        guard let user = user else {
            print("getUserPicture didn't get firebase user info right")
            return
        }
        
    

        let userStoredImageRef =  Storage.storage().reference().child("user/\(user)")
        
        userStoredImageRef.getData(maxSize: 1*1024*1024) { data, error in
            if let error = error{
                print(error, "Error has occured, default image is displayed")
                completion(nil)
            }else{
                let userStoredImage = UIImage(data: data!)
                completion(userStoredImage)
            }
        }
    }

    
    
    
}
