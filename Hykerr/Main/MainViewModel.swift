//
//  MainViewModel.swift
//  Hykerr
//
//  Created by Corey Edh on 7/7/22.
//

import MapKit
import Firebase
import SwiftUI
import FirebaseFirestore


final class MainViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    private var db = Firestore.firestore()
    let tripView = TripViewModel()
    @Published var coordsInTrip : LinkedList?
    
    
    private let firebaseManager = FirebaseManager.shared
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
        guard let locationManager = locationManager else { return }
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
    
    private func getTimeStamp() -> [String:String]{
        let date = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM-dd-yyyy"
        let tripDate = dateFormat.string(from: date)
        dateFormat.dateFormat = "HH:mm:ss"
        let timeString = dateFormat.string(from: date)
        return ["Date": tripDate, "Time": timeString]
        
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
        
        guard let user = Auth.auth().currentUser else{ return }
        
        let time = getTimeStamp()
        let locationInfo = ["Date": (time["Date"] ?? "Error") as String, "Time": (time["Time"] ?? "Error") as String,
                            "lat": location.latitude, "long": location.longitude] as [String : Any]
        
        let data = ["Current Trip Information.Last Location":locationInfo]
        
        let reference = db.collection("Users").document(user.uid).collection("Trips").document("Current Trip")
        firebaseManager.updateDataInFirebase(at: reference, data: data)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if self.tracking == true{ self.saveUserLocations() }
        }
    }
    
    //Improve
    private  func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
    
    func userSaveTripInfoToFirebase(state : String, license: String){
        
        guard let user = Auth.auth().currentUser else{ return }
        guard let coordsInTrip = coordsInTrip else { return }
        guard let endLocation = locationManager?.location else { return }

        let carInfo = ["State": state, "License" : license]
        
        let pathArray = coordsInTrip.mapPath()
        var total: Double = 0.0
        
        for i in 0..<pathArray.count - 1 {
            let start = pathArray[i]
            let end = pathArray[i + 1]
            let distance = getDistance(from: start, to: end)
            total += distance
        }
        
        let distanceTotalInMiles = total/1609.344
        
        getCity(location: endLocation) { city in
            coordsInTrip.endTown = city
            
            let coords = coordsInTrip.toArray()
            
            let time = self.getTimeStamp()
            let locationInfo = ["Date": (time["Date"] ?? "Error") as String,
                                "Time": (time["Time"] ?? "Error") as String,
                                "Car Information": carInfo,
                                "Starting City" : coordsInTrip.startTown,
                                "Ending City": coordsInTrip.endTown,
                                "Distance": distanceTotalInMiles,
                                "Coords in Trip": coords] as [String : Any]
            
            let trips = self.db.collection("Users").document(user.uid).collection("Trips").document("Past Trips")
            
            trips.getDocument{ (document, error) in
                if let document = document, document.exists{
                    trips.updateData(["Past Trips Information": FieldValue.arrayUnion([locationInfo])])
                    
                }else {
                    trips.setData(
                        ["Past Trips Information": FieldValue.arrayUnion([locationInfo])]
                    )
                    
                }
            }
            
            self.tripView.getUserTrips()
        }
    }
    
    func userTripInfoToFirebase(state: String, license: String){
        
        guard let user = Auth.auth().currentUser, let coordsInTrip = coordsInTrip else{ return }
        guard let startLocation = locationManager?.location else{ return }

        //safely unwrap below
//        getCity(location: startLocation, completion: { city in
//            coordsInTrip.startTown = city
//
//        })
        coordsInTrip.append(startLocation.coordinate)

        let carInfo = ["State":state, "License": license]
        let timeString = self.getTimeStamp()
        let locationInfo = ["Time": timeString, "lat": startLocation.coordinate.latitude, "long": startLocation.coordinate.longitude] as [String : Any]
        
        //Firebase firestore database
        let data: [String: Any ] = ["Current Trip Information":[
            "Car Info" : carInfo,
            "Starting Location" : locationInfo,
            "Last Location" : locationInfo
        ]]
        
        let reference = self.db.collection("Users").document(user.uid).collection("Trips").document("Current Trip")
        firebaseManager.addToFirebase(with: reference, data: data) { _ in }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.saveUserLocations()
        }
    }
    
    func emergency(state: String, car: String, activeEmergency: Bool){
        
        let time = getTimeStamp()
        guard let user = Auth.auth().currentUser, let coordsInTrip = coordsInTrip  else{
            return
        }
        guard let location = locationManager?.location else {
            return
        }
        
        let data: [String : Any] =  ["Driver Info": ["State": state, "Car License": car],
                                     "Reported Time": (time["Time"] ?? "N/A") as String,
                                     "Active Emergency": activeEmergency,
                                     "Text Emergency Contact" : false,
                                     "Coords in Trip": coordsInTrip.toArray(),
                                     "Current Location": ["Lat": String(location.coordinate.latitude),
                                                          "Long": String(location.coordinate.longitude),
                                                          "Time": time["Time"]
                                                         ]
        ]
        
        let reference: FirebaseCollection = .Emergency
        firebaseManager.addToFirebase(with: reference.documentReference, data: data) {result in
            switch result {
            case .success(_):
                print("success")
            case .failure(let failure):
                print(failure)
            }
        }
        
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
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
