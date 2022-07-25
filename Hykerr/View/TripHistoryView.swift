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

    
    var body: some View {
        
            ScrollView{
                ForEach(viewModel.trips){trip in
                    VStack{
                        Text(trip.startingLocation + " to " + trip.endingLocation).fontWeight(.heavy)
                            .frame(width: UIScreen.main.bounds.width-20,alignment:.trailing)
                    
                        Text("Distance: " + String(format: "%.2f", trip.distance) + " miles")
                            .frame(width: UIScreen.main.bounds.width-20,alignment:.trailing)
                   
                        Text("Date: " + trip.date)
                            .frame(width: UIScreen.main.bounds.width-20,alignment:.trailing)
                    
                    
                    Divider()}}
                
            }.frame(height:UIScreen.main.bounds.height-100)
            .onAppear{
                viewModel.getUserTrips()
            }
            
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
