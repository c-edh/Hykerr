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
        
        guard let user = Auth.auth().currentUser else{
            return
        }
     
        let time = getTimeStamp()
        
        let locationInfo = ["Date": (time["Date"] ?? "Error") as String, "Time": (time["Time"] ?? "Error") as String,
                            "lat": location.latitude, "long": location.longitude] as [String : Any]
                
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
    
    //Improve
    private  func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
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
        
        
            print(distanceTotalInMiles)
        
        let coords = coordsInTrip.printList()
        print(coords)
        
            let time = self.getTimeStamp()
//
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
            self.db.collection("Users").document(user.uid).collection("Trips").document("Current Trip").setData(
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
    
    func emergency(state: String, car: String, activeEmergency: Bool){
        
        let time = getTimeStamp()
        guard let user = Auth.auth().currentUser else{
            return
        }
        
        guard let coordsInTrip = coordsInTrip else {
            return
        }
        
        guard let location = locationManager?.location else {
            return
        }
        
        

     //Provides the database with who the hiker was with,
    //where they have been, and if it is activate or not.
        
            self.db.collection("Emergency").document(user.uid).setData(
                ["Driver Info":
                    ["State": state,
                     "Car License": car],
                 "Reported Time": (time["Time"] ?? "N/A") as String,
                 "Active Emergency": activeEmergency,
                 "Text Emergency Contact" : false,
                 "Coords in Trip": coordsInTrip.printList(),
                 "Current Location": ["Lat": String(location.coordinate.latitude),
                                      "Long": String(location.coordinate.longitude),
                                      "Time": time["Time"]
                                     ]
                ]){
                    (error) in
                    if let e = error{
                        print(e)
                    }else{
                        print("Database received the emergency")
                    }
                    
                }
        

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
