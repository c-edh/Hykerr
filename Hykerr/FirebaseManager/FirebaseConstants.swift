//
//  FirebaseConstants.swift
//  Hykerr
//
//  Created by Corey Edh on 3/13/23.
//

import Firebase

//MARK: - Constants

enum FirebaseManagerError: Error{
    case firebaseError(Error)
    case incorrectData
    case noData
        
    var toString: String{
        switch self {
        case .firebaseError(let error):
            return "Error with Firebase: \(error)"
        case .incorrectData:
            return "Incorrect Data"
        case .noData:
            return "No Data"
        }
    }
}

enum ImageStorage{
    case user(userID: String)
    
    var reference: String{
        switch self {
        case .user(let userID):
            return "Users/ProfileImage/\(userID)"
        }
    }
}


enum FirebaseCollection{
    case Users(user: User)
    case Emergency
    
     var documentReference: DocumentReference{
        let db = Firestore.firestore()
        switch self {
        case .Users(let user):
            return db.collection("Users").document(user.uid)
        case .Emergency:
            return db.collection("Emergency").document()
        }
    }
    
     var collectionReference: CollectionReference{
        let db = Firestore.firestore()
        switch self {
        case .Users(_):
            return db.collection("Users")
        case .Emergency:
            return db.collection("Emergency")
        }
        
    }
    
    enum TripsCollection{
        case Current(user: User)
        case Past(user: User, tripID: String? = nil)
        
        var tripDocuments: DocumentReference{
            let db = Firestore.firestore()
            switch self{
            case .Current(let user):
                return db.collection("Users").document(user.uid).collection("Current Trip").document()
            case .Past(let user, let tripID):
                guard let tripID else { preconditionFailure("NO TRIP ID FAILURE") }
                return db.collection("Users").document(user.uid).collection("Past Trips").document(tripID )
            }
        }
        
        var tripCollections: CollectionReference{
            let db = Firestore.firestore()
            switch self{
            case .Current(let user):
                return db.collection("Users").document(user.uid).collection("Current Trip")
            case .Past(let user, _):
                return db.collection("Users").document(user.uid).collection("Past Trips")
            }
        }
    }
    
}

