//
//  FirebaseManager.swift
//  Hykerr
//
//  Created by Corey Edh on 3/13/23.


import Firebase
import FirebaseFirestore


class FirebaseManager: FirebaseManagerProtocol{
    
    private let db = Firestore.firestore()
    static let shared = FirebaseManager()
    
    //MARK: - User Authentication to Firebase
    func setUpUser(userInfo: [String:Any]){
        guard let user = Auth.auth().currentUser else{ return }
       // CollectionPaths.UserCollection(.User(user)).documentReference.setData(userInfo)
    }
    
    //MARK: - Uploading to Firebase
    
    func addToFirebase(with reference: DocumentReference, data: [String: Any], completion: @escaping ( Result<String, FirebaseManagerError> ) -> Void){
        guard let user = Auth.auth().currentUser else{ return }
        
        var fireBaseData = data
        fireBaseData["UserID"] = user.uid
        
        reference.setData(fireBaseData){ err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(.failure(.incorrectData))
            }
            else { completion(.success(reference.documentID)) }
        }
    }
    
    func addImageToFireBase(storeAt: ImageStorage, image: UIImage){
        let storageRef = Storage.storage().reference().child(storeAt.reference)
        guard let compressedImage = image.jpegData(compressionQuality: 0.75) else{ return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(compressedImage, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil{ print("Image stored sucessfully") }
            else{ print("Upload fail") }
        }
    }
    
    func updateDataInFirebase(at reference: DocumentReference, data: [String:Any]){
        reference.updateData(data)
    }
    
    //MARK: - Retrieving Data from Firebase
    
    func getFirebaseDataInCollection(for reference: CollectionReference, allowUserData: Bool = false, limitAmount: Int = 10, completion: @escaping (Result<[[String:Any]], FirebaseManagerError>) -> Void){
       // guard let user = Auth.auth().currentUser else{ return }
        var query = reference.limit(to: limitAmount)
       // if !allowUserData{ query = reference.limit(to: limitAmount).whereField("UserID", isNotEqualTo: user.uid ) }
        
        query.getDocuments { (collectionData, error) in
            if let error { completion(.failure(.firebaseError(error))) }
            
            guard let collection = collectionData else{
                completion(.failure(.noData))
                return
            }
            var documentDataArray: [[String:Any]] = []
            for document in collection.documents{
                documentDataArray.append(document.data())
            }
            completion(.success(documentDataArray))
        }
    }
    
    func getFirebaseDocumentData(for reference: DocumentReference, completion: @escaping (Result<[String:Any], FirebaseManagerError>) -> Void){
        reference.getDocument { (document, error) in
            if let error = error{ completion(.failure(.firebaseError(error))) }
            else{
                guard let document = document, let data = document.data() else{
                    completion(.failure(.incorrectData))
                    return
                }
                completion(.success(data))
            }
        }
    }
    
    func getFirebaseImage(reference: ImageStorage , completion: @escaping (Result<UIImage, FirebaseManagerError>) -> Void){
        
        let prayerStoredImageRef =  Storage.storage().reference().child(reference.reference)
        
        prayerStoredImageRef.getData(maxSize: 1*1024*1024) { data, error in
            if let error = error{ completion(.failure(.firebaseError(error))) }
            else{
                guard let data = data, let userStoredImage = UIImage(data: data) else{
                    completion(.failure(.incorrectData))
                    return
                }
                completion(.success(userStoredImage))
            }
        }
    }
}
