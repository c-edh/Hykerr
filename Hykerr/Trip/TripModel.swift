//
//  TripModel.swift
//  Hykerr
//
//  Created by Corey Edh on 3/13/23.
//

import Foundation

struct Trip: Identifiable{
    let id = UUID()
    let startingLocation: String
    let endingLocation : String
    let distance : Double
    let date: String
    let coords: [Any]
    
    init(documentReference: [String: Any]) {
        self.startingLocation = documentReference["Starting City"] as! String
        self.endingLocation =  documentReference["Ending City"] as! String
        self.distance = documentReference["Distance"] as! Double
        self.date = documentReference["Date"] as! String
        self.coords = documentReference["Coords in Trip"] as! [Any]
    }
    
    let hander: () -> Void = {
        print("Tapped Item")
    }
}
