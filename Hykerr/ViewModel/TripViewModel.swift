//
//  TripViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 7/20/22.
//

import SwiftUI
import Firebase


class TripViewModel: ObservableObject{
    
    private var db = Firestore.firestore()
    @Published var trips : [Trip] = []
    
    func getUserTrips(){
        guard let user = Auth.auth().currentUser else{
            print("Error couldnt get current user")
            return
        }
        
        let tripsData = self.db.collection("Users").document(user.uid).collection("Trips").document("Past Trips")
        
        tripsData.getDocument { (document, error) in
            if let document = document, document.exists{
                let tripsDocument = document.get("Past Trips Information")
                
                guard let arrayOfTrips = tripsDocument as? [Any] else{
                    return
                }
                
            
                
                for trip in arrayOfTrips{
                    guard let data = trip as? [String: Any] else{
                        return
                    }
                    print("trip array is being appended too")
                    self.trips.append(Trip(startingLocation: data["Starting City"] as! String, endingLocation: data["Ending City"] as! String,
                                           distance: data["Distance"] as! Double, date: data["Date"] as! String))
                    
                }
                
                
                
            }
        }

    }
    
    
    

}

struct Trip: Identifiable{
    var id = UUID()
    let startingLocation: String
    let endingLocation : String
    let distance : Double
    let date: String
//    let region:MKCoordinateRegion
    let hander: () -> Void = {
        print("Tapped Item")
    }
}
