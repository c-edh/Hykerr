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
    @State var coordsInTrip : [CLLocationCoordinate2D]?

    let mapViewDelegate = Coordinator()

    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        
//        if let coordsInTrip = coordsInTrip {
//
//
////        let region = MKCoordinateRegion(
////            center: coordsInTrip  as! CLLocationCoordinate2D,
////            latitudinalMeters: 750,
////            longitudinalMeters: 750
////        )
////
////
////
////        map.region = region
//        }
        addPath(to: map)
        return map
    }
    
    func updateUIView(_ map: MKMapView, context: Context) {

    }
    
    func addPath(to map : MKMapView){
        guard let coordsInTrip = coordsInTrip else {
            return
        }

       let path = MKPolyline(coordinates: coordsInTrip, count: coordsInTrip.count)

        
        if !map.overlays.isEmpty{
            map.removeOverlays(map.overlays)
        }
        
        //map.setVisibleMapRect(path.boundingMapRect, animated: true)  //Shows whole path
        map.addOverlay(path, level: .aboveRoads)
        map.setVisibleMapRect(path.boundingMapRect, animated: true)

        
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
    
