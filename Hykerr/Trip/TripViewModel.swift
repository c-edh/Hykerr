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
    
    @Published var trips : [Trip] = []
    @Published var mapTripCoords : [CLLocationCoordinate2D]?
    
    private let firebaseManager = FirebaseManager.shared
    
    func getUserTrips(){
        guard let user = Auth.auth().currentUser else{ print("Error couldnt get current user"); return }
                
        let pastTrips: CollectionReference = FirebaseCollection.TripsCollection.Past(user: user).tripCollections
        
        firebaseManager.getFirebaseDataInCollection(for: pastTrips) { result in
            switch result {
            case .success(let trips):
                var tripArray: [Trip] = []
                for trip in trips{
                    tripArray.append(Trip(documentReference: trip))
                }
                DispatchQueue.main.async {
                    self.trips = tripArray
                }
            case .failure(let failure):
                print(failure)
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
             
        DispatchQueue.main.async { self.mapTripCoords = tripCoords }
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
    
