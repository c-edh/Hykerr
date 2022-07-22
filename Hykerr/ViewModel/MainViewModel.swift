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
    let tripView = TripViewModel()
    @Published var coordsInTrip : LinkedList?
    
    @Published var profileImage = UIImage(systemName: "person.circle")!
    @Published var userName = "User"
    
    var tracking = false
    
    
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
            print("Location is restrict//ParentalControl") //Inform User
        case .denied:
            print("Denied location, go into settings to fix it.") //TODO inform user
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
    
    func getCity(location : CLLocation,  completion: @escaping (String) -> Void){
        
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in

            guard let placemark = placemarks?.first else {
                let errorString = error?.localizedDescription ?? "Unexpected Error"
                print("Unable to reverse geocode the given location. Error: \(errorString)")
                return
            }

            let reversedGeoLocation = ReversedGeoLocation(with: placemark)
            completion(reversedGeoLocation.city)
         
        
        }

        
    }
    
    
    
    func userTripInfoToFirebase(current location : CLLocationCoordinate2D){
        
        guard let user = Auth.auth().currentUser else{
            return
        }
     
        let timeString = getTimeStamp()
        
        let locationInfo = ["Time": timeString, "lat": location.latitude, "long": location.longitude] as [String : Any]
                
        db.collection("Users").document(user.uid).collection("Trips").document("Current Trip").updateData(
            
            //Last Updated Location
            ["Current Trip Information.Last Location":locationInfo

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
            if self.tracking == true{
            self.saveUserLocations()
            }
            
        }
        

    }
    
    
    func userSaveTripInfoToFirebase(state : String, license: String){

        guard let user = Auth.auth().currentUser else{
            return
        }
        
        guard let coordsInTrip = coordsInTrip else {
            return
        }
        
        let carInfo = ["State": state,
                       "License" : license]
        
        guard let endLocation = locationManager?.location else {
            return
        }
        
        getCity(location: endLocation) { city in
            coordsInTrip.endTown = city
        

        
        let coords = coordsInTrip.printList()
        print(coords)
        
            let timeString = self.getTimeStamp()
//
        let locationInfo = ["Time": timeString,
                            "Car Information": carInfo,
                            "Starting City" : coordsInTrip.startTown,
                            "Ending City": coordsInTrip.endTown,
                            "Coords in Trip": coords] as [String : Any]





            let trips = self.db.collection("Users").document(user.uid).collection("Trips").document("Past Trips")

            trips.updateData(["Past Trips Information": FieldValue.arrayUnion([locationInfo])])}
        tripView.getUserTrips()
        
    }
        


    
    
    
    
    func userTripInfoToFirebase(state: String, license: String){
        
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        guard let startLocation = locationManager?.location else{
            return
        }
        
        guard let coordsInTrip = coordsInTrip else {
            return
        }
        
        //safely unwrap below
        
        getCity(location: startLocation, completion: { city in
            coordsInTrip.startTown = city
            
        })
    
        
        coordsInTrip.append(startLocation.coordinate)

        
        let carInfo = ["State":state, "License": license]
            let timeString = self.getTimeStamp()
    
        let locationInfo = ["Time": timeString, "lat": startLocation.coordinate.latitude, "long": startLocation.coordinate.longitude] as [String : Any]

        //Firebase firestore database
            self.db.collection("Users").document(user.uid).collection("Trips").document("Current Trip").updateData(
            ["Current Trip Information":[
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

       let path = MKPolyline(coordinates: coordsInTrip.mapPath(), count: coordsInTrip.mapPath().count)

        
        if !map.overlays.isEmpty{
            map.removeOverlays(map.overlays)
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

struct ReversedGeoLocation {
    let name: String            // eg. Apple Inc.
    let streetName: String      // eg. Infinite Loop
    let streetNumber: String    // eg. 1
    let city: String            // eg. Cupertino
    let state: String           // eg. CA
    let zipCode: String         // eg. 95014
    let country: String         // eg. United States
    let isoCountryCode: String  // eg. US

    var formattedAddress: String {
        return """
        \(name),
        \(streetNumber) \(streetName),
        \(city), \(state) \(zipCode)
        \(country)
        """
    }

    // Handle optionals as needed
    init(with placemark: CLPlacemark) {
        self.name           = placemark.name ?? ""
        self.streetName     = placemark.thoroughfare ?? ""
        self.streetNumber   = placemark.subThoroughfare ?? ""
        self.city           = placemark.locality ?? ""
        self.state          = placemark.administrativeArea ?? ""
        self.zipCode        = placemark.postalCode ?? ""
        self.country        = placemark.country ?? ""
        self.isoCountryCode = placemark.isoCountryCode ?? ""
    }
}
