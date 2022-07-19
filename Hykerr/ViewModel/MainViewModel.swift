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
    
    @Published var coordsInTrip : LinkedList?
    
    @Published var profileImage = UIImage(systemName: "person.circle")!
    @Published var userName = "User"
    
    @Published var region = MKCoordinateRegion(
           center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
           latitudinalMeters: 750,
           longitudinalMeters: 750
       )
    
    private var locationManager: CLLocationManager?
    
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
                                        longitudinalMeters: 750)
                coordsInTrip = LinkedList(l.coordinate)                
            }
            
        @unknown default:
            break
        }

        
    }
    
    
    private func saveUserLocations(){
        
        guard let location = locationManager?.location?.coordinate else{
            return
        }
        
        guard let coordsInTrip = coordsInTrip else {
            print("CoordsInTrip Failed!")
            return
        }

        //Adds coords to the linkedList
        coordsInTrip.append(location)
        userTripInfoToFirebase(current: location)


    }
    
    private func getTimeStamp() -> String{
        let date = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeString = dateFormat.string(from: date)
        return timeString
        
    }
    
    
    
    func userTripInfoToFirebase(current location : CLLocationCoordinate2D){
        
        guard let user = Auth.auth().currentUser else{
            return
        }
     
        let timeString = getTimeStamp()
        
        let locationInfo = ["Time": timeString, "lat": location.latitude, "long": location.longitude] as [String : Any]
                
        db.collection(user.uid).document("Trips").updateData(
            
            //Last Updated Location
            ["Trip.Last Location":locationInfo

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
    
    func userTripInfoToFirebase(state: String, license: String){
        
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        guard let startLocation = locationManager?.location?.coordinate else{
            return
        }
        
        guard let coordsInTrip = coordsInTrip else {
            return
        }

        
        coordsInTrip.append(startLocation)

        
        let carInfo = ["State":state, "License": license]
        let timeString = getTimeStamp()
    
        let locationInfo = ["Time": timeString, "lat": startLocation.latitude, "long": startLocation.longitude] as [String : Any]

        //Firebase firestore database
        db.collection(user.uid).document("Trips").setData(
            ["Trip":[
                    "Car Info" : carInfo,
                    "Starting Location" : locationInfo,
                    "Last Location" : locationInfo
                    ]

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
    
    

    
    
}

//MARK: - MapView

struct mapView: UIViewRepresentable{
    func makeCoordinator() -> Coordinator {
        return mapView.Coordinator()
    }
    
    
    //@Binding var region : MKCoordinateRegion
    @Binding var coordsInTrip: LinkedList?

    @Binding var path : MKPolyline?
    let mapViewDelegate = Coordinator()

    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        
        if let coordsInTrip = coordsInTrip {
            
        
        let region = MKCoordinateRegion(
            center: coordsInTrip.head.value  as! CLLocationCoordinate2D,
            latitudinalMeters: 750,
            longitudinalMeters: 750
        )
            
        
        
        map.region = region
        }
        
        return map
    }
    
    func updateUIView(_ map: MKMapView, context: Context) {
        
        guard let coordsInTrip = coordsInTrip else {
            return
        }

        let currentLocation = coordsInTrip.tranverseToIndex(coordsInTrip.length)

        
        let region = MKCoordinateRegion(
            center: currentLocation.value as! CLLocationCoordinate2D,
            latitudinalMeters: 750,
            longitudinalMeters: 750
        )
        
        map.delegate = mapViewDelegate
        map.showsUserLocation = true
        map.region = region
        
        addPath(to: map)
        //
        
    }
    
    func addPath(to map : MKMapView){
        print("this updated")
        guard let coordsInTrip = coordsInTrip else {
            print("addPath failed")
            return
        }

        path = MKPolyline(coordinates: coordsInTrip.mapPath(), count: coordsInTrip.mapPath().count)

        
        if !map.overlays.isEmpty{
            map.removeOverlays(map.overlays)
        }
        
        guard let path = path else{
            print("Path failed")
            return
        }
        //map.setVisibleMapRect(path.boundingMapRect, animated: true)  //Shows whole path
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
    

}
    
    
    
}

