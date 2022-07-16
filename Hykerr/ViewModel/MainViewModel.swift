//
//  MainViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 7/7/22.
//

import MapKit
import Firebase
import SwiftUI


final class MainViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    private var db = Firestore.firestore()
    
     var coordsInTrip = LinkedList(0)
    
    @Published var path : MKPolyline?
    @Published var profileImage = UIImage(systemName: "person.circle")!
    @Published var userName = "User"
    @Published var currentLocation = CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020)
    
    @Published var region = MKCoordinateRegion(
           center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
           latitudinalMeters: 750,
           longitudinalMeters: 750
       )
    
    var locationManager: CLLocationManager?
    
    func checkIfLocationServiceIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        }else{
            //Alert user to enable it in settings
        }
    }
    
    private func checkLocationAuthorization(){
        
        guard let locationManager = locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            print("Location is restrict//ParentalControl")
        case .denied:
            print("Denied location, go into settings to fix it.")
        case .authorizedAlways, .authorizedWhenInUse:
            if let l = locationManager.location{
            region = MKCoordinateRegion(center: l.coordinate,
                latitudinalMeters: 750,
                                        longitudinalMeters: 750)}
            
        @unknown default:
            break
        }

        
    }
    
    func saveUserLocations(){
        
        guard let location = locationManager?.location?.coordinate else{
            return
        }
   //     currentLocation = location
        
        //Adds coords to the linkedList
        coordsInTrip.append(location)
        updatePath()
        userLocationToFirebase(upload: location)
    }
    
    
    
    func userLocationToFirebase(upload location : CLLocationCoordinate2D){
        //Get userid -> Pick Up Location, and Last know location (update every 10 seconds?) and Time intervels
        
        
        
        //REGION GETS THE MAP CENTER, If user moves it wont get their location
        
        
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        
        db.collection(user.uid).document("currentTrip").setData(
            
            //Last Updated Location
            ["location" : ["lat": location.latitude,
                           "long": location.longitude]

                ]){
                    (error) in
                    if let e = error{
                        print(e)
                    }
                    else{
                        print("Sent Sucessful")
                    }
                }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.saveUserLocations()
        }

    }
    
    func getUserPicture(){
        //Only works after the user sign up they exit the app and reopen it
        
        guard let user = Auth.auth().currentUser else {
            print("getUserPicture didn't get firebase user info right")
            return
        }
        
    

        let userStoredImageRef =  Storage.storage().reference().child("user/\(user.uid)")
        
        userStoredImageRef.getData(maxSize: 1*1024*1024) { data, error in
            if let error = error{
                print(error.localizedDescription, "Error has occured, default image is displayed")
            }else{
                let userStoredImage = UIImage(data: data!)
                self.profileImage = userStoredImage!

            }
        }
    }
    
    func getUserName(){
        
        //Not working? dont know about display name
        guard let user = Auth.auth().currentUser else{
            return
            
        }
        
        userName = user.displayName ?? "User1"
        
    }
    
    //
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    
    func updatePath(){
        print(coordsInTrip.printList())
        path = MKPolyline(coordinates: coordsInTrip.mapPath(), count: coordsInTrip.mapPath().count)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.updatePath()
            
        }
    }
    

    
    
}

//MARK: - MapView

struct mapView: UIViewRepresentable{
    func makeCoordinator() -> Coordinator {
        return mapView.Coordinator()
    }
    
    
    //@Binding var region : MKCoordinateRegion
    @Binding var currentLocation: CLLocationCoordinate2D

    @Binding var path : MKPolyline?
    let mapViewDelegate = Coordinator()

    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        
        let region = MKCoordinateRegion(
            center: currentLocation,
            latitudinalMeters: 750,
            longitudinalMeters: 750
        )
        
        map.region = region
        
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.delegate = mapViewDelegate
        uiView.showsUserLocation = true
        uiView.setCenter(currentLocation, animated: true)
        addPath(to: uiView)
        //
        
    }
    
    func addPath(to map : MKMapView){
        print("this updated")
        
//        if !map.overlays.isEmpty{
//            map.removeOverlays(map.overlays)
//        }
        
        guard let path = path else{
            print("Path failed")
            return
        }
        map.setVisibleMapRect(path.boundingMapRect, animated: true)
        map.addOverlay(path, level: .aboveRoads)

        
    }
    
class Coordinator : NSObject,MKMapViewDelegate{
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
       
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .black
        render.lineCap = .round
        render.lineWidth = 3.0
        return render
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {

         }
    


    
}
    
    
    
}

