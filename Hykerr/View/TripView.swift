//
//  ProfileView.swift
//  Hykerr
//
//  Created by Corey Edh on 7/19/22.
//

import SwiftUI
import CoreLocationUI
import MapKit

struct TripHistoryView: View {
    
    let trips : [Trip] = [
        
        Trip(startingLocation: "Modesto", endingLocation: "Turlock", distance: 16.5, date: "07/04/2021"),
        
        Trip(startingLocation: "San Francisco", endingLocation: "Los Angeles", distance: 425.5, date: "07/22/2022"),
        
        Trip(startingLocation: "Portland", endingLocation: "Seattle", distance: 425.5, date: "07/22/2022")
    ]
    
    @State var  region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900,
                                       longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
   @State var  region2 = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.334_900,
                                       longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    @State var region1 = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 57.334_900,
                                       longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    
    var body: some View {
        VStack{
            VStack{
            Text("Trips").font(.largeTitle).fontWeight(.heavy).frame(width:UIScreen.main.bounds.width-20, alignment:.trailing)
                Text(String(trips.count)).fontWeight(.heavy).frame(width:UIScreen.main.bounds.width-20, alignment:.trailing)}
            Divider()
            ScrollView{
            ForEach(trips){trip in
                VStack{
                    Text(trip.startingLocation + " to " + trip.endingLocation).fontWeight(.heavy)
                        .frame(width: UIScreen.main.bounds.width-20,alignment:.trailing)
                   
                    Text("Date: " + trip.date)
                        .frame(width: UIScreen.main.bounds.width-20,alignment:.trailing)
                    
                    Text("Distance: " + String(trip.distance))
                        .frame(width: UIScreen.main.bounds.width-20,alignment:.trailing)
                    
                    Group{
                        Map(coordinateRegion: $region)
                            .frame(width:300,height:75,alignment: .trailing)
                            .cornerRadius(10)

                    }.frame(width:UIScreen.main.bounds.width-20,alignment:.trailing)
                    
                    Divider()
                    
                }.padding(.bottom)
                
            }}
           
            
            // SideMenu(width: UIScreen.main.bounds/1.5, menuOpened: <#T##Bool#>, toggleMenu: <#T##() -> Void#>)
            
            
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

struct TripHistoryView_Preview: PreviewProvider {
    static var previews: some View {
        TripHistoryView()
    }
}
