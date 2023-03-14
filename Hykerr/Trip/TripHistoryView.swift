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
    
    @StateObject private var viewModel = TripViewModel()

    @State private var sideMenuOpened = false
    @State private var openMapPath = false
    @State private var selected = false
    //private var selectedTrip = ""
    
    var body: some View {
        VStack{
            ScrollView{
                ForEach(viewModel.trips){trip in
                    VStack{
                    
                            Text(trip.startingLocation + " to " + trip.endingLocation).fontWeight(.heavy)
                                .frame(width: UIScreen.main.bounds.width-20,alignment:.trailing)
                        
                            Text("Distance: " + String(format: "%.2f", trip.distance) + " miles")
                                .frame(width: UIScreen.main.bounds.width-20,alignment:.trailing)
                       
                            Text("Date: " + trip.date)
                                .frame(width: UIScreen.main.bounds.width-20,alignment:.trailing)
                                
                        
                        
                    
                    
                    Divider()
                        
                    }.onTapGesture {
                        if (openMapPath == true){
                           //Todo, change region if different trip is selected
                            
                        }
                        openMapPath.toggle()
                        selected.toggle()
                        viewModel.getCoords(coords: trip.coords)
                       // print(trip.coords)
                    }
                    
                }
                
            }.frame(height:openMapPath ? 300: UIScreen.main.bounds.height-100 )
            .onAppear{
                viewModel.getUserTrips()
            }
            if openMapPath == true{
                TripView(coordsInTrip: $viewModel.mapTripCoords).frame(width: 300, height: 300, alignment: .center).cornerRadius(20).padding(75).shadow(radius: 10)
            }
//
            
        }.frame(height: UIScreen.main.bounds.height-100)
            
            .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                HStack{
                    Text(String(viewModel.trips.count)).font(.largeTitle)
                        .fontWeight(.heavy)
                    
                    Text("Trips")
                        .fontWeight(.heavy)
                }
            }
        }
    }
    
    func toggleSideMenu(){
        sideMenuOpened.toggle()
        
    }
}


struct TripHistoryView_Preview: PreviewProvider {
    static var previews: some View {
        TripHistoryView()
    }
}
