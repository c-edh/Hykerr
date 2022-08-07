//
//  TripViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 7/20/22.
//

import SwiftUI
import Firebase
import MapKit


class TripViewModel: ObservableObject{
    
    private var db = Firestore.firestore()
    @Published var trips : [Trip] = []
    @Published var mapTripCoords : [CLLocationCoordinate2D]?
    
    func getUserTrips(){
        guard let user = Auth.auth().currentUser else{
            print("Error couldnt get current user")
            return
        }
        
        let tripsData = self.db.collection("Users").document(user.uid).collection("Trips").document("Past Trips")
        
        tripsData.getDocument { (document, error) in
            if let document = document, document.exists{
                guard let arrayOfTrips = document.get("Past Trips Information") as? [Any] else{
                    return
                }
                
//                guard let arrayOfTrips = tripsDocument as? [Any] else{
//                    return
//                }
//
            
                
                for trip in arrayOfTrips{
                    guard let data = trip as? [String: Any] else{
                        return
                    }
                    print("trip array is being appended too")
                    self.trips.append(Trip(startingLocation: data["Starting City"] as! String, endingLocation: data["Ending City"] as! String,
                                           distance: data["Distance"] as! Double, date: data["Date"] as! String, coords: data["Coords in Trip"] as! [Any]))
                
            
                }
                
                
                
            }
        }

    }
    
    func getCoords(coords: [Any]){
        var tripCoords : [CLLocationCoordinate2D] = []
        
        
        for coord in coords {
            let coordDictionary = coord as! [String:Any]
            tripCoords.append(CLLocationCoordinate2D(latitude: Double(coordDictionary["Lat"] as! String)!,
                                                     longitude: Double(coordDictionary["Long"] as! String)!
                                                    ))
            
        }
                    
        
        self.mapTripCoords = tripCoords
                    
    }
    
    
    

}

struct Trip: Identifiable{
    var id = UUID()
    let startingLocation: String
    let endingLocation : String
    let distance : Double
    let date: String
    let coords: [Any]
    
    let hander: () -> Void = {
        print("Tapped Item")
    }
}


//MARK: - MapView

struct TripView: UIViewRepresentable{
    func makeCoordinator() -> Coordinator {
        return TripView.Coordinator()
    }
    
    
    //@Binding var region : MKCoordinateRegion
    @Binding var coordsInTrip : [CLLocationCoordinate2D]?

    let mapViewDelegate = Coordinator()

    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        
        guard let coordsInTrip = coordsInTrip else {
            print("NO COORDS")
            return map
        }
        
        
        
        let path = MKPolyline(coordinates: coordsInTrip, count: coordsInTrip.count)

         
         if !map.overlays.isEmpty{
             map.removeOverlays(map.overlays)
         }
        
        let startLocationPin = MKPointAnnotation()
        startLocationPin.coordinate = coordsInTrip[0]
        startLocationPin.title = "Start"
        
        let endLocationPin = MKPointAnnotation()
        endLocationPin.coordinate = coordsInTrip[coordsInTrip.count-1]
        endLocationPin.title = "End"
        
        map.addAnnotation(startLocationPin)
        map.addAnnotation(endLocationPin)
        
        
         
         //map.setVisibleMapRect(path.boundingMapRect, animated: true)  //Shows whole path
       DispatchQueue.main.async {

            map.addOverlay(path, level: .aboveRoads)
           map.setVisibleMapRect(path.boundingMapRect,edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: false)}
        
        return map
    }
    
    func updateUIView(_ map: MKMapView, context: Context) {

    }
    
    
    
class Coordinator : NSObject,MKMapViewDelegate{
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
       
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .black
        render.lineCap = .round
        render.lineWidth = 3.0
        return render
    }
    

}
}
    
