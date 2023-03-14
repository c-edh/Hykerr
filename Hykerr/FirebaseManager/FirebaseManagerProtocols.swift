//
//  FirebaseManagerProtocols.swift
//  Hykerr
//
//  Created by Corey Edh on 3/13/23.
//

import Foundation

//MARK: - Protocols

import FirebaseAuth
import FirebaseFirestore.FIRDocumentSnapshot

protocol FirebaseManagerProtocol: AuthenticationProtocol, UploadDataProtocol, GetDataProtocol{
    static var shared: FirebaseManager { get }
}

protocol AuthenticationProtocol{
    func createAccount(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func firebaseCredential(email: String, password: String, loginCompletion: @escaping (Result<Bool,Error>)->())
    func logOutFromFirebase() -> Bool
}

extension AuthenticationProtocol{
    func firebaseCredential(email: String, password: String, loginCompletion: @escaping (Result<Bool,Error>)->()){
        Auth.auth().signIn(withEmail: email, password: password){authResult, error in
            if let e = error{ loginCompletion(.failure(e)) }
            else{ loginCompletion(.success(true)) }
        }
    }
    
    func createAccount(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) {authResult, error in
            if let e = error{ completion(.failure(e)) }
            else{
                completion(.success(true))
            }
        }
    }
    
    func logOutFromFirebase() -> Bool{
        let firebaseAuth = Auth.auth()
        do{
            try firebaseAuth.signOut()
            return true
        }catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            return false
        }
    }
}

protocol UploadDataProtocol{
    func addToFirebase(with reference: DocumentReference, data: [String: Any], completion: @escaping ( Result<String, FirebaseManagerError> ) -> Void)
    func updateDataInFirebase(at reference: DocumentReference, data: [String:Any])
    func addImageToFireBase(storeAt: ImageStorage, image: UIImage)
}

protocol GetDataProtocol{
    func getFirebaseDataInCollection(for reference: CollectionReference, allowUserData: Bool, limitAmount: Int, completion: @escaping (Result<[[String:Any]], FirebaseManagerError>) -> Void)
    func getFirebaseDocumentData(for reference: DocumentReference, completion: @escaping (Result<[String:Any], FirebaseManagerError>) -> Void)
    func getFirebaseImage(reference: ImageStorage, completion: @escaping (Result<UIImage, FirebaseManagerError>) -> Void)
}

