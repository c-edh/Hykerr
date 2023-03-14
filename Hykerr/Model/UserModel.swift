//
//  UserModel.swift
//  Hykerr
//
//  Created by Corey Edh on 3/13/23.
//

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
